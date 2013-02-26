module libetpand.datatypes.base64;

import std.string;
import std.conv;
import core.memory;

extern(C) char* encode_base64(const char *, int);
extern(C) char* decode_base64(const char *, int);

string encodeBase64(string input) {
	char* r = encode_base64(cast(const char*)toStringz(input), cast(int)input.length);
	string ret = to!(string)(r);
	GC.free(r);

	return ret;
}

string decodeBase64(string input) {
	char* r = decode_base64(cast(const char*)toStringz(input), cast(int)input.length);
	string ret = to!(string)(r);
	GC.free(r);

	return ret;
}

unittest {
	assert(decodeBase64(encodeBase64("Hello")) == "Hello");
	assert(decodeBase64(encodeBase64("Hello1234")) == "Hello1234");
}
