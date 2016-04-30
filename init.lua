-- WAD SPRINTING minetest (https://minetest.net) mod (https://dev.minetest.net/Intro)
-- @link https://github.com/aa6/minetest_wadsprint
minetest_wadsprint = 
{
    version = "0.2.0"
    players = {},
}
dofile(minetest.get_modpath(minetest.get_current_modname()).."/config.lua")
dofile(minetest.get_modpath(minetest.get_current_modname()).."/init_hudbars.lua")

function minetest_wadsprint.stamina_update_cycle(player)
    if player.is_sprinting then
        player.stamina = player.stamina - (minetest_wadsprint.STAMINA_MAX_VALUE * minetest_wadsprint.SPRINT_STAMINA_DECREASE_PER_UPDATE_PERIOD_COEFFICIENT)
        if player.stamina < 0 then
            player.stamina = 0
            minetest_wadsprint.set_sprinting(player,false)
        end
    elseif player.stamina < minetest_wadsprint.STAMINA_MAX_VALUE then
        player.stamina = player.stamina + (minetest_wadsprint.STAMINA_MAX_VALUE * minetest_wadsprint.SPRINT_STAMINA_INCREASE_PER_UPDATE_PERIOD_COEFFICIENT)
        if player.stamina > minetest_wadsprint.STAMINA_MAX_VALUE then
            player.stamina = minetest_wadsprint.STAMINA_MAX_VALUE
        end
    end
    minetest_wadsprint.hudbar_update_stamina(player)
end

function minetest_wadsprint.set_sprinting(player,is_sprinting)
    if player.is_sprinting ~= is_sprinting then
        if player.is_sprinting ~= nil then
            local physics = player.obj:get_physics_override()
            print(minetest_wadsprint.version)
            if is_sprinting then
                player.obj:set_physics_override(
                {
                    jump = physics.jump - 1 + minetest_wadsprint.SPRINT_JUMP_HEIGHT_MODIFIER_COEFFICIENT,
                    speed = physics.speed - 1 + minetest_wadsprint.SPRINT_SPEED_MODIFIER_COEFFICIENT,
                })
            else
                player.obj:set_physics_override(
                {
                    jump = physics.jump + 1 - minetest_wadsprint.SPRINT_JUMP_HEIGHT_MODIFIER_COEFFICIENT,
                    speed = physics.speed + 1 - minetest_wadsprint.SPRINT_SPEED_MODIFIER_COEFFICIENT,
                })
            end
        end
        player.is_sprinting = is_sprinting
        minetest_wadsprint.hudbar_update_ready_to_sprint(player)
        minetest_wadsprint.hudbar_update_stamina(player)
    end
end

function minetest_wadsprint.set_ready_to_sprint(player,is_ready_to_sprint)
    if player.is_ready_to_sprint ~= is_ready_to_sprint then
        player.is_ready_to_sprint = is_ready_to_sprint
        minetest_wadsprint.hudbar_update_ready_to_sprint(player)
    end
end

function minetest_wadsprint.scan_player_controls(player)
    local control = player.obj:get_player_control()
    if not control["up"] then
        minetest_wadsprint.set_sprinting(player,false)
    end
    if control["left"] and control["right"] then
        minetest_wadsprint.set_ready_to_sprint(player,true)
        if control["up"] then
            minetest_wadsprint.set_sprinting(player,true)
        end
    else
        minetest_wadsprint.set_ready_to_sprint(player,false)
    end
end

function minetest_wadsprint.reset_stamina(player)
    player.stamina = minetest_wadsprint.STAMINA_MAX_VALUE
    minetest_wadsprint.set_sprinting(player,false)
    minetest_wadsprint.set_ready_to_sprint(player,false)
    return player
end

minetest.register_on_joinplayer(function(player_obj)
    local player = 
    { 
        obj = player_obj,
    }
    minetest_wadsprint.players[player_obj:get_player_name()] = player   
    minetest_wadsprint.initialize_hudbar(player)
    minetest_wadsprint.reset_stamina(player)
end)

minetest.register_on_respawnplayer(function(player_obj)
  minetest_wadsprint.reset_stamina(minetest_wadsprint.players[player_obj:get_player_name()])
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
            minetest_wadsprint.stamina_update_cycle(player)
        end
    end
end)
