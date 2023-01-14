local self_ID  = "ARES" 

declare_plugin(self_ID,
{
installed 	 = true, -- if false that will be place holder , or advertising
displayName     = _("ARES"),
developerName   =   "A. Barth",
version		 = "pre-alpha",
state		 = "installed",
info		 = _("ARES"),
-- binaries	= { 'ARES_FM', },  -- The DLL of the external flight model 


InputProfiles =
{
    ["ARES"] = current_mod_path .. '/Input/ARES',
},

Skins	=
	{
		{
			name	= _("ARES with SFM"), -- Mod title in bottom banner on startup
			dir		= "Skins/1"
		},
	},

Missions =
	{
		{
			name		= _("ARES"), -- Title in Instant Action
			dir			= "Missions",
		},
	},


LogBook =
	{
		{
			name		= _("Model 151 ARES"), -- Title of entry in logbook
			type		= "ARES",
		},
	},		
})



mount_vfs_texture_path  (current_mod_path ..  "/Theme/ME")--for simulator loading window
mount_vfs_texture_path  (current_mod_path ..  "/Textures/ARES")
mount_vfs_model_path    (current_mod_path ..  "/Shapes")


--local support_cockpit = current_mod_path..'/Cockpit/Scripts/'
dofile(current_mod_path..'/loadout.lua')
dofile(current_mod_path..'/weapons.lua')

dofile(current_mod_path..'/ARES.lua')
dofile(current_mod_path.."/Views.lua")
make_view_settings('ARES', ViewSettings, SnapViews)
mount_vfs_sound_path (current_mod_path.."/Sounds/")

--[[
local FM = 
{
	[1] = self_ID,
	[2] = "ARES_FM",
	center_of_mass		=	{ 0.183 , 0.261 , 0.0},		-- center of mass position relative to object 3d model center for empty aircraft
	moment_of_inertia  	= 	{12874.0, 85552.1, 75673.6},   	-- moment of inertia of empty aircraft
	suspension   = suspension, -- gear posts initialization
} 
--]]


-- make_flyable('ARES',nil,FM,nil)
----------------------------------------------------------------------------------------
make_flyable('ARES', current_mod_path..'/Cockpit/Scripts/' , nil , current_mod_path..'/comm.lua')
----------------------------------------------------------------------------------------
plugin_done()
