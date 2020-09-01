if minetest.registered_nodes["farming:coffee_cup"] then
    minetest.override_item("farming:coffee_cup", {
        on_use = function(itemstack, user, pointed_thing)
            if user == nil then return end -- better save then sorry
            minetest_wadsprint.api.addstamina(user:get_player_name(), 0.25)
            itemstack:take_item()
            local leftover = user:get_inventory():add_item("main", "vessels:drinking_glass")
            if not leftover:is_empty() then -- no free spot in players inventory
                minetest.item_drop(leftover, user, user:get_pos())
            end
            return itemstack
        end
    })
end
