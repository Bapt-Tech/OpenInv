-- init.lua
minetest.register_privilege("openinv" {
    description = "Allows player to open other players' inventories.",
    give_to_singleplayer = false,
})

minetest.register_privilege("openec" {
    description = "Allows player to open other players' Ender Chests.",
    give_to_singleplayer = false,
})

-- Function to open player inventory
local function open_player_inventory(name, param)
    if not minetest.check_player_privs(name, {openinv = true}) then
        return false, "You don't have permission to use this command"
    end

    local target_player = minetest.get_player_by_name(param)
    if not target_player then
        return false, "Player not found"
    end

    local target_inv = target_player:get_inventory()
    local formspec = "size[8,9]" ..
                     "label[0,0;"..param.."'s inventory]" ..
                     "list[detached:"..param.."_inv;main;0,0.5;8,4;]" ..
                     "label[0,4.5;Your inventory]" ..
                     "list[current_player;main;0,5;8,4;]"

    local detached_inv = minetest.create_detached_inventory(param.."_inv", {
        allow_move = function(_, _, _, _, _, count, _)
            return count
        end,
        allow_put = function(_, _, _, stack, _)
            return stack:get_count()
        end,
        allow_take = function(_, _, _, stack, _)
            return stack:get_count()
        end,
        on_put = function(inv, listname, index, stack, _)
            local target_inv = minetest.get_player_by_name(param):get_inventory()
            target_inv:set_stack("main", index, stack)
        end,
        on_take = function(inv, listname, index, stack, _)
            local target_inv = minetest.get_player_by_name(param):get_inventory()
            target_inv:set_stack("main", index, inv:get_stack("main", index))
        end,
        on_move = function(inv, from_list, from_index, to_list, to_index, count, _)
            local target_inv = minetest.get_player_by_name(param):get_inventory()
            local from_stack = inv:get_stack(from_list, from_index)
            local to_stack = inv:get_stack(to_list, to_index)
            local taken_stack = from_stack:take_item(count)
            to_stack:add_item(taken_stack)
            inv:set_stack(from_list, from_index, from_stack)
            inv:set_stack(to_list, to_index, to_stack)
            target_inv:set_stack(from_list, from_index, from_stack)
            target_inv:set_stack(to_list, to_index, to_stack)
        end,
    })

    detached_inv:set_size("main", target_inv:get_size("main"))
    detached_inv:set_list("main", target_inv:get_list("main"))

    minetest.show_formspec(name, "openinvmod:player_inventory", formspec)
    return true
end

-- Function to open player Ender Chest
local function open_player_enderchest(name, param)
    if not minetest.check_player_privs(name, {openec = true}) then
        return false, "You don't have permission to use this command"
    end

    local target_player = minetest.get_player_by_name(param)
    if not target_player then
        return false, "Player not found"
    end

    local target_inv = target_player:get_inventory()
    local ec_list = target_inv:get_list("enderchest")
    if not ec_list then
        return false, "Player does not have an Ender Chest inventory"
    end

    local formspec = "size[8,9]" ..
                     "label[0,0;"..param.."'s enderchest]" ..
                     "list[detached:"..param.."_ec;main;0,0.5;8,3;]" ..
                     "label[0,4.5;Your inventory]" ..
                     "list[current_player;main;0,5;8,4;]"

    local detached_ec = minetest.create_detached_inventory(param.."_ec", {
        allow_move = function(_, _, _, _, _, count, _)
            return count
        end,
        allow_put = function(_, _, _, stack, _)
            return stack:get_count()
        end,
        allow_take = function(_, _, _, stack, _)
            return stack:get_count()
        end,
        on_put = function(inv, listname, index, stack, _)
            local target_inv = minetest.get_player_by_name(param):get_inventory()
            target_inv:set_stack("enderchest", index, stack)
        end,
        on_take = function(inv, listname, index, stack, _)
            local target_inv = minetest.get_player_by_name(param):get_inventory()
            target_inv:set_stack("enderchest", index, inv:get_stack("main", index))
        end,
        on_move = function(inv, from_list, from_index, to_list, to_index, count, _)
            local target_inv = minetest.get_player_by_name(param):get_inventory()
            local from_stack = inv:get_stack(from_list, from_index)
            local to_stack = inv:get_stack(to_list, to_index)
            local taken_stack = from_stack:take_item(count)
            to_stack:add_item(taken_stack)
            inv:set_stack(from_list, from_index, from_stack)
            inv:set_stack(to_list, to_index, to_stack)
            target_inv:set_stack("enderchest", from_index, from_stack)
            target_inv:set_stack(to_list, to_index, to_stack)
        end,
    })

    detached_ec:set_size("main", #ec_list)
    detached_ec:set_list("main", ec_list)

    minetest.show_formspec(name, "openinvmod:enderchest", formspec)
    return true
end

minetest.register_chatcommand("openinv", {
    params = "<player>",
    description = "Open the inventory of another player.",
    privs = {openinv = true},
    func = open_player_inventory
})

minetest.register_chatcommand("openec", {
    params = "<player>",
    description = "Open the Ender Chest of another player.",
    privs = {openec = true},
    func = open_player_enderchest
})

