if minetest.get_modpath("hud") ~= nil and minetest_wadsprint.HIDE_HUD_BARS ~= true then 

    -- @see https://github.com/BlockMen/hud_hunger/blob/master/API.txt
    function minetest_wadsprint.register_hudbar()
        hud.register(
            minetest_wadsprint.HUDHUNGER_BAR_NAME,
            {
                hud_elem_type = "statbar",                               -- currently only supported type (same as in lua-api.txt)
                max = minetest_wadsprint.HUDHUNGER_HALF_ICONS_NUMBER,    -- used to prevent "overflow" of statbars
                size = minetest_wadsprint.HUDHUNGER_ICON_SIZE,           -- statbar texture size (default 24x24), needed to be scaled correctly
                text = minetest_wadsprint.HUDBARS_IS_NOT_SPRINTING_ICON, -- texture name (same as in lua-api.txt)
                offset = minetest_wadsprint.HUDHUNGER_OFFSET,
                number = minetest_wadsprint.HUDHUNGER_HALF_ICONS_NUMBER, -- number/2 = number of full textures(e.g. hearts)
                position = minetest_wadsprint.HUDHUNGER_POSITION,        -- position of statbar (same as in lua-api.txt)
                alignment = minetest_wadsprint.HUDHUNGER_ALIGNMENT,      -- alignment on screen (same as in lua-api.txt)
                background = nil,                                        -- statbar background texture name
                autohide_bg = false,                                     -- hide statbar background textures when number = 0
                events = {},                                             -- called on events "damage" and "breath_changed" of players
            }
        )
    end
    function minetest_wadsprint.initialize_hudbar(player)
        minetest_wadsprint.hudbar_update_stamina(player)
    end
    function minetest_wadsprint.hudbar_update_ready_to_sprint(player)
        if player.is_sprinting or player.is_ready_to_sprint then
            hud.change_item(
                player.obj,
                minetest_wadsprint.HUDHUNGER_BAR_NAME,
                {
                    text = minetest_wadsprint.HUDHUNGER_IS_SPRINTING_ICON,
                }
            )
        else
            hud.change_item(
                player.obj,
                minetest_wadsprint.HUDHUNGER_BAR_NAME,
                {
                    text = minetest_wadsprint.HUDBARS_IS_NOT_SPRINTING_ICON,
                }
            )
        end
    end
    function minetest_wadsprint.hudbar_update_stamina(player)
        hud.change_item(
            player.obj,
            minetest_wadsprint.HUDHUNGER_BAR_NAME,
            {
                number = 0, -- Workaround for some obscure bug.
            }
        )
        hud.change_item(
            player.obj,
            minetest_wadsprint.HUDHUNGER_BAR_NAME,
            {
                number = math.ceil((player.stamina / minetest_wadsprint.STAMINA_MAX_VALUE) * minetest_wadsprint.HUDHUNGER_HALF_ICONS_NUMBER),
            }
        )
    end
end