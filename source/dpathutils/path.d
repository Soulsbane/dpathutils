/**
	Basic Path functionality.
*/
module dpathutils.path;

import std.path;
import std.algorithm.searching : all;
import std.string : replace;
import std.traits;
import std.array;
import std.range;
import std.typecons;
import std.stdio : writeln;
import std.file : thisExePath;

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

/**
	A rangified path object.
*/
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

/**
	Average path handling object.
*/
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

	/*bool opEquals(string value) const
	{
		return value == path_;
	}

	bool opEquals()(auto ref const Path value) const
	{
		return value.path_ == path_;
	}

	int opCmp()(auto ref const Path value) const
	{
		return std.path.filenameCmp(path_, value.path_);
	}

	int opCmp(string value) const
	{
		return std.path.filenameCmp(path_, value);
	}

	void opAssign(string value)
	{
		path_ = value;
	}

	void opAssign(Path value)
	{
		path_ = value.path_;
	}*/

	mixin Proxy!path_;

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

	auto strPath = Path("/home/zekereth/stuff/");

	assert(strPath == "/home/zekereth/stuff");
	assert(strPath.dirName == "/home/zekereth");
	assert(!strPath.empty);

	auto strPath2 = Path("/home/zekereth/stuff");
	assert(strPath == strPath2);

	auto convertedToRange = strPath.toPathRange();

	foreach(dir; convertedToRange)
	{
		writeln(dir);
	}

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
	assert(assignTest.toString == "/home/assign/another/path");
	assert(assignTest.toRelative == "../../../../../assign/another/path");
	assert(assignTest.toAbsolute == "/home/assign/another/path");
	assert(assignTest.rootName == "/");

	Path application = "/home/documents/myfile.txt";
	assert(application.extension == ".txt");

	PathSplitterType splitType;
	assert(typeof(splitType).stringof == "PathSplitter");
}

/**
	Retrieves the complete path where the application resides.

	Returns:
		A string path where the the application resides.
*/
string getAppPath() @safe
{
	return dirName(thisExePath());
}

/**
	Retrieves the complete path where the application resides with the provided path appended.

	Params:
		path = The path to append to the application path.

	Returns:
		A string path where the the application resides with the provided path appended.
*/
string getAppPath(string[] path...) @safe
{
	return buildNormalizedPath(dirName(thisExePath()) ~ path);
}

///
unittest
{
	/*immutable string notFound =  isInPath("fakeprogram");
	immutable string found =  isInPath("ls");

	assert(found.length);
	assert(notFound == null);
	assert(ensurePathExists("my", "test", "dir"));
	assert(removePathIfExists("my"));
	assert(ensurePathExists("my/test/dir"));
	assert(removePathIfExists("my"));

	assert(getAppPath() == dirName(thisExePath()));
	assert(getAppPath("test") == buildNormalizedPath(dirName(thisExePath()) ~ "/test"));*/
}
