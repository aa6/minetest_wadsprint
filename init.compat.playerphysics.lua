if minetest.get_modpath("playerphysics") ~= nil then 

    function minetest_wadsprint.set_sprinting_physics(player,is_on_val)
        if player.is_sprinting_physics_on ~= is_on_val then
            if is_on_val == true then
                playerphysics.add_physics_factor(
                    player.obj, "speed", "minetest_wadsprint_speed_boost",
                    minetest_wadsprint.SPRINT_RUN_SPEED_BOOST_COEFFICIENT
                )
                playerphysics.add_physics_factor(
                    player.obj, "jump", "minetest_wadsprint_jump_boost",
                    minetest_wadsprint.SPRINT_JUMP_HEIGHT_BOOST_COEFFICIENT
                )
            elseif player.is_sprinting_physics_on ~= nil then
                playerphysics.remove_physics_factor(
                    player.obj, "speed", "minetest_wadsprint_speed_boost"
                )
                playerphysics.remove_physics_factor(
                    player.obj, "jump", "minetest_wadsprint_jump_boost"
                )
            end
            player.is_sprinting_physics_on = is_on_val
        end
    end
    
end
