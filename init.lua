-- WAD SPRINTING minetest (https://minetest.net) mod (https://dev.minetest.net/Intro)
-- @link https://github.com/aa6/minetest_wadsprint
minetest_wadsprint = 
{
    api = {},
    players = {},
    version = io.open(minetest.get_modpath(minetest.get_current_modname()).."/VERSION","r"):read("*all"),
    savedstats = { index = {} },
    savetablepath = minetest.get_modpath(minetest.get_current_modname()).."/saved_players_stats.dat",
}
dofile(minetest.get_modpath(minetest.get_current_modname()).."/config.lua")
dofile(minetest.get_modpath(minetest.get_current_modname()).."/init_hudbars.lua")
dofile(minetest.get_modpath(minetest.get_current_modname()).."/lib_savetable.lua")
dofile(minetest.get_modpath(minetest.get_current_modname()).."/lib_file_exists.lua")
dofile(minetest.get_modpath(minetest.get_current_modname()).."/lib_eventemitter.lua")
minetest_wadsprint.api.events = EventEmitter:new()

function minetest_wadsprint.api.stats(player_name)
    local player = minetest_wadsprint.players[player_name]
    if player ~= nil then
        return 
            {
                name = player_name,
                stamina = player.stamina,
                is_sprinting = player.is_sprinting,
                is_ready_to_sprint = player.is_ready_to_sprint,
                is_sprinting_physics_on = player.is_sprinting_physics_on,
            }
    end  
end

function minetest_wadsprint.api.stamina(player_name,stamina_rate)
    local player = minetest_wadsprint.players[player_name]
    if player ~= nil then
        if stamina_value ~= nil then
            minetest_wadsprint.set_stamina(player, minetest_wadsprint.STAMINA_MAX_VALUE * stamina_value)
        else
            return player.stamina / minetest_wadsprint.STAMINA_MAX_VALUE
        end
    end  
end

function minetest_wadsprint.api.addstamina(player_name,stamina_rate_change)
    local player = minetest_wadsprint.players[player_name]
    if player ~= nil then
        minetest_wadsprint.set_stamina(player, player.stamina + minetest_wadsprint.STAMINA_MAX_VALUE * stamina_value)
    end  
end

function minetest_wadsprint.stamina_update_cycle(player)
    if player.is_sprinting then
        minetest_wadsprint.set_stamina(player, player.stamina - (minetest_wadsprint.STAMINA_MAX_VALUE * minetest_wadsprint.SPRINT_STAMINA_DECREASE_PER_UPDATE_PERIOD_COEFFICIENT))
    elseif player.stamina < minetest_wadsprint.STAMINA_MAX_VALUE then
        minetest_wadsprint.set_stamina(player, player.stamina + (minetest_wadsprint.STAMINA_MAX_VALUE * minetest_wadsprint.SPRINT_STAMINA_INCREASE_PER_UPDATE_PERIOD_COEFFICIENT))
    end
end

function minetest_wadsprint.set_stamina(player,stamina_value)
    local old_stamina_value = player.stamina
    if stamina_value < 0 then
        minetest_wadsprint.set_sprinting(player,false)
        minetest_wadsprint.set_ready_to_sprint(player,false)
        player.stamina = 0
    elseif stamina_value > minetest_wadsprint.STAMINA_MAX_VALUE then
        player.stamina = minetest_wadsprint.STAMINA_MAX_VALUE
    else
        player.stamina = stamina_value
    end
    if old_stamina_value >= minetest_wadsprint.DYSPNEA_THRESHOLD_VALUE and player.stamina < minetest_wadsprint.DYSPNEA_THRESHOLD_VALUE then
        minetest_wadsprint.api.events:emit(
            "dyspnea",
            {
                player = player,
                value = true,
                name = "dyspnea",
            }
        )
    elseif old_stamina_value < minetest_wadsprint.DYSPNEA_THRESHOLD_VALUE and player.stamina >= minetest_wadsprint.DYSPNEA_THRESHOLD_VALUE then
        minetest_wadsprint.api.events:emit(
            "dyspnea",
            {
                player = player,
                value = false,
                name = "dyspnea",
            }
        )
    end
    minetest_wadsprint.hudbar_update_stamina(player)
end

function minetest_wadsprint.set_sprinting_physics(player,is_on)
    if player.is_sprinting_physics_on ~= is_on then
        local physics = player.obj:get_physics_override()
        if is_on then
            player.obj:set_physics_override(
            {
                jump = physics.jump - 1 + minetest_wadsprint.SPRINT_JUMP_HEIGHT_MODIFIER_COEFFICIENT,
                speed = physics.speed - 1 + minetest_wadsprint.SPRINT_SPEED_MODIFIER_COEFFICIENT,
            })
        else
            if player.is_sprinting_physics_on ~= nil then
                player.obj:set_physics_override(
                {
                    jump = physics.jump + 1 - minetest_wadsprint.SPRINT_JUMP_HEIGHT_MODIFIER_COEFFICIENT,
                    speed = physics.speed + 1 - minetest_wadsprint.SPRINT_SPEED_MODIFIER_COEFFICIENT,
                })
            end
        end
        player.is_sprinting_physics_on = is_on
    end
end

-- If player.is_sprinting that means he is actually moving forward. If player is not moving then he
-- isn't sprinting. `player.is_sprinting` could be nil if the value is not initialized. Nil is not 
-- equal nor to true neither to false.
function minetest_wadsprint.set_sprinting(player,is_sprinting)
    if player.is_sprinting ~= is_sprinting then
        if player.is_sprinting ~= nil then
            if is_sprinting then
                minetest_wadsprint.set_sprinting_physics(player,true)
            else
                if not player.is_ready_to_sprint then
                    minetest_wadsprint.set_sprinting_physics(player,false)
                end
            end
        end
        player.is_sprinting = is_sprinting
        minetest_wadsprint.hudbar_update_ready_to_sprint(player)
        minetest_wadsprint.hudbar_update_stamina(player)
    end
end

-- Main use of this function is to put player in a state when pressing "W" would trigger the 
-- set_sprinting function thus you won't need to hold "A"+"D" to keep sprinting. Also it alters player
-- physics to workaround lag between pressing "W" and actual set_sprinting call. So if player is ready
-- to sprint it is sure that his physics is already in sprinting state and he can not afraid to fall
-- while jumping from a tree to tree just because the lag between pressing "W" and set_sprinting call
-- would be too big. At the same time being only ready to sprint and not actually sprinting does not
-- decreases the stamina because decreasing stamina for nothing is unfair.
function minetest_wadsprint.set_ready_to_sprint(player,is_ready_to_sprint)
    if player.is_ready_to_sprint ~= is_ready_to_sprint then
        if is_ready_to_sprint then
            minetest_wadsprint.set_sprinting_physics(player,true)
        else
            if not player.is_sprinting then
                minetest_wadsprint.set_sprinting_physics(player,false)  
            end
        end
        player.is_ready_to_sprint = is_ready_to_sprint
        minetest_wadsprint.hudbar_update_ready_to_sprint(player)
    end
end

function minetest_wadsprint.scan_player_controls(player)
    local control = player.obj:get_player_control()
    if not control["up"] then
        minetest_wadsprint.set_sprinting(player,false)
    end
    if control["left"] and control["right"] and not control["down"] then
        if player.stamina > minetest_wadsprint.DYSPNEA_THRESHOLD_VALUE then
          minetest_wadsprint.set_ready_to_sprint(player,true)
          if control["up"] then
              minetest_wadsprint.set_sprinting(player,true)
          end
        end
    else
        minetest_wadsprint.set_ready_to_sprint(player,false)
    end
end

function minetest_wadsprint.reset_stamina(player,stamina_value)
    if stamina_value == nil then stamina_value = minetest_wadsprint.STAMINA_MAX_VALUE end
    minetest_wadsprint.set_stamina(player,stamina_value)
    minetest_wadsprint.set_sprinting(player,false)
    minetest_wadsprint.set_ready_to_sprint(player,false)
    return player
end

function minetest_wadsprint.save_players_stats()
    local stats = {}
    local counter = 1
    for key,val in pairs(minetest_wadsprint.players) do
      stats[counter] = { name = key, stamina = val.stamina }
      counter = counter + 1
    end
    for key,val in ipairs(minetest_wadsprint.savedstats) do
      if minetest_wadsprint.players[val.name] == nil then
          stats[counter] = { name = val.name, stamina = val.stamina }
          counter = counter + 1
      end
      if counter == minetest_wadsprint.PLAYERS_STATS_FILE_LIMIT_RECORDS + 1 then
          break
      end
    end
    table.save(stats,minetest_wadsprint.savetablepath)
end

function minetest_wadsprint.load_players_stats()
    if file_exists(minetest_wadsprint.savetablepath) then
         minetest_wadsprint.savedstats = table.load(minetest_wadsprint.savetablepath)
         minetest_wadsprint.savedstats.index = {}
         for key,val in ipairs(minetest_wadsprint.savedstats) do
            minetest_wadsprint.savedstats.index[val.name] = { stamina = val.stamina }
        end
    end
end

minetest.register_on_joinplayer(function(player_obj)
    local player = {}
    local playername = player_obj:get_player_name()
    if minetest_wadsprint.savedstats.index[playername] ~= nil then
        player = minetest_wadsprint.savedstats.index[playername]
    else
        player = { stamina = minetest_wadsprint.STAMINA_MAX_VALUE }
    end
    player.obj = player_obj
    player.name = playername
    minetest_wadsprint.players[playername] = player   
    minetest_wadsprint.initialize_hudbar(player)
    minetest_wadsprint.reset_stamina(player,player.stamina)
    if player.stamina < minetest_wadsprint.DYSPNEA_THRESHOLD_VALUE then
        minetest_wadsprint.api.events:emit(
            "dyspnea",
            {
                player = player,
                value = true,
                name = "dyspnea",
            }
        )
    end
end)

minetest.register_on_respawnplayer(function(player_obj)
  minetest_wadsprint.reset_stamina(minetest_wadsprint.players[player_obj:get_player_name()])
end)

minetest.register_on_leaveplayer(function(player_obj)
    local playername = player_obj:get_player_name()
    local player = minetest_wadsprint.players[playername]
    table.insert(minetest_wadsprint.savedstats, 1, { name = playername, stamina = player.stamina})
    minetest_wadsprint.savedstats.index[playername] = { stamina = player.stamina }
    minetest_wadsprint.players[playername] = nil
end)

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
local timer_stats_update = 0
local timer_controls_check = 0
minetest.register_globalstep(function(dtime)
    timer_stats_update = timer_stats_update + dtime
    timer_controls_check = timer_controls_check + dtime
    if timer_stats_update > minetest_wadsprint.PLAYER_STATS_UPDATE_PERIOD_SECONDS then
        timer_stats_update = 0
        for player_name,player in pairs(minetest_wadsprint.players) do
            minetest_wadsprint.stamina_update_cycle(player)
        end
    end
    if timer_controls_check > minetest_wadsprint.PLAYER_CONTROLS_CHECK_PERIOD_SECONDS then
        timer_controls_check = 0
        for player_name,player in pairs(minetest_wadsprint.players) do
            minetest_wadsprint.scan_player_controls(player)
        end
    end
end)
