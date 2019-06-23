if minetest_wadsprint.HIDE_HUD_BARS == true then

    function minetest_wadsprint.initialize_hudbar(player) end
    function minetest_wadsprint.hudbar_update_stamina(player) end
    function minetest_wadsprint.hudbar_update_ready_to_sprint(player) end

elseif minetest.get_modpath("hudbars") ~= nil then 

    -- @see http://repo.or.cz/minetest_hudbars.git/blob_plain/HEAD:/API.md
    function minetest_wadsprint.register_hudbar()
        -- This function registers a new custom HUD bar definition to the HUD bars mod, so it can be later used to be displayed, changed, hidden and unhidden on a per-player basis. Note this does not yet display the HUD bar.
        -- The HUD bars will be displayed in a “first come, first serve” order. This mod does not allow fow a custom order or a way to set it manually in a reliable way.
        hb.register_hudbar(
            minetest_wadsprint.HUDBARS_IDENTIFIER, -- `identifier`: A globally unique internal name for the HUD bar, will be used later to refer to it. Please only rely on alphanumeric characters for now. The identifiers “`health`” and “`breath`” are used internally for the built-in health and breath bar, respectively. Please do not use these names.
            minetest_wadsprint.HUDBARS_TEXT_COLOR, -- `text_color`: A 3-octet number defining the color of the text. The octets denote, in this order red, green and blue and range from `0x00` (complete lack of this component) to `0xFF` (full intensity of this component). Example: `0xFFFFFF` for white.
            minetest_wadsprint.HUDBARS_TEXT_LABEL, -- `label`: A string which is displayed on the HUD bar itself to describe the HUD bar. Try to keep this string short.
            {                                      -- `textures`: A table with the following fields:
                bar = minetest_wadsprint.HUDBARS_PROGRESSBAR_NOT_SPRINTING_IMAGE, -- `bar`: The file name of the bar image (as string). This is only used for the `progress_bar` bar type (see `README.txt`, settings section). The image for the bar will be repeated horizontally to denote the “value” of the HUD bar. It **must** be of size 2×16. If neccessary, the image will be split vertically in half, and only the left half of the image is displayed. So the final HUD bar will always be displayed on a per-pixel basis. The default bar images are single-colored, but you can use other styles as well, for instance, a vertical gradient.
                icon = minetest_wadsprint.HUDBARS_IS_NOT_SPRINTING_ICON,          -- `icon`: The file name of the icon, as string. For the `progress_bar` type, it is shown as single image left of the bar, for the two statbar bar types, it is used as the statbar icon and will be repeated. This field can be `nil`, in which case no icon will be used, but this is not recommended, because the HUD bar will be invisible if the one of the statbar bar types is used. Icon is a 16×16 image shown left of the HUD bar. This is optional.
                bgicon = minetest_wadsprint.HUDBARS_BACKGROUND_ICON,              -- `bgicon`: The file name of the background icon, it is used as the background for the modern statbar mode only. This field can be `nil`, in which case no background icon will be displayed in this mode. 
            },
            minetest_wadsprint.STAMINA_MAX_VALUE,  -- `default_start_value`: If this HUD bar is added to a player, and no initial value is specified, this value will be used as initial current value.
            minetest_wadsprint.STAMINA_MAX_VALUE,  -- `default_max_value`: If this HUD bar is added to a player, and no initial maximum value is specified, this value will be used as initial maximum value.
            false,                                 -- `default_start_hidden`: The HUD bar will be initially start hidden by default when added to a player. Use `hb.unhide_hudbar` to unhide it.
            minetest_wadsprint.HUDBARS_TEXT_FORMAT -- `format_string`: This is optional; You can specify an alternative format string display the final text on the HUD bar. The default format string is “`%s: %d/%d`” (in this order: Label, current value, maximum value). See also the Lua documentation of `string.format`.
        )
    end
    function minetest_wadsprint.initialize_hudbar(player)
        -- After a HUD bar has been registered, they are not yet displayed yet for any player. HUD bars must be explicitly initialized on a per-player basis. You probably want to do this in the `minetest.register_on_joinplayer`.
        -- This function initialzes and activates a previously registered HUD bar and assigns it to a certain client/player. This has only to be done once per player and after that, you can change the values using `hb.change_hudbar`. However, if `start_hidden` was set to `true` for the HUD bar (in `hb.register_hudbar`), the HUD bar will initially be hidden, but the HUD elements are still sent to the client. Otherwise, the HUD bar will be initially be shown to the player.
        hb.init_hudbar(
            player.obj,                            -- `player`: `ObjectRef` of the player to which the new HUD bar should be displayed to.
            minetest_wadsprint.HUDBARS_IDENTIFIER, -- `identifier`: The identifier of the HUD bar type, as specified in `hb.register_hudbar`.
            math.ceil(player.stamina),             -- `start_value`: The initial current value of the HUD bar. This is optional, `default_start_value` of the registration function will be used, if this is `nil`.
            nil,                                   -- `start_max`: The initial maximum value of the HUD bar. This is optional, `default_start_max` of the registration function will be used, if this is `nil`
            nil                                    -- `start_hidden`: Whether the HUD bar is initially hidden. This is optional, `default_start_hidden` of the registration function will be used as default.
        )
    end
    function minetest_wadsprint.hudbar_update_ready_to_sprint(player)
        if player.is_sprinting then
            hb.change_hudbar(
                player.obj,                                             -- `player`: `ObjectRef` of the player to which the new HUD bar should be displayed to.
                minetest_wadsprint.HUDBARS_IDENTIFIER,                  -- `identifier`: The identifier of the HUD bar type, as specified in `hb.register_hudbar`.
                nil,                                                    -- `new_value`: The new current value of the HUD bar.
                nil,                                                    -- `new_max_value`: The new maximum value of the HUD bar.
                minetest_wadsprint.HUDBARS_IS_SPRINTING_ICON,           -- `new_icon`: File name of the new icon.
                nil,                                                    -- `new_bgicon`: File name of the new background icon for the modern-style statbar.
                minetest_wadsprint.HUDBARS_PROGRESSBAR_SPRINTING_IMAGE, -- `new_bar`: File name of the new bar segment image.
                nil,                                                    -- `new_label`: A new text label of the HUD bar. Note the format string still applies.
                nil                                                     -- `new_text_color`: A 3-octet number defining the new color of the text.
            )
        elseif player.is_ready_to_sprint then
            hb.change_hudbar(
                player.obj,                                             -- `player`: `ObjectRef` of the player to which the new HUD bar should be displayed to.
                minetest_wadsprint.HUDBARS_IDENTIFIER,                  -- `identifier`: The identifier of the HUD bar type, as specified in `hb.register_hudbar`.
                nil,                                                    -- `new_value`: The new current value of the HUD bar.
                nil,                                                    -- `new_max_value`: The new maximum value of the HUD bar.
                minetest_wadsprint.HUDBARS_IS_NOT_SPRINTING_ICON,       -- `new_icon`: File name of the new icon.
                nil,                                                    -- `new_bgicon`: File name of the new background icon for the modern-style statbar.
                minetest_wadsprint.HUDBARS_PROGRESSBAR_SPRINTING_IMAGE, -- `new_bar`: File name of the new bar segment image.
                nil,                                                    -- `new_label`: A new text label of the HUD bar. Note the format string still applies.
                nil                                                     -- `new_text_color`: A 3-octet number defining the new color of the text.
            )
        else
            hb.change_hudbar(
                player.obj,                                                 -- `player`: `ObjectRef` of the player to which the new HUD bar should be displayed to.
                minetest_wadsprint.HUDBARS_IDENTIFIER,                      -- `identifier`: The identifier of the HUD bar type, as specified in `hb.register_hudbar`.
                nil,                                                        -- `new_value`: The new current value of the HUD bar.
                nil,                                                        -- `new_max_value`: The new maximum value of the HUD bar.
                minetest_wadsprint.HUDBARS_IS_NOT_SPRINTING_ICON,           -- `new_icon`: File name of the new icon.
                nil,                                                        -- `new_bgicon`: File name of the new background icon for the modern-style statbar.
                minetest_wadsprint.HUDBARS_PROGRESSBAR_NOT_SPRINTING_IMAGE, -- `new_bar`: File name of the new bar segment image.
                nil,                                                        -- `new_label`: A new text label of the HUD bar. Note the format string still applies.
                nil                                                         -- `new_text_color`: A 3-octet number defining the new color of the text.
            )
        end
    end
    function minetest_wadsprint.hudbar_update_stamina(player)
        -- After a HUD bar has been added, you can change the current and maximum value on a per-player basis. You use the function `hb.change_hudbar` for this. It changes the values of an initialized HUD bar for a certain player. `new_value` and `new_max_value` can be `nil`; if one of them is `nil`, that means the value is unchanged. If both values are `nil`, this function is a no-op. This function also tries minimize the amount of calls to `hud_change` of the Minetest Lua API, and therefore, network traffic. `hud_change` is only called if it is actually needed, i.e. when the actual length of the bar or the displayed string changed, so you do not have to worry about it.
        hb.change_hudbar(
            player.obj,                            -- `player`: `ObjectRef` of the player to which the HUD bar belongs to
            minetest_wadsprint.HUDBARS_IDENTIFIER, -- `identifier`: The identifier of the HUD bar type to change, as specified in `hb.register_hudbar`.
            math.ceil(player.stamina),             -- `new_value`: The new current value of the HUD bar
            minetest_wadsprint.STAMINA_MAX_VALUE   -- `new_max_value`: The new maximum value of the HUD bar
        )
    end

elseif minetest.get_modpath("hud") ~= nil then 

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