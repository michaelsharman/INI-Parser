#INI Parser
Parses an initialisation (ini) text file and returns a ColdFusion structure of properties. Typically used to store environment/config variables in application scope (in onApplicationStart())

##Usage
```
config = new INIParser('/path_to_config.ini').parse();
```

##INI format

With sections:

```
[environment]
mode = development

[exceptions]
mailto = admin@mysite.com
view = /view/error.cfm

[url]
www = http://mysite.com/
admin = https://admin.mysite.com/
```

Without sections:

```
mode = development
mailto = admin@mysite.com
view = /view/error.cfm
www = http://mysite.com/
admin = https://admin.mysite.com/
```

##Compare INI files
Typically your application will have multiple INI files, one for each environment. Eg

* development
* staging
* UAT
* production

There is a risk that a developer may add properties to one file (for example _development_) but not to the other environment files. This could cause an outage once a deployment is done to production etc.

To mitigate this scenario, there is a _checkCompare()_ method you can run on a directory holding all project INI files. This will check that all properties (keys) are present across all files. It does not check values, just that the properties exist.

```
checkINIFilesEqual = new INIParser('/path_to_ini_dir').checkCompare();
```