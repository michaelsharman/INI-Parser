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