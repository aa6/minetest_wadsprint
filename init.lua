-- WAD SPRINTING minetest (https://minetest.net) mod (https://dev.minetest.net/Intro)
-- @link https://github.com/aa6/minetest_wadsprint
minetest_wadsprint = 
{
    players = {},
}
dofile(minetest.get_modpath(minetest.get_current_modname()).."/config.lua")
dofile(minetest.get_modpath(minetest.get_current_modname()).."/init_hudbars.lua")

function minetest_wadsprint.update_player_properties(player)
    if player.is_sprinting then
        player.stamina = player.stamina - (minetest_wadsprint.STAMINA_MAX_VALUE * minetest_wadsprint.SPRINT_STAMINA_DECREASE_PER_UPDATE_PERIOD_COEFFICIENT)
        if player.stamina < 0 then
            player.stamina = 0
            minetest_wadsprint.disable_sprinting(player)
        end
    elseif player.stamina < minetest_wadsprint.STAMINA_MAX_VALUE then
        player.stamina = player.stamina + (minetest_wadsprint.STAMINA_MAX_VALUE * minetest_wadsprint.SPRINT_STAMINA_INCREASE_PER_UPDATE_PERIOD_COEFFICIENT)
    end
    minetest_wadsprint.hudbar_update_stamina(player)
end

function minetest_wadsprint.enable_sprinting(player)
    if not player.is_sprinting then
        player.is_sprinting = true
        player.obj:set_physics_override(
        {
            jump = minetest_wadsprint.SPRINT_JUMP_HEIGHT_MODIFIER_COEFFICIENT,
            speed = minetest_wadsprint.SPRINT_SPEED_MODIFIER_COEFFICIENT,
        })
        minetest_wadsprint.hudbar_update_ready_to_sprint(player)
        minetest_wadsprint.hudbar_update_stamina(player)
    end
end

function minetest_wadsprint.disable_sprinting(player)
    if player.is_sprinting then
        player.is_sprinting = false
        player.obj:set_physics_override(
        {
            jump = 1.0,
            speed = 1.0,
        })
        minetest_wadsprint.hudbar_update_ready_to_sprint(player)
        minetest_wadsprint.hudbar_update_stamina(player)
    end
end

function minetest_wadsprint.set_ready_to_sprint(player,is_ready_to_sprint)
    if player.is_ready_to_sprint ~= is_ready_to_sprint then
        player.is_ready_to_sprint = is_ready_to_sprint
        minetest_wadsprint.hudbar_update_ready_to_sprint(player)
    else
        player.is_ready_to_sprint = is_ready_to_sprint
    end
end

function minetest_wadsprint.scan_player_controls(player)
    local control = player.obj:get_player_control()
    if not control["up"] then
        minetest_wadsprint.disable_sprinting(player)
    end
    if control["left"] and control["right"] then
        minetest_wadsprint.set_ready_to_sprint(player,true)
        if control["up"] then
            minetest_wadsprint.enable_sprinting(player)
        end
    else
        minetest_wadsprint.set_ready_to_sprint(player,false)
    end
end

minetest.register_on_joinplayer(function(player_obj)
    minetest_wadsprint.players[player_obj:get_player_name()] = 
    { 
        obj = player_obj,
        stamina = minetest_wadsprint.STAMINA_MAX_VALUE,
        is_sprinting = false,
        is_ready_to_sprint = false,
    }
    minetest_wadsprint.initialize_hudbar(minetest_wadsprint.players[player_obj:get_player_name()])
end)

minetest.register_on_leaveplayer(function(player_obj)
    minetest_wadsprint.players[player_obj:get_player_name()] = nil
end)

-- Register hudbar call for compatibility with some hudbar mods.
if minetest_wadsprint.register_hudbar ~= nil then
    minetest_wadsprint.register_hudbar()
end
-- Main cycle.
local timer_controls_check = 0
local timer_properties_update = 0
minetest.register_globalstep(function(dtime)
    timer_controls_check = timer_controls_check + dtime
    timer_properties_update = timer_properties_update + dtime
    if timer_controls_check > minetest_wadsprint.PLAYER_CONTROLS_CHECK_PERIOD_SECONDS then
        timer_controls_check = 0
        for player_name,player in pairs(minetest_wadsprint.players) do
            minetest_wadsprint.scan_player_controls(player)
        end
    end
    if timer_properties_update > minetest_wadsprint.PLAYER_STATS_UPDATE_PERIOD_SECONDS then
        timer_properties_update = 0
        for player_name,player in pairs(minetest_wadsprint.players) do
            minetest_wadsprint.update_player_properties(player)
        end
    end
end)
