module dpathutils.path;

import std.path;
import std.algorithm.searching : all;
import std.string : replace;
import std.traits;
import std.array;

import std.stdio : writeln;

private auto getPathSplitterReturnType()
{
	return pathSplitter(".");
}

private alias PathSplitterType = ReturnType!(getPathSplitterReturnType);

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

	this(PathSplitterType range)
	{
		range_ = range;
	}

	string asString()
	{
		return range_.join("/").buildNormalizedPath;
	}

private:

	//INFO: Since phobos makes use of voldemort types we have to work to get the actual type that pathSplitter returns.
	//ReturnType!(getPathSplitterReturnType) range_;
	PathSplitterType range_;

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

	PathRange asPathRange()
	{
		auto range = PathRange(path_);
		return range;
	}

private:
	string path_ = ".";
}

unittest
{
	assert(buildNormalizedPathEx("\\home/soulsbane") == "/home/soulsbane");

	auto path = PathRange("/home/zekereth/stuff");

	assert(path.back == "stuff");
	assert(path.front == "/");
	assert(path.asString == "/home/zekereth/stuff");

	foreach(dir; path)
	{
		writeln(dir);
	}

	writeln("------------------");

	auto strPath = Path("/home/zekereth/stuff");
	//assert(strPath == "/home/zekereth/stuff"); // TODO: opEquals

	writeln("------------------");
	auto convertedToRange = strPath.asPathRange();

	foreach(dir; convertedToRange)
	{
		writeln(dir);
	}

	writeln("------------------");
	auto splitter = pathSplitter("/usr/lib/local");
	auto pathSplit = PathRange(splitter);

	foreach(dir; pathSplit)
	{
		writeln(dir);
	}

	assert(buildNormalizedPathEx() == "");
	assert(buildNormalizedPathEx(null) == null);
	assert(buildNormalizedPathEx(null) == "");
}

