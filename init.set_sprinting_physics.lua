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
    local default_minetest_wadsprint_initialize_player = minetest_wadsprint.initialize_player
    function minetest_wadsprint.initialize_player(player_obj)
        default_minetest_wadsprint_initialize_player(player_obj)
        minetest_wadsprint.stats[player_obj:get_player_name()].monoids = {}
        minetest_wadsprint.stats[player_obj:get_player_name()].monoids.jump = {}
        minetest_wadsprint.stats[player_obj:get_player_name()].monoids.speed = {}
    end
    function minetest_wadsprint.set_sprinting_physics(player,is_on_val)
        if player.is_sprinting_physics_on ~= is_on_val then
            if is_on_val == true then
                table.insert(
                    player.monoids.jump,
                    player_monoids.jump:add_change(
                        player.obj, 
                        minetest_wadsprint.SPRINT_JUMP_HEIGHT_BOOST_COEFFICIENT, 
                        "minetest_wadsprint:jump"
                    )
                )
                table.insert(
                    player.monoids.speed,
                    player_monoids.speed:add_change(
                        player.obj, 
                        minetest_wadsprint.SPRINT_RUN_SPEED_BOOST_COEFFICIENT, 
                        "minetest_wadsprint:speed"
                    )
                )
            elseif player.is_sprinting_physics_on ~= nil then
                while #player.monoids.jump ~= 0 do
                    player_monoids.jump:del_change(player.obj, table.remove(player.monoids.jump))
                end
                while #player.monoids.speed ~= 0 do
                    player_monoids.speed:del_change(player.obj, table.remove(player.monoids.speed))
                end
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