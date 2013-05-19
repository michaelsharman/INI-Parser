/**
* @author  Michael Sharman michael[at]chapter31.com
* http://chapter31.com/
* @description Parses initialisation (ini) files and returns a structure of key/value properties
*/
component accessors="true" output="false"
{

	property name="iniDirectory" type="string" getter="true" setter="true" default="";
	property name="iniPath" type="string" getter="true" setter="true" default="";

	/**
	* @param {String} iniPath Absolute path to a textfile in the INI format
	* @param {String} iniDirectory Absolute path to a directory that holds INI files (used for checkCompare())
	*/
	public function init(string iniPath = "", string iniDirectory = "")
	{
		setINIDirectory(arguments.iniDirectory);
		setINIPath(arguments.iniPath);
		return this;
	}


	/**
	* @hint Compares INI files in a given directory to ensure all 'keys' are present across all files. Does not check actual
	* values, just key names. We do this to make sure properties (keys) aren't accidentally excluded from some
	* environment nfiles, such as production
	* @param {String} ignoreProperties If you have properties you know are specific to certain environment (ini) files,
	* suppress them from the comparison. Should be a comma delimited list of strings
	*/
	public boolean function checkCompare(string ignoreProperties = "")
	{
		try
		{
			var files = directoryList(path=getINIDirectory(), recurse=false, listInfo="path", filter="*.ini", sort="directory ASC");
			var properties = {};
			var originalINIPath = getINIPath();
			var keysList = [];
			var keys = [];
			var key = "";
			var subkey = "";
			var i = "";
			var isEqual = true;

			if (!arrayLen(files))
			{
				throw(type="iniparser.checkcompare.dirempty", message="The INI directory was not found or was empty");
			}

			// Get the key list in the properties structure (include sub-keys) for each properties file in the supplied directory
			for (var ini IN files)
			{
				setINIPath(ini);
				properties = parse();
				keys = [];
				for (key IN properties)
				{
					if (!listFindNoCase(arguments.ignoreProperties, key))
					{
						keys.add(key);
						// Check that the value of the "key" is a structure (we only check one level deep, as per INI spec)
						if (isStruct(properties[key]))
						{
							for (subkey IN properties[key])
							{
								if (!listFindNoCase(arguments.ignoreProperties, subkey))
								{
									keys.add(subkey);
								}
							}
						}
					}
				}
				arraySort(keys, "text", "asc");
				// Add all keys for this file to a global array for later comparison
				keysList.add(arrayToList(keys));
			}

			// Compare the sorted lists (one list for each ini file) for equality
			for (i = 1; i < arrayLen(keysList); i++)
			{
				if (!keysList[i].equalsIgnoreCase(keysList[i+1]))
				{
					isEqual = false;
					break;
				}
			}

			// Just in case we already had a path in the class var, set it back to the original value
			setINIPath(originalINIPath);

			return isEqual;
		}
		catch (any e)
		{
			throw(type="iniparser.checkcompare.error", message=e.getMessage());
		}
	}


	/**
	* @hint Parses a textfile in the INI format and returns a structure of variables grouped by sections
	*/
	public struct function parse()
	{
		try
		{
			var properties = {};
			var prop = "";
			var section = "";
			var sections = getProfileSections(getINIPath());

			// If there are no sections in the ini file, return a single level struct of name=value pairs
			if (structIsEmpty(sections))
			{
				return parseSimple();
			}

			for (section in sections)
			{
				properties[section] = {};
				for (prop in listToArray(sections[section]))
				{
					properties[section][prop] = getProfileString(getINIPath(), section, prop);
				}
			}

			return properties;
		}
		catch(java.io.FileNotFoundException e)
		{
			throw(type="iniparser.parse.filenotfound", message="Ini file not found in path '#getINIPath()#'");
		}
		catch (any e)
		{
			throw(type="iniparser.parse.error", message=e.getMessage());
		}
	}


	/**
	* @hint Parses a simple INI file that contains name=value pairs with no sections and returns a single level struct
	*/
	private struct function parseSimple()
	{
		var iniFile = fileOpen(getINIPath(), "read", "utf-8");
		var line = "";
		var properties = {};

		while(!fileisEOF(iniFile))
		{
			line = fileReadLine(iniFile);
			// Ignore empty (spacer) lines, as well as comment lines (;)
			if (len(line) && left(trim(line), 1) != ";")
			{
				properties[trim(listFirst(line, "="))] = trim(listLast(line, "="));
			}
		}
		fileClose(iniFile);

		return properties;
	}

}
