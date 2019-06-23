-- WAD SPRINTING minetest (https://minetest.net) mod (https://dev.minetest.net/Intro)
-- @link https://github.com/aa6/minetest_wadsprint
dofile(minetest.get_modpath(minetest.get_current_modname()).."/lib_round.lua")
dofile(minetest.get_modpath(minetest.get_current_modname()).."/lib_savetable.lua")
dofile(minetest.get_modpath(minetest.get_current_modname()).."/lib_file_exists.lua")
dofile(minetest.get_modpath(minetest.get_current_modname()).."/lib_eventemitter.lua")
dofile(minetest.get_modpath(minetest.get_current_modname()).."/lib_file_get_contents.lua")
dofile(minetest.get_modpath(minetest.get_current_modname()).."/lib_file_put_contents.lua")
minetest_wadsprint = 
{
    api = { events = EventEmitter:new() },
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
dofile(minetest.get_modpath(minetest.get_current_modname()).."/init_config.lua")
dofile(minetest.get_modpath(minetest.get_current_modname()).."/init_hudbars.lua")
----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------- api.stats() --
----------------------------------------------------------------------------------------------------
-- Returns player stats.
--
--  minetest_wadsprint.api.stats(player_name) -- Get player stats.
--
function minetest_wadsprint.api.stats(player_name)
    local player = minetest_wadsprint.stats[player_name]
    if player ~= nil then
        return -- Return copy of values to be sure that they won't be changed by accident.
            {
                name = player_name,
                stamina = player.stamina,
                is_walking = player.is_walking,
                is_sprinting = player.is_sprinting,
                is_ready_to_sprint = player.is_ready_to_sprint,
                is_sprinting_physics_on = player.is_sprinting_physics_on,
            }
    end
end
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------- api.stamina() --
----------------------------------------------------------------------------------------------------
-- Gets/sets player stamina.
--
--  minetest_wadsprint.api.stamina(player_name)      -- Get player stamina percentage (1 is 100%).
--  minetest_wadsprint.api.stamina(player_name, 0.1) -- SET stamina to 10% of STAMINA_MAX_VALUE.
--
function minetest_wadsprint.api.stamina(player_name, stamina_percentage)
    local player = minetest_wadsprint.stats[player_name]
    if player ~= nil then
        if stamina_value ~= nil then
            minetest_wadsprint.set_stamina(
              player, 
              minetest_wadsprint.STAMINA_MAX_VALUE * stamina_percentage
            )
        else
            return player.stamina / minetest_wadsprint.STAMINA_MAX_VALUE
        end
    end  
end
----------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------- api.addstamina() --
----------------------------------------------------------------------------------------------------
-- Adds/subtracts stamina to player.
--
--  minetest_wadsprint.api.addstamina(player_name, 0.1)  -- Add 10% of STAMINA_MAX_VALUE.
--  minetest_wadsprint.api.addstamina(player_name, -0.1) -- Subtract 10% of STAMINA_MAX_VALUE.
--
function minetest_wadsprint.api.addstamina(player_name, stamina_percentage)
    local player = minetest_wadsprint.stats[player_name]
    if player ~= nil then
        minetest_wadsprint.set_stamina(
          player, 
          player.stamina + minetest_wadsprint.STAMINA_MAX_VALUE * stamina_percentage
        )
    end  
end
----------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------- stamina_update_cycle() --
----------------------------------------------------------------------------------------------------
function minetest_wadsprint.stamina_update_cycle(player)
    if player.is_sprinting then
        minetest_wadsprint.set_stamina(player, 
            player.stamina - 
            (
                minetest_wadsprint.STAMINA_MAX_VALUE * 
                minetest_wadsprint.SPRINT_STAMINA_DECREASE_PER_UPDATE_PERIOD_COEFFICIENT
            )
        )
    else
        if player.stamina < minetest_wadsprint.STAMINA_MAX_VALUE then
            minetest_wadsprint.set_stamina(player, 
                player.stamina + 
                (
                    minetest_wadsprint.STAMINA_MAX_VALUE * 
                    minetest_wadsprint.SPRINT_STAMINA_INCREASE_PER_UPDATE_PERIOD_COEFFICIENT
                )
            )
        end
    end
end
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------- switch_to_walking() --
----------------------------------------------------------------------------------------------------
function minetest_wadsprint.switch_to_walking(player)
    if player.is_walking == false then
        if player.is_sprinting_physics_on == true then 
            minetest_wadsprint.set_sprinting_physics(player,false)
        end
        player.is_walking = true
        player.is_sprinting = false
        player.is_ready_to_sprint = false
        minetest_wadsprint.hudbar_update_ready_to_sprint(player)
        minetest_wadsprint.hudbar_update_stamina(player)
    end
end
----------------------------------------------------------------------------------------------------
--------------------------------------------------------------------- switch_to_ready_to_sprint() --
----------------------------------------------------------------------------------------------------
-- Main use of this function is to put player in a state when pressing "W" would trigger the 
-- sprinting state thus you won't need to hold "A"+"D" to keep sprinting. Also it alters player 
-- physics to workaround lag between pressing "W" and actual sprinting. So if player is ready to 
-- sprint he is sure that his physics is already in sprinting state and he can not afraid to fall
-- while jumping from a tree to tree just because the lag between pressing "W" and switching to 
-- sprinting state would be too big. At the same time being only ready to sprint but not actually 
-- sprinting does not decreases the stamina because decreasing stamina for not sprinting is unfair.
function minetest_wadsprint.switch_to_ready_to_sprint(player)
    if player.is_ready_to_sprint == false then
        if player.is_sprinting_physics_on == false then 
            minetest_wadsprint.set_sprinting_physics(player,true)
        end
        player.is_walking = false
        player.is_sprinting = false
        player.is_ready_to_sprint = true
        minetest_wadsprint.hudbar_update_ready_to_sprint(player)
        minetest_wadsprint.hudbar_update_stamina(player)
    end
end
----------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------- switch_to_sprinting() --
----------------------------------------------------------------------------------------------------
-- Sprinting means that player has altered physics and is moving forward. If player isn't moving 
-- then he isn't sprinting.
function minetest_wadsprint.switch_to_sprinting(player)
    if player.is_sprinting == false then
        if player.is_sprinting_physics_on == false then 
            minetest_wadsprint.set_sprinting_physics(player,true)
        end
        player.is_walking = false
        player.is_sprinting = true
        player.is_ready_to_sprint = false
        minetest_wadsprint.hudbar_update_ready_to_sprint(player)
        minetest_wadsprint.hudbar_update_stamina(player)
    end
end
----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------- set_sprinting_physics() --
----------------------------------------------------------------------------------------------------
dofile(minetest.get_modpath(minetest.get_current_modname()).."/init_set_sprinting_physics.lua")
----------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------- scan_player_controls() --
----------------------------------------------------------------------------------------------------
function minetest_wadsprint.scan_player_controls(player)
    local control = player.obj:get_player_control()
    if control["up"] then 
        if player.is_sprinting then
            return
        elseif player.is_ready_to_sprint then
            minetest_wadsprint.switch_to_sprinting(player)
            return
        end
    end
    if control["left"] and control["right"] and not control["down"] then
        if player.stamina > minetest_wadsprint.DYSPNEA_THRESHOLD_VALUE then
            if control["up"] then
                minetest_wadsprint.switch_to_sprinting(player)
            else
                minetest_wadsprint.switch_to_ready_to_sprint(player)
            end
        end
    else
        minetest_wadsprint.switch_to_walking(player)
    end
end
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------- set_stamina() --
----------------------------------------------------------------------------------------------------
function minetest_wadsprint.set_stamina(player,stamina_value)
    local old_stamina_value = player.stamina
    if stamina_value < 0 then
        minetest_wadsprint.switch_to_walking(player)
        player.stamina = 0
    elseif stamina_value > minetest_wadsprint.STAMINA_MAX_VALUE then
        player.stamina = minetest_wadsprint.STAMINA_MAX_VALUE
    else
        player.stamina = stamina_value
    end
    if old_stamina_value >= minetest_wadsprint.DYSPNEA_THRESHOLD_VALUE 
    and player.stamina < minetest_wadsprint.DYSPNEA_THRESHOLD_VALUE then
        minetest_wadsprint.api.events:emit(
            "dyspnea-on",
            {
                name = "dyspnea-on",
                player = player,
            }
        )
    elseif old_stamina_value < minetest_wadsprint.DYSPNEA_THRESHOLD_VALUE 
    and player.stamina >= minetest_wadsprint.DYSPNEA_THRESHOLD_VALUE then
        minetest_wadsprint.api.events:emit(
            "dyspnea-off",
            {
                name = "dyspnea-off",
                player = player,
            }
        )
    end
    minetest_wadsprint.hudbar_update_stamina(player)
end
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------- initialize_player() --
----------------------------------------------------------------------------------------------------
function minetest_wadsprint.initialize_player(player_obj)
    local player = 
    {
        obj = player_obj,
        name = player_obj:get_player_name(),
        is_walking = true,
        is_sprinting = false,
        is_ready_to_sprint = false,
        is_sprinting_physics_on = false,
    }
    if minetest_wadsprint.offline_stats[player.name] ~= nil then
        player.stamina = minetest_wadsprint.offline_stats[player.name].stamina
    else
        player.stamina = minetest_wadsprint.STAMINA_MAX_VALUE
    end
    minetest_wadsprint.stats[player.name] = player
    minetest_wadsprint.initialize_hudbar(player)
    if player.stamina < minetest_wadsprint.DYSPNEA_THRESHOLD_VALUE then
        minetest_wadsprint.api.events:emit(
            "dyspnea-on",
            {
                name = "dyspnea-on",
                player = player,
            }
        )
    end
end
----------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------- reset_player() --
----------------------------------------------------------------------------------------------------
function minetest_wadsprint.reset_player(player_obj)
    local player = minetest_wadsprint.stats[player_obj:get_player_name()]
    minetest_wadsprint.set_stamina(player,minetest_wadsprint.STAMINA_MAX_VALUE)
    minetest_wadsprint.switch_to_walking(player)
end
----------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------- deinitialize_player() --
----------------------------------------------------------------------------------------------------
function minetest_wadsprint.deinitialize_player(player_obj)
    local player = minetest_wadsprint.stats[player_obj:get_player_name()]
    minetest_wadsprint.offline_stats[player.name] = { stamina = player.stamina, was_online = true }
    minetest_wadsprint.stats[player.name] = nil
end
----------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------- save_players_stats() --
----------------------------------------------------------------------------------------------------
function minetest_wadsprint.save_players_stats()
    local stats = {}
    local counter = 1
    for key,val in pairs(minetest_wadsprint.stats) do
      stats[counter] = { name = key, stamina = val.stamina }
      counter = counter + 1
    end
    for key,val in ipairs(minetest_wadsprint.offline_stats) do
      if counter == minetest_wadsprint.PLAYERS_STATS_FILE_LIMIT_RECORDS then break end
      if minetest_wadsprint.stats[val.name] == nil and val.was_online ~= nil then
          stats[counter] = { name = val.name, stamina = val.stamina }
          counter = counter + 1
      end
    end
    for key,val in ipairs(minetest_wadsprint.offline_stats) do
      if counter == minetest_wadsprint.PLAYERS_STATS_FILE_LIMIT_RECORDS then break end
      if minetest_wadsprint.stats[val.name] == nil and val.was_online == nil then
          stats[counter] = { name = val.name, stamina = val.stamina }
          counter = counter + 1
      end
    end
    table.save(stats,minetest_wadsprint.savepath)
end
----------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------- load_players_stats() --
----------------------------------------------------------------------------------------------------
function minetest_wadsprint.load_players_stats()
    if file_exists(minetest_wadsprint.savepath) then
         local raw_saved_stats = table.load(minetest_wadsprint.savepath)
         minetest_wadsprint.offline_stats = {}
         for key,val in ipairs(raw_saved_stats) do
            minetest_wadsprint.offline_stats[val.name] = { stamina = val.stamina }
        end
    end
end
----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------ Mod initialization --
----------------------------------------------------------------------------------------------------
minetest.register_on_joinplayer(minetest_wadsprint.initialize_player)
minetest.register_on_respawnplayer(minetest_wadsprint.reset_player)
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
minetest.register_globalstep(function(dtime) -- Called every server step, usually interval of 0.05s.

    timer_of_stats_update = timer_of_stats_update + dtime
    timer_of_controls_check = timer_of_controls_check + dtime

    -- Run stamina update cycle for every player.
    if timer_of_stats_update > minetest_wadsprint.PLAYER_STATS_UPDATE_PERIOD_SECONDS then
        timer_of_stats_update = 0
        for player_name,player in pairs(minetest_wadsprint.stats) do
            minetest_wadsprint.stamina_update_cycle(player)
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
