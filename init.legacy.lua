function minetest.legacy_hudbars_below_2_0_0()
    local hudbars_readme
    local hudbars_template
    local hudbars_readme_path = minetest.get_modpath("hudbars").."/README.md"
    local hudbars_template_path = minetest.get_modpath("hudbars").."/locale/template.txt"
    if file_exists(hudbars_readme_path) and file_exists(hudbars_template_path) then
        hudbars_readme = file_get_contents(hudbars_readme_path)
        hudbars_template = file_get_contents(hudbars_template_path)
        if string.find(hudbars_readme,"The current version is 1.") and string.find(hudbars_template,"%%s: %%d/%%d") then 
            print(minetest.get_current_modname()..": Hudbars version below 2.0.0 legacy hook applied.")
            minetest_wadsprint.HUDBARS_2_0_0_TEXT_FORMAT = minetest_wadsprint.HUDBARS_TEXT_FORMAT
        end
    end
end