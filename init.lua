-- WAD SPRINTING minetest (https://minetest.net) mod (https://dev.minetest.net/Intro)
-- @link https://github.com/aa6/minetest_wadsprint
dofile(minetest.get_modpath(minetest.get_current_modname()).."/lib.round.lua")
dofile(minetest.get_modpath(minetest.get_current_modname()).."/lib.savetable.lua")
dofile(minetest.get_modpath(minetest.get_current_modname()).."/lib.file_exists.lua")
dofile(minetest.get_modpath(minetest.get_current_modname()).."/lib.eventemitter.lua")
dofile(minetest.get_modpath(minetest.get_current_modname()).."/lib.file_get_contents.lua")
dofile(minetest.get_modpath(minetest.get_current_modname()).."/lib.file_put_contents.lua")
minetest_wadsprint = 
{
    stats = -- Online players' stats.
    {
      --  <playername string>:
      --      obj:                      <player object>
      --      name:                     <playername string>
      --      stamina:                  <float>
      --      is_walking:               <boolean>
      --      is_sprinting:             <boolean>
      --      is_ready_to_sprint:       <boolean>
      --      is_sprinting_physics_on:  <boolean>
    },
    offline_stats = -- Offline stats aren't processed in the main cycle.
    {
      --  <playername string>:
      --      stamina:                  <float>
    },
    version = file_get_contents(minetest.get_modpath(minetest.get_current_modname()).."/VERSION"),
    savepath = minetest.get_worldpath().."/mod_minetest_wadsprint_saved_players_stats.dat",
    worldconfig = minetest.get_worldpath().."/mod_minetest_wadsprint_config.lua",
}
dofile(minetest.get_modpath(minetest.get_current_modname()).."/init.api.lua")
dofile(minetest.get_modpath(minetest.get_current_modname()).."/init.core.lua")
dofile(minetest.get_modpath(minetest.get_current_modname()).."/init.legacy.lua")
dofile(minetest.get_modpath(minetest.get_current_modname()).."/init.config.lua")
dofile(minetest.get_modpath(minetest.get_current_modname()).."/init.hudbars.lua")
dofile(minetest.get_modpath(minetest.get_current_modname()).."/init.set_sprinting_physics.lua")