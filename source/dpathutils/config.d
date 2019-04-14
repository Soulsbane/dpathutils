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

import standardpaths;

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

	deprecated("Use getAppDir instead.") string getDir(T...)(T args) pure nothrow const @safe
	{
		return buildNormalizedPath(configDirPath_, organizationName_, applicationName_, args);
	}

	/**
		Retrieves the path to the applicationName's config directory.
	*/
	string getAppConfigDir(T...)(T args) const pure nothrow @safe
	{
		return buildNormalizedPath(configDirPath_, organizationName_, applicationName_, args);
	}

	deprecated("Use getAppConfigDir instead.") string getAppDir(T...)(T args) const pure nothrow @safe
	{
		return buildNormalizedPath(configDirPath_, organizationName_, applicationName_, args);
	}

	/**
		Gets the user's config directory path. Ex /home/user/.config

		Returns:
			The path to the user's config directory.
	*/
	deprecated("Use getBaseConfigDir instead.") string getConfigDir(T...)(T args) const pure nothrow @safe
	{
		return buildNormalizedPath(configDirPath_, args);
	}

	/**
		Gets the user's config directory path. Ex /home/user/.config

		Returns:
			The path to the user's config directory.
	*/
	string getBaseConfigDir(T...)(T args) const pure nothrow @safe
	{
		return buildNormalizedPath(configDirPath_, args);
	}

	/**
		Gets the user's home directory path. Ex /home/user

		Returns:
			The path to the user's home directory.
	*/
	string getHomeDir() const nothrow @safe
	{
		return homeDir();
	}

	/**
		Get the users cache directory.

		Returns:
			The path to the user's cache directory.
	*/
	string getCacheDir(T...)(T args) const nothrow @safe
	{
		return buildNormalizedPath(writablePath(StandardPath.cache), organizationName_, applicationName_, args);
	}

	/**
		Get the users data directory.

		Returns:
			The path to the user's data directory.
	*/
	string getDataDir(T...)(T args) const nothrow @safe
	{
		return buildNormalizedPath(writablePath(StandardPath.data), organizationName_, applicationName_, args);
	}

	/**
		Get the users desktop directory.

		Returns:
			The path to the user's desktop directory.
	*/
	string getDesktopDir()
	{
		return writablePath(StandardPath.desktop);
	}

	/**
		Get the users documents directory.

		Returns:
			The path to the user's documents directory.
	*/
	string getDocumentsDir()
	{
		return writablePath(StandardPath.documents);
	}

	/**
		Get the users pictures directory.

		Returns:
			The path to the user's pictures directory.
	*/
	string getPicturesDir()
	{
		return writablePath(StandardPath.pictures);
	}

	/**
		Get the users music directory.

		Returns:
			The path to the user's music directory.
	*/
	string getMusicDir()
	{
		return writablePath(StandardPath.music);
	}

	/**
		Get the users videos directory.

		Returns:
			The path to the user's videos directory.
	*/
	string getVideosDir()
	{
		return writablePath(StandardPath.videos);
	}

	/**
		Get the users downloads directory.

		Returns:
			The path to the user's downloads directory.
	*/
	string getDownloadsDir()
	{
		return writablePath(StandardPath.downloads);
	}

	version(Windows)
	{
		/**
			Get the users roaming directory. Only available in Windows.

			Returns:
				The path to the user's roaming directory.
		*/
		string getRoamingDir()
		{
			return writablePath(StandardPath.roaming);
		}

		/**
			Get the users saved games directory. Only available in Windows.

			Returns:
				The path to the user's saved games directory.
		*/
		string getSavedGamesDir()
		{
			return writablePath(StandardPath.savedGames);
		}
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
		immutable string normalPath = getAppConfigDir(args);

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
		immutable string normalPath = getAppDir(args);

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
		rmdirRecurse(getAppConfigDir());
	}

	/**
		Determines whether the path exists in the application's config directory.
	*/
	bool exists(T...)(T args) nothrow const @safe
		if(isSomeString!T)
	{
		immutable string path = getAppConfigDir(args);
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
	auto path = ConfigPath("DlangUnitOrg", "MyUnitTestApp");

	assert(path.createDir("tests"));
	assert(path.exists("tests"));

	writeln(path.getAppDir("tests"));
	writeln(path.getConfigDir("tests"));
	writeln(path.getAppDir);
	writeln(path.getAppDir("blah"));
	writeln(path.getDataDir);
	writeln(path.getConfigDir);
	writeln(path.getConfigDir("foo", "bar"));

	assert(path.removeDir("tests"));
	path.removeAllDirs();
}
