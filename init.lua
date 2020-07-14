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
----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------ Mod initialization --
----------------------------------------------------------------------------------------------------
minetest.register_on_joinplayer(minetest_wadsprint.initialize_player)
minetest.register_on_respawnplayer(minetest_wadsprint.reset_player_stats)
minetest.register_on_leaveplayer(minetest_wadsprint.deinitialize_player)

-- Register hudbar call for compatibility with some hudbar mods.
if minetest_wadsprint.register_hudbar ~= nil then
    minetest_wadsprint.register_hudbar()
end

-- Save player stats to file on server shutdown.
if minetest_wadsprint.SAVE_PLAYERS_STATS_TO_FILE then
    minetest_wadsprint.load_players_stats()
    minetest.register_on_shutdown(minetest_wadsprint.save_players_stats)
end

-- Main cycle.
local timer_of_stats_update = 0
local timer_of_controls_check = 0
minetest.register_globalstep(function(seconds_since_last_global_step) -- Called every server step, usually interval of 0.05s.

    timer_of_stats_update = timer_of_stats_update + seconds_since_last_global_step
    timer_of_controls_check = timer_of_controls_check + seconds_since_last_global_step

    -- Run stamina update cycle for every player.
    if timer_of_stats_update > minetest_wadsprint.PLAYER_STATS_UPDATE_PERIOD_SECONDS then
        timer_of_stats_update = 0
        for player_name,player in pairs(minetest_wadsprint.stats) do
            minetest_wadsprint.stamina_update_cycle_tick(player)
        end
    end

    -- Scan players controls.
    if timer_of_controls_check > minetest_wadsprint.PLAYER_CONTROLS_CHECK_PERIOD_SECONDS then
        timer_of_controls_check = 0
        for player_name,player in pairs(minetest_wadsprint.stats) do
            minetest_wadsprint.scan_player_controls(player)
        end
    end

end)