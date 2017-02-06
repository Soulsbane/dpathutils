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

private string buildNormalizedPathEx(const string[] paths...) pure @safe
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

	string toString()
	{
		version(Windows)
		{
			//FIXME: Could be an issue with drive letters.
			return range_.join("\\").buildNormalizedPath;
		}
		else
		{
			return range_.join("/").buildNormalizedPath;
		}
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

	this(const string path) pure @safe
	{
		path_ = buildNormalizedPathEx(path);
	}

	this(string[] pstrs...) pure @safe
	{
		path_ = pstrs.buildNormalizedPathEx();
	}

	string toString() pure nothrow @safe
	{
		return path_;
	}

	PathRange toPathRange()
	{
		auto range = PathRange(path_);
		return range;
	}

	string extension() pure nothrow @safe
	{
		return path_.extension();
	}

	string rootName() pure nothrow @safe
	{
		return path_.rootName();
	}

	version(Windows)
	{
		string driveName() pure nothrow @safe
		{
			return path_.driveName();
		}

		Path stripDrive() pure @safe
		{
			return Path(path_.stripDrive());
		}
	}

	Path toAbsolute() pure @safe
	{
		return Path(path_.absolutePath());
	}

	Path toAbsolute(string base) pure @safe
	{
		return Path(path_.absolutePath(base));
	}

	Path toRelative() pure
	{
		return Path(path_.relativePath());
	}

	Path toRelative(string base) pure
	{
		return Path(path_.relativePath(base));
	}

	Path dirName()
	{
	   return Path(path_.dirName());
	}

	bool empty() pure nothrow @safe
	{
		return path_ == string.init;
	}

	bool opEquals(const string path) pure nothrow @safe
	{
		return path == path_;
	}

	bool opEquals(Path path) pure nothrow @safe
	{
		return path.toString == path_;
	}

	Path opAssign(const string path)
	{
		path_ = path;
		return this;
	}

private:
	string path_ = ".";
}

unittest
{
	assert(buildNormalizedPathEx("\\home/soulsbane") == "/home/soulsbane");
	assert(buildNormalizedPathEx() == "");
	assert(buildNormalizedPathEx(null) == null);
	assert(buildNormalizedPathEx(null) == "");

	PathRange emptyRange;
	assert(emptyRange.empty);

	auto path = PathRange("/home/zekereth/stuff");

	assert(path.back == "stuff");
	assert(path.front == "/");
	assert(path.toString == "/home/zekereth/stuff");
	assert(path.length == 4);
	assert(path[0] == "/");
	assert(path[3] == "stuff");
	assert(path[4] == ".");

	foreach(dir; path)
	{
		writeln(dir);
	}

	writeln("------------------");

	auto strPath = Path("/home/zekereth/stuff/");
	assert(strPath == "/home/zekereth/stuff");
	assert(strPath.dirName == "/home/zekereth");
	assert(!strPath.empty);

	auto strPath2 = Path("/home/zekereth/stuff");
	assert(strPath == strPath2);

	writeln("------------------");
	auto convertedToRange = strPath.toPathRange();

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

	Path assignTest = "/home/assign/path";
	assert(assignTest == "/home/assign/path");

	assignTest = "/home/assign/another/path"; // opAssign
	assert(assignTest == "/home/assign/another/path");
}

