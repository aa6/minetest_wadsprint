function minetest_wadsprint.set_sprinting_physics(player,is_on_val)
    if player.is_sprinting_physics_on ~= is_on_val then
        local physics = player.obj:get_physics_override()
        if is_on_val == true then
            player.obj:set_physics_override(
            {
                jump = minetest_wadsprint.SPRINT_JUMP_HEIGHT_BOOST_COEFFICIENT,
                speed = minetest_wadsprint.SPRINT_RUN_SPEED_BOOST_COEFFICIENT,
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