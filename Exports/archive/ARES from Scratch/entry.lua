declare_plugin("ARES by Andrew Barth",
{
installed 	 = true, -- if false that will be place holder , or advertising
dirName	  	 = current_mod_path,
version		 = "0.0.1.alpha",		 
state		 = "installed",
info		 = _("Scaled Composites Model 151 ARES"),

Skins	= 
	{
		{
			name	= "ARES",
			dir		= "Theme"
		},
	},
Missions =
	{
		{
			name		= _("ARES"),
			dir			= "Missions",
			CLSID		= "{CLSID5456456346CLSID}",	
		},
	},	
LogBook =
	{
		{
			name		= _("ARES"),
			type		= "ARES",
		},
	},	
InputProfiles =
	{
		["ARES"]     = current_mod_path .. '/Input',
	},
})
---------------------------------------------------------------------------------------
dofile(current_mod_path..'/ARES.lua')

plugin_done()-- finish declaration , clear temporal data
