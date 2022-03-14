declare_plugin("ARES by Andrew Barth",{
version		 	  = __DCS_VERSION__,		 
state		 	  = "installed",
info		 	  = _("Armed with one 25mm cannon with 560 rounds, rockets, bombs and close combat Air-To-Air missiles."),
encyclopedia_path = current_mod_path..'/Encyclopedia'
})

mount_vfs_model_path	(current_mod_path.."/Shapes")
mount_vfs_liveries_path (current_mod_path.."/Liveries")
mount_vfs_texture_path  (current_mod_path.."/Textures")
---------------------------------------------------------
dofile(current_mod_path..'/ARES.lua')
---------------------------------------------------------
plugin_done()