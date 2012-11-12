<cfscript>

config = new "../INIParser"('config.ini').parse();

dump(var=config);

</cfscript>