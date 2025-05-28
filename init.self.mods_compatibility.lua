function minetest_wadsprint.load_mods_compatibility()
	dofile(minetest.get_modpath(minetest.get_current_modname()).."/init.mod.hud.lua")
	dofile(minetest.get_modpath(minetest.get_current_modname()).."/init.mod.hudbars.lua")
	dofile(minetest.get_modpath(minetest.get_current_modname()).."/init.mod.farming.lua")
	dofile(minetest.get_modpath(minetest.get_current_modname()).."/init.mod.playerphysics.lua")
	dofile(minetest.get_modpath(minetest.get_current_modname()).."/init.mod.player_monoids.lua")
end
