function minetest_wadsprint.parse_settingtypes(settingtypes)

    local settings = {}
    
    for line in settingtypes:gmatch("[^\r\n]+") do
        -- Skip empty lines and comments
        if not line:match("^%s*#") and not line:match("^%s*$") then
            -- Match the pattern:
            local modname, name, description, type, default_value 
                = line:match("^([^.]+)%.([^.]+)%s+%(([^)]+)%)%s+(%S+)%s+(.+)$")
            
            if modname and name and description and type and default_value then
                settings[modname.."."..name] = {
                    modname = modname,
                    name = name,
                    type = type,
                    default_value = default_value,
                    description = description
                }
            end
        end
    end
    
    return settings
    
end
