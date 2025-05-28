----------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------- API --
----------------------------------------------------------------------------------------------------
minetest_wadsprint.api = { events = EventEmitter:new() }
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