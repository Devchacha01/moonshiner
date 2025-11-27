local RSGCore = exports['rsg-core']:GetCoreObject()

-- Check if player has any moonshine
RegisterNetEvent('rsg-moonshiner:server:checkHasMoonshine', function()
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end
    
    local hasMoonshine = false
    local moonshineTypes = {'ginseng_moonshine', 'blackberry_moonshine', 'minty_berry_moonshine'}
    
    for _, moonshineType in ipairs(moonshineTypes) do
        local item = Player.Functions.GetItemByName(moonshineType)
        if item and item.amount > 0 then
            hasMoonshine = true
            break
        end
    end
    
    if hasMoonshine then
        TriggerClientEvent('rsg-moonshiner:client:startSelling', src)
    else
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Moonshine Selling',
            description = 'You don\'t have any moonshine to sell!',
            type = 'error',
            duration = 5000
        })
    end
end)

-- Process NPC sale
RegisterNetEvent('rsg-moonshiner:server:sellToNPC', function(moonshineType, amount, pricePerBottle)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end
    
    print(string.format("Moonshiner Server: Processing sale - %s x%d at $%d each", moonshineType, amount, pricePerBottle))
    
    -- Validate moonshine type
    if not Config.Selling.buyerPrices[moonshineType] then
        print("Moonshiner Server: Invalid moonshine type:", moonshineType)
        return
    end
    
    -- Validate price (prevent exploits)
    -- Validate price (prevent exploits)
    -- Allow up to 2.5x max price to account for "Lucky Offers" (2x) and small variances
    local priceData = Config.Selling.buyerPrices[moonshineType]
    local maxAllowedPrice = priceData.max * 2.5
    
    if pricePerBottle < priceData.min or pricePerBottle > maxAllowedPrice then
        print("Moonshiner Server: Invalid price:", pricePerBottle, "Max allowed:", maxAllowedPrice)
        return
    end
    
    -- Validate amount
    -- Validate amount
    -- Allow any amount between 1 and 20
    if amount < 1 or amount > 20 then
        print("Moonshiner Server: Invalid amount:", amount)
        return
    end
    
    -- Check if player has enough moonshine
    local item = Player.Functions.GetItemByName(moonshineType)
    if not item or item.amount < amount then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Moonshine Selling',
            description = 'You don\'t have enough moonshine!',
            type = 'error',
            duration = 5000
        })
        return
    end
    
    -- Remove moonshine
    local removed = Player.Functions.RemoveItem(moonshineType, amount)
    if not removed then
        print("Moonshiner Server: Failed to remove item")
        return
    end
    
    -- Add money
    local totalPrice = pricePerBottle * amount
    Player.Functions.AddMoney('cash', totalPrice)
    
    -- Success notification
    local moonshineLabel = Config.moonshine[moonshineType].label
    TriggerClientEvent('ox_lib:notify', src, {
        title = 'Moonshine Selling',
        description = string.format('Sold %d x %s for $%d!', amount, moonshineLabel, totalPrice),
        type = 'success',
        duration = 5000
    })
    
    print(string.format("Moonshiner Server: Sale complete - Removed %d %s, added $%d", amount, moonshineType, totalPrice))
    
    -- Police alert system (30% chance)
    local alertChance = math.random(100)
    if alertChance <= 30 then
        -- Get player location
        local playerPed = GetPlayerPed(src)
        local coords = GetEntityCoords(playerPed)
        
        -- Determine which city
        local cityName = "Unknown"
        for _, city in ipairs(Config.Selling.allowedCities) do
            local distance = #(coords - city.coords)
            if distance <= city.radius then
                cityName = city.name
                break
            end
        end
        
        -- Send alert to all law enforcement
        local Players = RSGCore.Functions.GetPlayers()
        for _, playerId in pairs(Players) do
            local TargetPlayer = RSGCore.Functions.GetPlayer(playerId)
            if TargetPlayer then
                local job = TargetPlayer.PlayerData.job.name
                -- Alert law enforcement jobs
                if job == 'police' or job == 'marshal' or job == 'sheriff' or job == 'lawman' then
                    TriggerClientEvent('ox_lib:notify', playerId, {
                        title = 'Law Enforcement Alert',
                        description = string.format('Suspicious activity reported in %s. Possible illegal moonshine sales.', cityName),
                        type = 'warning',
                        duration = 10000
                    })
                    
                    -- Send blip to law enforcement
                    TriggerClientEvent('rsg-moonshiner:client:policeAlert', playerId, coords, cityName)
                end
            end
        end
        
        -- Notify player they've been spotted
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Moonshine Selling',
            description = 'Someone might have seen you... be careful!',
            type = 'warning',
            duration = 5000
        })
        
        print(string.format("Moonshiner Server: Police alert triggered in %s", cityName))
    end
end)
