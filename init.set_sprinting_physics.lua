if minetest_wadsprint.BAD_PHYSICS_OVERRIDE_MODE == true then

    function minetest_wadsprint.set_sprinting_physics(player,is_on_val)
        if player.is_sprinting_physics_on ~= is_on_val then
            local physics = player.obj:get_physics_override()
            if is_on_val == true then
                player.obj:set_physics_override(
                {
                    jump = (round(physics.jump,0.01) - 1 + minetest_wadsprint.SPRINT_JUMP_HEIGHT_BOOST_COEFFICIENT),
                    speed = (round(physics.speed,0.01) - 1 + minetest_wadsprint.SPRINT_RUN_SPEED_BOOST_COEFFICIENT),
                })
            elseif player.is_sprinting_physics_on ~= nil then
                player.obj:set_physics_override(
                {
                    jump = 1,
                    speed = 1,
                })
            end
            player.is_sprinting_physics_on = is_on_val
        end
    end

elseif minetest.get_modpath("player_monoids") ~= nil then 

    function minetest_wadsprint.set_sprinting_physics(player,is_on_val)
        if player.is_sprinting_physics_on ~= is_on_val then
            if is_on_val == true then
                player_monoids.jump:add_change(
                    player.obj, 
                    minetest_wadsprint.SPRINT_JUMP_HEIGHT_BOOST_COEFFICIENT, 
                    "minetest_wadsprint:jump"
                )
                player_monoids.speed:add_change(
                    player.obj, 
                    minetest_wadsprint.SPRINT_RUN_SPEED_BOOST_COEFFICIENT, 
                    "minetest_wadsprint:speed"
                )
            elseif player.is_sprinting_physics_on ~= nil then
                player_monoids.jump:del_change(player.obj, "minetest_wadsprint:jump")
                player_monoids.speed:del_change(player.obj, "minetest_wadsprint:speed")
            end
            player.is_sprinting_physics_on = is_on_val
        end
    end

else

    function minetest_wadsprint.set_sprinting_physics(player,is_on_val)
        if player.is_sprinting_physics_on ~= is_on_val then
            local physics = player.obj:get_physics_override()
            if is_on_val == true then
                player.obj:set_physics_override(
                {
                    jump = (round(physics.jump,0.01) - 1 + minetest_wadsprint.SPRINT_JUMP_HEIGHT_BOOST_COEFFICIENT),
                    speed = (round(physics.speed,0.01) - 1 + minetest_wadsprint.SPRINT_RUN_SPEED_BOOST_COEFFICIENT),
                })
            elseif player.is_sprinting_physics_on ~= nil then
                player.obj:set_physics_override(
                {
                    jump = (round(physics.jump,0.01) + 1 - minetest_wadsprint.SPRINT_JUMP_HEIGHT_BOOST_COEFFICIENT),
                    speed = (round(physics.speed,0.01) + 1 - minetest_wadsprint.SPRINT_RUN_SPEED_BOOST_COEFFICIENT),
                })
            end
            player.is_sprinting_physics_on = is_on_val
        end
    end
    
end