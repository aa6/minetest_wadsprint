-- Loading global config.
dofile(minetest.get_modpath(minetest.get_current_modname()).."/config.lua")

-- Processing in-game settings. In-game settings are preferrable
-- over global config.lua values.
function minetest_wadsprint.load_minetest_settings_key(key,type)
  if type == "int" then
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
  print("In-game minetest settings are enabled. Loading them.")
  minetest_wadsprint.load_minetest_settings_key("HIDE_HUD_BARS","bool")
  minetest_wadsprint.load_minetest_settings_key("STAMINA_MAX_VALUE","int")
  minetest_wadsprint.load_minetest_settings_key("DYSPNEA_THRESHOLD_VALUE","int")
  minetest_wadsprint.load_minetest_settings_key("SAVE_PLAYERS_STATS_TO_FILE","bool")
  minetest_wadsprint.load_minetest_settings_key("PLAYERS_STATS_FILE_LIMIT_RECORDS","int")
  minetest_wadsprint.load_minetest_settings_key("PLAYER_STATS_UPDATE_PERIOD_SECONDS","int")
  minetest_wadsprint.load_minetest_settings_key("PLAYER_CONTROLS_CHECK_PERIOD_SECONDS","int")
  minetest_wadsprint.load_minetest_settings_key("SPRINT_RUN_SPEED_BOOST_COEFFICIENT","int")
  minetest_wadsprint.load_minetest_settings_key("SPRINT_JUMP_HEIGHT_BOOST_COEFFICIENT","int")
  minetest_wadsprint.load_minetest_settings_key("SPRINT_STAMINA_DECREASE_PER_SECOND_PERCENTS","int")
  minetest_wadsprint.load_minetest_settings_key("SPRINT_STAMINA_INCREASE_PER_SECOND_PERCENTS","int")
else
  print("In-game minetest settings are disabled. Ignoring them.")
end

-- Processing world-specific config. World-specific values are preferrable 
-- over both global config and in-game settings.
if file_exists(minetest_wadsprint.worldconfig) then 
  print("Loading minetest_wadsprint world-specific config: "..minetest_wadsprint.worldconfig)
  dofile(minetest_wadsprint.worldconfig)
else
  print("Creating minetest_wadsprint world-specific config: "..minetest_wadsprint.worldconfig)
  file_put_contents(
    minetest_wadsprint.worldconfig,
    "-- World-specific config. Copy here values from `mods/minetest_wadsprint/config.lua`:\n"
  )
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