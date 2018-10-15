/**
	Provides an easy way to work the users configuration directory.

	Authors:
		Paul Crane
*/
module dpathutils.config;

import std.path : buildNormalizedPath;
import std.file : mkdirRecurse, rmdirRecurse, exists;
import std.traits;
public import std.typecons : Yes, No, Flag;

/**
	Allows for the creation and deletion of directories in the users configuration directory.
*/
struct ConfigPath
{
	/**
		Intializes the application name to executables name and setups up config directory using supplied arguments.

		Params:
			organizationName = Name of your organization.
			applicationName = Name of your application.
			createDirs = Also create the config directory
	*/
	this(const string organizationName, const string applicationName,
		const Flag!"createDirs" createDirs = Yes.createDirs) @safe
	{
		create(organizationName, applicationName, createDirs);
	}

	/**
		Intializes the application name to executables name and setups up config directory using supplied arguments.

		Params:
			organizationName = Name of your organization.
			applicationName = Name of your application.
			createDirs = Also create the config directory
	*/
	void create(const string organizationName, const string applicationName,
		const Flag!"createDirs" createDirs = Yes.createDirs) @safe
	{
		import standardpaths : StandardPath, writablePath;

		organizationName_ = organizationName;
		applicationName_ = applicationName;

		configDirPath_ = writablePath(StandardPath.config);

		if(createDirs)
		{
			createDir(""); // Creates the actual config dir. Ex ~/.config/organization/applicationName
		}
	}

	/**
		Retrieves the path to the users config directory with an optional path appended to the end.

		Params:
			args = Name of the directory to retrieve.
	*/
	string getDir(T...)(T args) pure nothrow const @safe
		if(isSomeString!T)
	{
		return buildNormalizedPath(configDirPath_, organizationName_, applicationName_, args);
	}

	/**
		Retrieves the path to the applicationName's config directory.
	*/
	string getAppDir() pure nothrow const @safe
	{
		return buildNormalizedPath(configDirPath_, organizationName_, applicationName_);
	}

	/**
		Gets the user's config directory path. Ex /home/user/.config
	*/
	string getConfigDir()
	{
		return configDirPath_;
	}

	/**
		Creates a directory in the users config directory.

		Params:
			args = Name of the directory to create.

		Returns:
			True if the directory was created false otherwise.
	*/
	bool createDir(T...)(T args) @trusted
		if(isSomeString!T)
	{
		immutable string normalPath = getDir(args);

		if(!exists(normalPath))
		{
			mkdirRecurse(normalPath);
		}

		return normalPath.exists;
	}

	/**
		Removes a directory from the users config directory.

		Params:
			args = Name of the directory to remove.

		Returns:
			True if the directory was removed false otherwise;
	*/
	bool removeDir(T...)(T args) @trusted
		if(isSomeString!T)
	{
		immutable string normalPath = getDir(args);

		if(exists(normalPath))
		{
			rmdirRecurse(normalPath);
		}

		return !normalPath.exists;
	}

	/**
		Removes all directories under applicationName including applicationName.
	*/
	void removeAllDirs() @trusted
	{
		rmdirRecurse(getAppDir());
	}

	/**
		Determines whether the path exists in the application's config directory.
	*/
	bool exists(T...)(T args) nothrow const @safe
		if(isSomeString!T)
	{
		immutable string path = getDir(args);
		return path.exists;
	}

private:
	string organizationName_;
	string applicationName_;
	string configDirPath_;
}

///
unittest
{
	import std.stdio : writeln;

	writeln;
	writeln("<=====================Beginning test for configpath module=====================>");

	auto path = ConfigPath("DlangUnitOrg", "MyUnitTestApp");

	assert(path.createDir("tests"));
	assert(path.exists("tests"));
	writeln(path.getDir("tests"));
	writeln(path.getAppDir);
	assert(path.removeDir("tests"));
	path.removeAllDirs();

	writeln();
}
