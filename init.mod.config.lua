function minetest_wadsprint.load_config()
    -- Loading global config.
    dofile(minetest.get_modpath(minetest.get_current_modname()).."/config.lua")

    -- Processing in-game settings. In-game settings are preferrable
    -- over global config.lua values.
    -- Warning: minetest.settings:get() and minetest.settings:get_bool() 
    -- return `nil` value when not set, instead of actual default value.
    function minetest_wadsprint.load_minetest_settings_key(key,type)
        if type == "int" or type == "float" then
            if minetest.settings:get("minetest_wadsprint."..key) ~= nil then
                minetest_wadsprint[key] = tonumber(minetest.settings:get("minetest_wadsprint."..key))
            end
        elseif type == "bool" then
            if minetest.settings:get_bool("minetest_wadsprint."..key) ~= nil then
                minetest_wadsprint[key] = minetest.settings:get_bool("minetest_wadsprint."..key)
            end
        end
    end
    minetest_wadsprint.load_minetest_settings_key("ENABLE_INGAME_SETTINGS","bool")
    if minetest_wadsprint.ENABLE_INGAME_SETTINGS == true then
        minetest_wadsprint.log("In-game minetest settings are enabled. Loading them.")
        local settings = minetest_wadsprint.parse_settingtypes(
            file_get_contents(
                minetest.get_modpath(minetest.get_current_modname()).."/settingtypes.txt"
            )
        )
        for setting_name, setting in pairs(settings) do
            minetest_wadsprint.load_minetest_settings_key(setting.name,setting.type)
        end
    else
        minetest_wadsprint.log("In-game minetest settings are disabled. Ignoring them.")
    end

    -- Processing world-specific config. World-specific values are preferrable 
    -- over both global config and in-game settings.
    if file_exists(minetest_wadsprint.worldconfig) then 
        minetest_wadsprint.log("Loading minetest_wadsprint world-specific config: "..minetest_wadsprint.worldconfig)
        dofile(minetest_wadsprint.worldconfig)
    else
        minetest_wadsprint.log("Creating minetest_wadsprint world-specific config: "..minetest_wadsprint.worldconfig)
        local new_world_config_contents = 
            "-- World-specific config. Values are taken from `mods/minetest_wadsprint/config.lua`:\n"..
            "-- Please uncomment lines of your need and set the desired value.\n"
        for line in string.gmatch(file_get_contents(minetest.get_modpath(minetest.get_current_modname()).."/config.lua"), "[^\r\n]+") do
            if string.sub(line,0,19) == "minetest_wadsprint." then
                new_world_config_contents = new_world_config_contents.."-- "..line.."\n"
            end
        end
        file_put_contents(minetest_wadsprint.worldconfig,new_world_config_contents)
    end

    -- Processing some config values to avoid further unnecessary calculations.
    minetest_wadsprint.SPRINT_RUN_SPEED_BOOST_COEFFICIENT = (
        minetest_wadsprint.SPRINT_RUN_SPEED_BOOST_PERCENTS / 100
    )
    minetest_wadsprint.SPRINT_JUMP_HEIGHT_BOOST_COEFFICIENT = (
        minetest_wadsprint.SPRINT_JUMP_HEIGHT_BOOST_PERCENTS / 100
    )
    minetest_wadsprint.SPRINT_STAMINA_DECREASE_PER_UPDATE_PERIOD_COEFFICIENT = (
        minetest_wadsprint.PLAYER_STATS_UPDATE_PERIOD_SECONDS * 
        ( minetest_wadsprint.SPRINT_STAMINA_DECREASE_PER_SECOND_PERCENTS / 100 )
    )
    minetest_wadsprint.SPRINT_STAMINA_INCREASE_PER_UPDATE_PERIOD_COEFFICIENT = (
        minetest_wadsprint.PLAYER_STATS_UPDATE_PERIOD_SECONDS * 
        ( minetest_wadsprint.SPRINT_STAMINA_INCREASE_PER_SECOND_PERCENTS / 100 )
    )
end