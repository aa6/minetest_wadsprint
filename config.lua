-- Common config values
minetest_wadsprint.STAMINA_MAX_VALUE                                     = 100
minetest_wadsprint.PLAYER_STATS_UPDATE_PERIOD_SECONDS                    = 1
minetest_wadsprint.PLAYER_CONTROLS_CHECK_PERIOD_SECONDS                  = 0.2
minetest_wadsprint.SPRINT_SPEED_MODIFIER_COEFFICIENT                     = 3.8
minetest_wadsprint.SPRINT_JUMP_HEIGHT_MODIFIER_COEFFICIENT               = 1.1
minetest_wadsprint.SPRINT_STAMINA_DECREASE_PER_UPDATE_PERIOD_COEFFICIENT = 0.01  -- 1 means 100% decrease
minetest_wadsprint.SPRINT_STAMINA_INCREASE_PER_UPDATE_PERIOD_COEFFICIENT = 0.001 -- 1 means 100% increase
-- Config values for `hudbars` mod (totally optional, applied only if installed).
-- @see http://repo.or.cz/minetest_hudbars.git/blob_plain/HEAD:/API.md
minetest_wadsprint.HUDBARS_IDENTIFIER            = "sprint"
minetest_wadsprint.HUDBARS_TEXT_COLOR            = 0xFFFFFF
minetest_wadsprint.HUDBARS_TEXT_LABEL            = "Stamina"
minetest_wadsprint.HUDBARS_TEXT_FORMAT           = "%s: %d/%d"
minetest_wadsprint.HUDBARS_BACKGROUND_ICON       = nil
minetest_wadsprint.HUDBARS_PROGRESSBAR_IMAGE     = "minetest_wadsprint_hudbars_progressbar.png"
minetest_wadsprint.HUDBARS_IS_SPRINTING_ICON     = "minetest_wadsprint_is_sprinting_icon.png"
minetest_wadsprint.HUDBARS_IS_NOT_SPRINTING_ICON = "minetest_wadsprint_is_not_sprinting_icon.png" -- Unsupported yet.
-- Config values for `hud_hunger` mod (totally optional, applied only if installed).
-- @see https://github.com/BlockMen/hud_hunger/blob/master/API.txt
minetest_wadsprint.HUDHUNGER_BAR_NAME              = "sprint"
minetest_wadsprint.HUDHUNGER_OFFSET                = { x = -261, y = -110 }
minetest_wadsprint.HUDHUNGER_POSITION              = { x = 0.5, y = 1 }
minetest_wadsprint.HUDHUNGER_ICON_SIZE             = { x = 24, y = 24 }
minetest_wadsprint.HUDHUNGER_ALIGNMENT             = { x = 0, y = 1 }
minetest_wadsprint.HUDHUNGER_HALF_ICONS_NUMBER     = 20
minetest_wadsprint.HUDHUNGER_IS_SPRINTING_ICON     = "minetest_wadsprint_is_sprinting_icon.png"
minetest_wadsprint.HUDHUNGER_IS_NOT_SPRINTING_ICON = "minetest_wadsprint_is_not_sprinting_icon.png"
-- Config values for default minetest HUD interface (no mods).
-- @see http://dev.minetest.net/HUD
minetest_wadsprint.MINETESTHUD_OFFSET                = { x = -263, y = -110 }
minetest_wadsprint.MINETESTHUD_POSITION              = { x = 0.5, y = 1 }
minetest_wadsprint.MINETESTHUD_ICON_SIZE             = { x = 24, y = 24 }
minetest_wadsprint.MINETESTHUD_ALIGNMENT             = { x = 0, y = 1 }
minetest_wadsprint.MINETESTHUD_HALF_ICONS_NUMBER     = 20
minetest_wadsprint.MINETESTHUD_IS_SPRINTING_ICON     = "minetest_wadsprint_is_sprinting_icon.png"
minetest_wadsprint.MINETESTHUD_IS_NOT_SPRINTING_ICON = "minetest_wadsprint_is_not_sprinting_icon.png"