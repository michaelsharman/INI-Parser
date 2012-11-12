/**
* @author  Michael Sharman michael[at]chapter31.com
* http://chapter31.com/
* @description Parses initialisation (ini) files and returns a structure of properties
*/
component output="false"
{

	/**
	* @param {String} inipath Absolute path to a textfile in the INI format
	*/
	public function init(required String inipath)
	{
		variables.instance = {
			iniPath = expandPath(arguments.iniPath)
		}

		if (!fileExists(variables.instance.iniPath))
		{
			throw(type="error", message="Ini file not found in #variables.instance.iniPath#");
		}

		return this;
	}


	/**
	* @hint Parses a textfile in the INI format and returns a structure of variables grouped by sections
	*/
	public struct function parse()
	{
		var properties = {};
		var prop = "";
		var section = "";
		var sections = getProfileSections(variables.instance.iniPath);

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
				properties[section][prop] = getProfileString(variables.instance.iniPath, section, prop);
			}
		}

		return properties;
	}


	/**
	* @hint Parses a simple INI file that contains name=value pairs with no sections and returns a single level struct
	*/
	private struct function parseSimple()
	{
		var iniFile = fileOpen(variables.instance.iniPath, "read", "utf-8");
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