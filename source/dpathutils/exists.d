/**
	Various functions for dealing with path based manipulation and retrieval.

	Authors:
		Paul Crane
*/
module dpathutils.exists;

import std.process : environment;
import std.path : buildNormalizedPath, dirName;
import std.file : exists, mkdirRecurse, rmdirRecurse;
import std.algorithm : splitter;

/**
	Determines if executableName is in the user's path.

	Params:
		executableName = Name of the executable to look for.

	Returns:
		The path to the executable if found otherwise null.
*/
string isInPath(const string executableName) @safe
{
	version(windows)
	{
		enum separator = ";";
	}
	else
	{
		enum separator = ":";
	}

	foreach(dir; splitter(environment["PATH"], separator))
	{
		auto path = dir.buildNormalizedPath(executableName);

		if(path.exists)
		{
			return path;
		}
	}

	return null;
}

/**
	Ensures a directory path exists by creating it if it does not already exist.

	Params:
		path = string containing the path to create.

	Returns:
		true if path was created false otherwise.
*/
bool ensurePathExists(const string path)
{
	if(!path.exists)
	{
		path.mkdirRecurse;
	}

	return path.exists;
}

/**
	Ensures a directory path exists by creating it if it does not already exist.

	Params:
		args = Variable number of argument strings containing the path to create.

	Returns:
		true if path was created false otherwise.
*/
bool ensurePathExists(T...)(T args)
{
	immutable string path = buildNormalizedPath(args);

	if(!path.exists)
	{
		path.mkdirRecurse;
	}

	return path.exists;
}

/**
	Remove the path if it exists.

	Params:
		path = path to create.
*/
bool removePathIfExists(const string path)
{
	if(path.exists)
	{
		path.rmdirRecurse;
	}

	return !path.exists;
}

/**
	Remove the path if it exists.

	Params:
		args = Variable number of strings that compose the path.
*/
bool removePathIfExists(T...)(T args)
{
	immutable string path = buildNormalizedPath(args);

	if(path.exists)
	{
		path.rmdirRecurse;
	}

	return !path.exists;
}
