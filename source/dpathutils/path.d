module dpathutils.path;

import std.path;
import std.algorithm.searching : all;
import std.string : replace;
import std.traits;
import std.array;
import std.range;

import std.stdio : writeln;

private auto getPathSplitterReturnType()
{
	return pathSplitter(".");
}

//INFO: Since phobos makes use of voldemort types we have to work to get the actual type that pathSplitter returns.
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

	size_t length()
	{
		return walkLength(range_);
	}

	auto opIndex(size_t index)
	{
		size_t currentIndex;

		foreach(dir; range_)
		{
			if(currentIndex == index)
			{
				return dir;
			}

			++currentIndex;
		}

		return ".";
	}

private:
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

	string asString() pure @safe
	{
		return path_;
	}

	PathRange asPathRange()
	{
		auto range = PathRange(path_);
		return range;
	}

	bool opEquals(const string path) pure @safe
	{
		return path == path_;
	}

	bool opEquals(Path path) pure @safe
	{
		return path.asString == path_;
	}

private:
	string path_ = ".";
}

unittest
{
	assert(buildNormalizedPathEx("\\home/soulsbane") == "/home/soulsbane");

	PathRange emptyRange;
	assert(emptyRange.empty);

	auto path = PathRange("/home/zekereth/stuff");

	assert(path.back == "stuff");
	assert(path.front == "/");
	assert(path.asString == "/home/zekereth/stuff");
	assert(path.length == 4);
	assert(path[0] == "/");
	assert(path[3] == "stuff");
	assert(path[4] == ".");

	foreach(dir; path)
	{
		writeln(dir);
	}

	writeln("------------------");

	auto strPath = Path("/home/zekereth/stuff");
	assert(strPath == "/home/zekereth/stuff");

	auto strPath2 = Path("/home/zekereth/stuff");
	assert(strPath == strPath2);

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

