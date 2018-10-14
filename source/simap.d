module simap;

mixin template StaticData(K, V, string filename, string funcName, string defaultFmt) {
	import std.format : format;
	mixin("private V[K] _"~funcName~";");
	mixin("private immutable _static"~funcName~"Data = parseData!"~K.stringof~"(import(\""~filename~"\"));");

	mixin(format(q{
		string %s(K id) {
			import std.format : format;
			if (id in _%1$s) {
				return _%1$s[id];
			}
			return format!defaultFmt(id);
		}
	}, funcName));
	static this() {
		mixin("alias immData = _static"~funcName~"Data;");
		mixin("alias dest = _"~funcName~";");
		foreach (tuple; immData) {
			dest[tuple.key] = tuple.value;
		}
	}
}

auto parseData(T)(string data) @safe pure {
	import std.algorithm.iteration : splitter;
	import std.algorithm.searching : startsWith;
	import std.array : empty;
	import std.conv : to;
	import std.string : lineSplitter, strip;
	import std.typecons : tuple, Tuple;
	Tuple!(T, "key", string, "value")[] output;
	foreach (line; data.lineSplitter) {
		if (line.startsWith("#") || line.strip().empty) {
			continue;
		}
		auto split = line.splitter("\t");
		auto bytesequence = split.front.to!T(16);
		split.popFront();
		output ~= tuple!("key","value")(bytesequence, split.front);
	}
	return output;
}