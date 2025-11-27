local RSGCore = exports['rsg-core']:GetCoreObject()

-- Check Mash Items
RegisterNetEvent('rsg-moonshiner:server:checkMashItems', function(mash, mashData)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end
    
    print("=== MASH CHECK ===")
    print("Player:", src, "checking items for:", mashData.label)
    
    local hasAllItems = true
    local missingItems = {}
    
    -- Check if player has all required items
    for itemName, itemCount in pairs(mashData.items) do
        local item = Player.Functions.GetItemByName(itemName)
        print("Checking:", itemName, "- Need:", itemCount, "Have:", item and item.amount or 0)
        if not item then
            hasAllItems = false
            table.insert(missingItems, itemCount .. 'x ' .. itemName)
        elseif item.amount < itemCount then
            hasAllItems = false
            local needed = itemCount - item.amount
            table.insert(missingItems, needed .. 'x ' .. itemName)
        end
    end
    
    if hasAllItems then
        print("✓ Player has all items, starting mash production")
        -- Remove items from inventory
        for itemName, itemCount in pairs(mashData.items) do
            Player.Functions.RemoveItem(itemName, itemCount)
            TriggerClientEvent('inventory:client:ItemBox', src, RSGCore.Shared.Items[itemName], "remove", itemCount)
        end
        
        -- Start mash production
        TriggerClientEvent('rsg-moonshiner:client:processMash', src, mash, mashData)
        TriggerClientEvent('ox_lib:notify', src, { title = 'Moonshiner', description = '🍺 Started making ' .. mashData.label .. '...', type = 'success', duration = 5000 })
        print("✓ Notification sent: Started making", mashData.label)
    else
        local missingText = table.concat(missingItems, ', ')
        print("✗ Missing items:", missingText)
        TriggerClientEvent('ox_lib:notify', src, { title = 'Moonshiner', description = '❌ Missing items: ' .. missingText, type = 'error', duration = 5000 })
        print("✗ Notification sent: Missing items")
    end
end)

-- Give Mash
RegisterNetEvent('rsg-moonshiner:server:giveMash', function(mash, mashData)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end
    
    print("=== MASH COMPLETE ===")
    
    -- Base output amount
    local outputAmount = mashData.outputAmount
    
    -- 30% chance to get bonus (3-4 instead of 1)
    local luck = math.random(1, 100)
    if luck <= 30 then
        outputAmount = math.random(3, 4)
        Player.Functions.AddItem(mashData.output, outputAmount)
        TriggerClientEvent('inventory:client:ItemBox', src, RSGCore.Shared.Items[mashData.output], "add", outputAmount)
        TriggerClientEvent('ox_lib:notify', src, { title = 'Moonshiner', description = '🍀 Lucky! You created ' .. outputAmount .. 'x ' .. mashData.label .. '!', type = 'success', duration = 5000 })
        print("✓ LUCKY! Created", outputAmount .. "x", mashData.label)
    else
        Player.Functions.AddItem(mashData.output, outputAmount)
        TriggerClientEvent('inventory:client:ItemBox', src, RSGCore.Shared.Items[mashData.output], "add", outputAmount)
        TriggerClientEvent('ox_lib:notify', src, { title = 'Moonshiner', description = '✓ Successfully created ' .. outputAmount .. 'x ' .. mashData.label .. '!', type = 'success', duration = 5000 })
        print("✓ Created", outputAmount .. "x", mashData.label)
    end
    
    -- Add XP (if you have an XP system)
    -- local xp = math.random(mashData.minXP, mashData.maxXP)
    -- Player.Functions.AddJobReputation('moonshiner', xp)
end)

-- Check Moonshine Items
RegisterNetEvent('rsg-moonshiner:server:checkMoonshineItems', function(moonshine, moonshineData)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end
    
    print("=== MOONSHINE CHECK ===")
    print("Player:", src, "checking items for:", moonshineData.label)
    
    local hasAllItems = true
    local missingItems = {}
    
    -- Check if player has all required items
    for itemName, itemCount in pairs(moonshineData.items) do
        local item = Player.Functions.GetItemByName(itemName)
        print("Checking:", itemName, "- Need:", itemCount, "Have:", item and item.amount or 0)
        if not item then
            hasAllItems = false
            table.insert(missingItems, itemCount .. 'x ' .. itemName)
        elseif item.amount < itemCount then
            hasAllItems = false
            local needed = itemCount - item.amount
            table.insert(missingItems, needed .. 'x ' .. itemName)
        end
    end
    
    if hasAllItems then
        print("✓ Player has all items, starting brew")
        -- Remove items from inventory
        for itemName, itemCount in pairs(moonshineData.items) do
            Player.Functions.RemoveItem(itemName, itemCount)
            TriggerClientEvent('inventory:client:ItemBox', src, RSGCore.Shared.Items[itemName], "remove", itemCount)
        end
        
        -- Start brewing
        TriggerClientEvent('rsg-moonshiner:client:processBrewing', src, moonshine, moonshineData)
        TriggerClientEvent('ox_lib:notify', src, { title = 'Moonshiner', description = '🥃 Started brewing ' .. moonshineData.label .. '...', type = 'success', duration = 5000 })
        print("✓ Notification sent: Started brewing", moonshineData.label)
    else
        local missingText = table.concat(missingItems, ', ')
        print("✗ Missing items:", missingText)
        TriggerClientEvent('ox_lib:notify', src, { title = 'Moonshiner', description = '❌ Missing items: ' .. missingText, type = 'error', duration = 5000 })
        print("✗ Notification sent: Missing items")
    end
end)

-- Give Moonshine
RegisterNetEvent('rsg-moonshiner:server:giveMoonshine', function(moonshine, moonshineData)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end
    
    print("=== MOONSHINE COMPLETE ===")
    
    -- Base output amount
    local outputAmount = moonshineData.outputAmount
    
    -- 30% chance to get bonus (3-4 instead of 1)
    local luck = math.random(1, 100)
    if luck <= 30 then
        outputAmount = math.random(3, 4)
        Player.Functions.AddItem(moonshineData.output, outputAmount)
        TriggerClientEvent('inventory:client:ItemBox', src, RSGCore.Shared.Items[moonshineData.output], "add", outputAmount)
        TriggerClientEvent('ox_lib:notify', src, { title = 'Moonshiner', description = '🍀 Lucky! You brewed ' .. outputAmount .. 'x ' .. moonshineData.label .. '!', type = 'success', duration = 5000 })
        print("✓ LUCKY! Brewed", outputAmount .. "x", moonshineData.label)
    else
        Player.Functions.AddItem(moonshineData.output, outputAmount)
        TriggerClientEvent('inventory:client:ItemBox', src, RSGCore.Shared.Items[moonshineData.output], "add", outputAmount)
        TriggerClientEvent('ox_lib:notify', src, { title = 'Moonshiner', description = '✓ Successfully brewed ' .. outputAmount .. 'x ' .. moonshineData.label .. '!', type = 'success', duration = 5000 })
        print("✓ Brewed", outputAmount .. "x", moonshineData.label)
    end
    
    -- Add XP (if you have an XP system)
    -- local xp = math.random(moonshineData.minXP, moonshineData.maxXP)
    -- Player.Functions.AddJobReputation('moonshiner', xp)
end)

-- Give Prop Back
RegisterNetEvent('rsg-moonshiner:server:givePropBack', function(propName)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end
    
    Player.Functions.AddItem(propName, 1)
    TriggerClientEvent('inventory:client:ItemBox', src, RSGCore.Shared.Items[propName], "add", 1)
end)

-- Place Prop (Temporary - doesn't save to database)
RegisterNetEvent('rsg-moonshiner:server:placeProp', function(propName, xpos, ypos, zpos)
    local src = source
    
    -- Props are temporary and will disappear on server restart
    -- MySQL.insert('INSERT INTO moonshiner (object, xpos, ypos, zpos, actif) VALUES (?, ?, ?, ?, ?)', {
    --     propName,
    --     xpos,
    --     ypos,
    --     zpos,
    --     1
    -- }, function(id)
    --     if id then
    --         TriggerClientEvent('rsg-moonshiner:client:replaceProps', -1, propName, xpos, ypos, zpos, 1)
    --     end
    -- end)
    
    -- Just sync to all clients without saving
    TriggerClientEvent('rsg-moonshiner:client:replaceProps', -1, propName, xpos, ypos, zpos, 1)
end)

-- Remove Prop (Temporary - doesn't save to database)
RegisterNetEvent('rsg-moonshiner:server:removeProp', function(id)
    -- MySQL.query('DELETE FROM moonshiner WHERE id = ?', {id})
    -- Props are temporary, no database cleanup needed
end)

-- Update Props
RegisterNetEvent('rsg-moonshiner:server:updateProps', function()
    local src = source
    
    MySQL.query('SELECT * FROM moonshiner', {}, function(result)
        if result and #result > 0 then
            for _, v in pairs(result) do
                TriggerClientEvent('rsg-moonshiner:client:replaceProps', src, v.object, v.xpos, v.ypos, v.zpos, v.actif)
            end
        end
    end)
end)

-- Get Coords ID
RegisterNetEvent('rsg-moonshiner:server:getCoordsId', function(x, y, z)
    local src = source
    
    MySQL.query('SELECT * FROM moonshiner', {}, function(result)
        if result and #result > 0 then
            for _, v in pairs(result) do
                TriggerClientEvent('rsg-moonshiner:client:getId', src, x, y, z, v.object, v.xpos, v.ypos, v.zpos)
            end
        end
    end)
end)

-- Get Object ID
RegisterNetEvent('rsg-moonshiner:server:getObjectId', function(object, x, y, z)
    local src = source
    
    MySQL.query('SELECT * FROM moonshiner WHERE object = ? AND xpos LIKE ? AND ypos LIKE ? AND zpos LIKE ?', {
        object,
        x,
        y,
        z
    }, function(result)
        if result and #result > 0 then
            for _, v in pairs(result) do
                MySQL.update('UPDATE moonshiner SET actif = 0 WHERE id = ?', {v.id})
                TriggerClientEvent('rsg-moonshiner:client:deleteProp', src, v.id, v.object, v.xpos, v.ypos, v.zpos)
            end
        end
    end)
end)

-- Initialize Shop
CreateThread(function()
    local shopItems = {}
    for _, item in pairs(Config.ShopItems) do
        table.insert(shopItems, {
            name = item.name,
            price = item.price,
            amount = item.amount
        })
    end

    exports['rsg-inventory']:CreateShop({
        name = 'moonshiner_shop',
        label = 'Moonshiner Shop',
        slots = #shopItems,
        items = shopItems,
    })
end)

-- Open Shop
RegisterNetEvent('rsg-moonshiner:server:openShop', function()
    local src = source
    exports['rsg-inventory']:OpenShop(src, 'moonshiner_shop')
end)

-- Buy Item
RegisterNetEvent('rsg-moonshiner:server:buyItem', function(data)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end
    
    local itemName = data.item
    local price = data.price
    
    if Player.PlayerData.money.cash >= price then
        Player.Functions.RemoveMoney('cash', price)
        Player.Functions.AddItem(itemName, 1)
        TriggerClientEvent('inventory:client:ItemBox', src, RSGCore.Shared.Items[itemName], "add", 1)
        TriggerClientEvent('RSGCore:Notify', src, 'You bought ' .. itemName .. ' for $' .. price, 'success')
    else
        TriggerClientEvent('RSGCore:Notify', src, 'You don\'t have enough money!', 'error')
    end
end)

-- Sell Products (Auto-sell all moonshine products)
RegisterNetEvent('rsg-moonshiner:server:openSellMenu', function()
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end
    
    local totalMoney = 0
    local soldItems = {}
    
    -- Check each sellable item
    for itemName, price in pairs(Config.SellPrices) do
        local item = Player.Functions.GetItemByName(itemName)
        if item and item.amount > 0 then
            local amount = item.amount
            local itemTotal = price * amount
            
            Player.Functions.RemoveItem(itemName, amount)
            totalMoney = totalMoney + itemTotal
            
            table.insert(soldItems, {
                name = itemName,
                amount = amount,
                total = itemTotal
            })
            
            TriggerClientEvent('inventory:client:ItemBox', src, RSGCore.Shared.Items[itemName], "remove", amount)
        end
    end
    
    if totalMoney > 0 then
        Player.Functions.AddMoney('cash', totalMoney)
        TriggerClientEvent('RSGCore:Notify', src, 'Sold all products for $' .. totalMoney, 'success')
    else
        TriggerClientEvent('RSGCore:Notify', src, 'You don\'t have any moonshine or mash to sell!', 'error')
    end
end)

-- Usable Moonshine Items (Drunk System)
local drunkPlayers = {} -- Track drunk level per player

-- Ginseng Moonshine
RSGCore.Functions.CreateUseableItem('ginseng_moonshine', function(source, item)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end
    
    print("Moonshiner Server: Player", src, "used ginseng_moonshine")
    
    Player.Functions.RemoveItem('ginseng_moonshine', 1)
    TriggerClientEvent('inventory:client:ItemBox', src, RSGCore.Shared.Items['ginseng_moonshine'], "remove", 1)
    
    -- Track drunk level
    drunkPlayers[src] = (drunkPlayers[src] or 0) + 1
    
    print("Moonshiner Server: Player drunk level now:", drunkPlayers[src])
    TriggerClientEvent('rsg-moonshiner:client:drinkMoonshine', src, drunkPlayers[src])
end)

-- Blackberry Moonshine
RSGCore.Functions.CreateUseableItem('blackberry_moonshine', function(source, item)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end
    
    print("Moonshiner Server: Player", src, "used blackberry_moonshine")
    
    Player.Functions.RemoveItem('blackberry_moonshine', 1)
    TriggerClientEvent('inventory:client:ItemBox', src, RSGCore.Shared.Items['blackberry_moonshine'], "remove", 1)
    
    drunkPlayers[src] = (drunkPlayers[src] or 0) + 1
    
    print("Moonshiner Server: Player drunk level now:", drunkPlayers[src])
    TriggerClientEvent('rsg-moonshiner:client:drinkMoonshine', src, drunkPlayers[src])
end)

-- Minty Berry Moonshine
RSGCore.Functions.CreateUseableItem('minty_berry_moonshine', function(source, item)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end
    
    print("Moonshiner Server: Player", src, "used minty_berry_moonshine")
    
    Player.Functions.RemoveItem('minty_berry_moonshine', 1)
    TriggerClientEvent('inventory:client:ItemBox', src, RSGCore.Shared.Items['minty_berry_moonshine'], "remove", 1)
    
    drunkPlayers[src] = (drunkPlayers[src] or 0) + 1
    
    print("Moonshiner Server: Player drunk level now:", drunkPlayers[src])
    TriggerClientEvent('rsg-moonshiner:client:drinkMoonshine', src, drunkPlayers[src])
end)

-- Reset drunk level when player disconnects
AddEventHandler('playerDropped', function()
    local src = source
    drunkPlayers[src] = nil
end)

-- Usable Items
RSGCore.Functions.CreateUseableItem(Config.brewProp, function(source, item)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end
    
    Player.Functions.RemoveItem(Config.brewProp, 1)
    TriggerClientEvent('inventory:client:ItemBox', src, RSGCore.Shared.Items[Config.brewProp], "remove", 1)
    TriggerClientEvent('rsg-moonshiner:client:placeProp', src, Config.brewProp)
end)

RSGCore.Functions.CreateUseableItem(Config.mashProp, function(source, item)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end
    
    Player.Functions.RemoveItem(Config.mashProp, 1)
    TriggerClientEvent('inventory:client:ItemBox', src, RSGCore.Shared.Items[Config.mashProp], "remove", 1)
    TriggerClientEvent('rsg-moonshiner:client:placeProp', src, Config.mashProp)
end)

-- Props are temporary and don't persist after server restart
-- Initialize moonshiner props on server start (DISABLED - props are temporary)
-- CreateThread(function()
--     Wait(1000)
--     MySQL.query('SELECT * FROM moonshiner', {}, function(result)
--         if result and #result > 0 then
--             for _, v in pairs(result) do
--                 TriggerClientEvent('rsg-moonshiner:client:replaceProps', -1, v.object, v.xpos, v.ypos, v.zpos, v.actif)
--                 if Config.Debug then
--                     print('^2[RSG-Moonshiner]: Loaded object at', v.xpos, v.ypos, v.zpos, v.object, '^7')
--                 end
--             end
--         end
--     end)
-- end)
