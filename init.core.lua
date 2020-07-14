----------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------- scan_player_controls() --
----------------------------------------------------------------------------------------------------
function minetest_wadsprint.scan_player_controls(player)
    local controls = player.obj:get_player_control()
    if controls["up"] then 
        if player.is_sprinting then
            return
        elseif player.is_ready_to_sprint then
            minetest_wadsprint.switch_to_sprinting(player)
            return
        end
    end
    if controls["left"] and controls["right"] and not controls["down"] then
        if player.stamina > minetest_wadsprint.DYSPNEA_THRESHOLD_VALUE then
            if controls["up"] then
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
--------------------------------------------------------------------- stamina_update_cycle_tick() --
----------------------------------------------------------------------------------------------------
function minetest_wadsprint.stamina_update_cycle_tick(player)
    if player.is_sprinting then
        minetest_wadsprint.set_stamina(player, player.stamina - 
            (
                minetest_wadsprint.STAMINA_MAX_VALUE * 
                minetest_wadsprint.SPRINT_STAMINA_DECREASE_PER_UPDATE_PERIOD_COEFFICIENT
            )
        )
    else
        if player.stamina < minetest_wadsprint.STAMINA_MAX_VALUE then
            minetest_wadsprint.set_stamina(player, player.stamina + 
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
        player.is_walking = true
        player.is_sprinting = false
        player.is_ready_to_sprint = false
        minetest_wadsprint.set_sprinting_physics(player,false)
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
        player.is_walking = false
        player.is_sprinting = true
        player.is_ready_to_sprint = false
        minetest_wadsprint.set_sprinting_physics(player,true)
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
        player.is_walking = false
        player.is_sprinting = false
        player.is_ready_to_sprint = true
        minetest_wadsprint.set_sprinting_physics(player,true)
        minetest_wadsprint.hudbar_update_ready_to_sprint(player)
        minetest_wadsprint.hudbar_update_stamina(player)
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
---------------------------------------------------------------------------- reset_player_stats() --
----------------------------------------------------------------------------------------------------
function minetest_wadsprint.reset_player_stats(player_obj)
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