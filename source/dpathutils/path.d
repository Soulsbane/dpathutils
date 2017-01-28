module dpathutils.path;

import std.path;
import std.algorithm.searching : all;
import std.string : replace;
import std.traits;
import std.array;

import std.stdio : writeln;

private string buildNormalizedPathEx(const string[] paths...)
{
	if(all!`a is null`(paths))
	{
		return null;
	}

	if(all!`a == ""`(paths))
	{
		return "";
	}

	auto result = buildNormalizedPath(paths);

	version(Posix)
	{
		result = result.replace(`\`, `/`);
	}

	return result == "" ? "." : result;
}

struct PathRange
{
public:
	this(const string path)
	{
		range_ = pathSplitter(path.buildNormalizedPath);
	}

	string asString()
	{
		return range_.join("/").buildNormalizedPath;
	}

private:
	auto getPathSplitterReturnType()
	{
		return pathSplitter(".");
	}

	//INFO: Since phobos makes use of voldemort types we have to work to get the actual type that pathSplitter returns.
	ReturnType!(PathRange.getPathSplitterReturnType) range_;

	alias range_ this;
}

struct Path
{
public:

	this(const string path)
	{
		path_ = buildNormalizedPathEx(path);
	}

	string asString()
	{
		return path_;
	}

private:
	string path_ = ".";
}

unittest
{
	auto path = PathRange("/home/zekereth/stuff");

	writeln(buildNormalizedPathEx("\\home/soulsbane"));
	writeln(path.back);
	writeln(path.front);
	writeln(path.asString);

	writeln("------------------");
	foreach(dir; path)
	{
		writeln(dir);
	}

	assert(buildNormalizedPathEx() == "");
	assert(buildNormalizedPathEx(null) == null);
	assert(buildNormalizedPathEx(null) == "");
}

