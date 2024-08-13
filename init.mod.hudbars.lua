function minetest_wadsprint.load_hudbars()
    
    if minetest_wadsprint.HIDE_HUD_BARS == true then

        -- Declare empty functions that do nothing.
        function minetest_wadsprint.initialize_hudbar(player) end
        function minetest_wadsprint.hudbar_update_stamina(player) end
        function minetest_wadsprint.hudbar_update_ready_to_sprint(player) end

    else

        -- @see http://dev.minetest.net/HUD
        function minetest_wadsprint.initialize_hudbar(player)
            player.hud = player.obj:hud_add(
            {
                hud_elem_type = "statbar",                                   -- HUD type. Statbar displays a horizontal bar made up of half-images. 
                size = minetest_wadsprint.MINETESTHUD_ICON_SIZE,             -- `size`: If used will force full-image size to this value (override texture pack image size).
                text = minetest_wadsprint.MINETESTHUD_IS_NOT_SPRINTING_ICON, -- `text`: The name of the texture that is used. 
                number = math.ceil((player.stamina / minetest_wadsprint.STAMINA_MAX_VALUE) * minetest_wadsprint.MINETESTHUD_HALF_ICONS_NUMBER),                                             -- `number`: The number of half-textures that are displayed. If odd, will end with a vertically center-split texture. 
                offset = minetest_wadsprint.MINETESTHUD_OFFSET,              -- `offset`: Specifies a pixel offset from the position. Not scaled to the screen size. Note: offset WILL adapt to screen DPI as well as the user defined scaling factor!
                position = minetest_wadsprint.MINETESTHUD_POSITION,          -- `position`: Used for all element types. To account for differing resolutions, the position coordinates are the percentage of the screen, ranging in value from 0 to 1. 0 means left/top, 1 means right/bottom. 
                alignment = minetest_wadsprint.MINETESTHUD_ALIGNMENT,        -- `alignment`: Specifies how the item will be aligned. It ranges from -1 to 1, with 0 being the center, -1 is moved to the left/up, and 1 is to the right/down. Fractional values can be used.
            })
        end
        function minetest_wadsprint.hudbar_update_stamina(player)
            player.obj:hud_change(player.hud, "number", math.ceil((player.stamina / minetest_wadsprint.STAMINA_MAX_VALUE) * minetest_wadsprint.MINETESTHUD_HALF_ICONS_NUMBER))
        end
        function minetest_wadsprint.hudbar_update_ready_to_sprint(player)
            if player.is_sprinting or player.is_ready_to_sprint then
              player.obj:hud_change(player.hud, "text", minetest_wadsprint.MINETESTHUD_IS_SPRINTING_ICON)
            else
              player.obj:hud_change(player.hud, "text", minetest_wadsprint.MINETESTHUD_IS_NOT_SPRINTING_ICON)
            end
        end
        
    end

end