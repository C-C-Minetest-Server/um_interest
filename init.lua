um_interest = {}

local timer = 0
minetest.register_globalstep(function(dtime)
    timer = timer + dtime
    local interval = tonumber(minetest.settings:get("um_interest.interest_interval")) or 1000
    if interval == 0 then return end

    if timer >= interval then
        timer = 0

        local online_only = minetest.settings:get_bool("um_interest.online_only",true)
        local list_players
        if online_only then
            list_players = {}
            for _,p in ipairs(minetest.get_connected_players()) do
                table.insert(list_players,p:get_player_name())
            end
        else
            list_players = unified_money.list_accounts()
        end

        local method_calculation = minetest.settings:get("um_interest.interest_method")
        if not method_calculation or method_calculation == "" then method_calculation = "add" end
        local interest_amount = tonumber(minetest.settings:get("um_interest.interest_amount")) or 5

        for _,name in ipairs(list_players) do
            local old_balance = unified_money.get_balance_safe(name)
            local new_balance
            if method_calculation == "add" then
                new_balance = old_balance + interest_amount
            elseif method_calculation == "mul" then
                new_balance = old_balance * interest_amount
            end
            minetest.log("action",string.format("[um_interest] Calculated interest of %s: %d -> %d",
                name, old_balance, new_balance
            ))
            unified_money.set_balance_safe(name,new_balance)
        end
    end
end)