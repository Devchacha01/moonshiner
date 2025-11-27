local RSGCore = exports['rsg-core']:GetCoreObject()

-- Selling State
local isSelling = false
local currentBuyer = nil
local buyersServed = 0
local sellingCooldown = false
local spawnedNPCs = {}

-- Helper Functions
local function Notify(message, type)
    lib.notify({
        title = 'Moonshine Selling',
        description = message,
        type = type or 'inform',
        duration = 5000
    })
end

local function IsInAllowedCity()
    local playerCoords = GetEntityCoords(PlayerPedId())
    
    for _, city in ipairs(Config.Selling.allowedCities) do
        local distance = #(playerCoords - city.coords)
        if distance <= city.radius then
            return true, city.name
        end
    end
    
    return false, nil
end

local function LoadAnimDict(dict)
    if HasAnimDictLoaded(dict) then return true end
    RequestAnimDict(dict)
    local timeout = 0
    while not HasAnimDictLoaded(dict) and timeout < 2000 do
        Wait(10)
        timeout = timeout + 10
    end
    return HasAnimDictLoaded(dict)
end

local function GetRandomMoonshineType()
    local playerPed = PlayerPedId()
    local moonshineTypes = {'ginseng_moonshine', 'blackberry_moonshine', 'minty_berry_moonshine'}
    
    -- Check which moonshine types player has
    local availableTypes = {}
    for _, moonshineType in ipairs(moonshineTypes) do
        -- Server will validate actual count
        table.insert(availableTypes, moonshineType)
    end
    
    if #availableTypes == 0 then
        return nil
    end
    
    return availableTypes[math.random(1, #availableTypes)]
end

local function CleanupNPCs()
    for _, npc in ipairs(spawnedNPCs) do
        if DoesEntityExist(npc) then
            DeletePed(npc)
        end
    end
    spawnedNPCs = {}
end

local function SpawnBuyer()
    if not isSelling then return end
    if currentBuyer and DoesEntityExist(currentBuyer) then return end
    
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    
    -- Find nearby NPCs (excluding store owners, mission NPCs, and animals)
    local nearbyPeds = {}
    local handle, ped = FindFirstPed()
    local success
    
    repeat
        local pedCoords = GetEntityCoords(ped)
        local distance = #(playerCoords - pedCoords)
        
        -- Check if ped is valid (not player, not dead, not in vehicle, not mission entity, within range)
        if ped ~= playerPed and 
           not IsPedDeadOrDying(ped, true) and 
           not IsPedInAnyVehicle(ped, false) and
           not IsPedAPlayer(ped) and
           not IsEntityAMissionEntity(ped) and -- Must not be a mission entity (like shopkeepers)
           distance > 10.0 and distance < 50.0 then
            
            -- STRICT HUMAN VALIDATION - Multiple checks to prevent animals
            local isValidHuman = true
            
            -- Check 1: Must be human ped type
            if not IsPedHuman(ped) then
                isValidHuman = false
            end
            
            -- Check 2: Entity type must be ped (type 1), not animal
            local entityType = GetEntityType(ped)
            if entityType ~= 1 then
                isValidHuman = false
            end
            
            -- Check 3: Ped type must be human (PED_TYPE_CIVMALE = 4 or PED_TYPE_CIVFEMALE = 5)
            local pedType = GetPedType(ped)
            if pedType ~= 4 and pedType ~= 5 then
                isValidHuman = false
            end
            
            -- Check 4: Verify ped relationship group is not animal
            local relationshipGroup = GetPedRelationshipGroupHash(ped)
            local animalGroups = {
                GetHashKey('WILD_ANIMAL'),
                GetHashKey('DOMESTIC_ANIMAL'),
                GetHashKey('ANIMAL'),
                GetHashKey('HORSE'),
                GetHashKey('LIVESTOCK')
            }
            for _, animalGroup in ipairs(animalGroups) do
                if relationshipGroup == animalGroup then
                    isValidHuman = false
                    break
                end
            end
            
            if isValidHuman then
                -- Exclude store owners and specific NPCs
                local pedModel = GetEntityModel(ped)
                local modelName = GetHashKey('u_m_m_valgenstoreowner_01')
                local storeModel1 = GetHashKey('u_m_m_rhdgenstore_01')
                local storeModel2 = GetHashKey('u_m_m_sdgenstore_01')
                
                -- Also exclude our configured shopkeeper model
                local configShopModel = Config.NPCSettings.model
                if type(configShopModel) == 'string' then configShopModel = GetHashKey(configShopModel) end
                
                if pedModel ~= modelName and pedModel ~= storeModel1 and pedModel ~= storeModel2 and pedModel ~= configShopModel then
                    table.insert(nearbyPeds, {ped = ped, distance = distance})
                end
            end
        end
        
        success, ped = FindNextPed(handle)
    until not success
    
    EndFindPed(handle)
    
    -- If no NPCs found nearby, notify player
    if #nearbyPeds == 0 then
        print("Moonshiner: No NPCs found nearby, waiting...")
        Notify('No potential buyers nearby. Move to a busier area or wait...', 'inform')
        
        -- Try again in 10 seconds
        SetTimeout(10000, function()
            if isSelling and buyersServed < Config.Selling.maxBuyersPerSession then
                SpawnBuyer()
            end
        end)
        return
    end
    
    -- Sort by distance and pick a random one from the closest 5
    table.sort(nearbyPeds, function(a, b) return a.distance < b.distance end)
    local maxPeds = math.min(5, #nearbyPeds)
    local selectedPed = nearbyPeds[math.random(1, maxPeds)].ped
    
    currentBuyer = selectedPed
    table.insert(spawnedNPCs, currentBuyer)
    
    -- Set as mission entity and control it
    SetEntityAsMissionEntity(currentBuyer, true, true)
    SetBlockingOfNonTemporaryEvents(currentBuyer, true)
    SetPedFleeAttributes(currentBuyer, 0, false)
    SetPedCombatAttributes(currentBuyer, 17, true)
    
    -- Clear any current tasks
    ClearPedTasks(currentBuyer)
    
    -- Make NPC walk to player
    TaskGoToEntity(currentBuyer, playerPed, -1, 2.0, 1.0, 0, 0)
    
    print("Moonshiner: Found buyer NPC, making them approach")
    
    -- Wait for NPC to reach player
    CreateThread(function()
        local timeout = 0
        while isSelling and DoesEntityExist(currentBuyer) and timeout < 30000 do
            local npcCoords = GetEntityCoords(currentBuyer)
            local playerCoords = GetEntityCoords(PlayerPedId())
            local distance = #(npcCoords - playerCoords)
            
            if distance <= 3.0 then
                -- NPC arrived, show interaction
                ClearPedTasks(currentBuyer)
                TaskTurnPedToFaceEntity(currentBuyer, PlayerPedId(), 3000)
                
                -- Trigger sale interaction
                HandleBuyerInteraction()
                break
            end
            
            Wait(500)
            timeout = timeout + 500
        end
        
        -- Timeout - release NPC
        if timeout >= 30000 and DoesEntityExist(currentBuyer) then
            print("Moonshiner: Buyer timeout, releasing NPC")
            -- Release the NPC back to normal behavior
            SetEntityAsMissionEntity(currentBuyer, false, true)
            SetBlockingOfNonTemporaryEvents(currentBuyer, false)
            ClearPedTasks(currentBuyer)
            currentBuyer = nil
            
            -- Try next buyer
            if isSelling and buyersServed < Config.Selling.maxBuyersPerSession then
                local delay = math.random(Config.Selling.timeBetweenBuyers.min, Config.Selling.timeBetweenBuyers.max)
                Wait(delay)
                SpawnBuyer()
            end
        end
    end)
end

function HandleBuyerInteraction()
    if not isSelling or not DoesEntityExist(currentBuyer) then return end
    
    print("Moonshiner: Buyer arrived, showing interaction")
    
    -- Get Player Inventory to see what they have
    local PlayerData = RSGCore.Functions.GetPlayerData()
    local inventory = PlayerData.items
    local sellableItems = {}
    
    local moonshineTypes = {'ginseng_moonshine', 'blackberry_moonshine', 'minty_berry_moonshine'}
    
    for _, item in pairs(inventory) do
        for _, mType in ipairs(moonshineTypes) do
            if item.name == mType and item.amount > 0 then
                table.insert(sellableItems, {
                    name = item.name,
                    label = item.label,
                    amount = item.amount,
                    info = item.info
                })
            end
        end
    end
    
    if #sellableItems == 0 then
        Notify('You don\'t have any moonshine to sell!', 'error')
        -- Buyer leaves disappointed
        if DoesEntityExist(currentBuyer) then
            SetEntityAsMissionEntity(currentBuyer, false, true)
            SetBlockingOfNonTemporaryEvents(currentBuyer, false)
            TaskWanderStandard(currentBuyer, 10.0, 10)
        end
        currentBuyer = nil
        EndSelling()
        return
    end
    
    -- Buyer timeout tracking
    local buyerTimedOut = false
    local offerAccepted = false
    
    -- Start timeout thread (6 seconds - VERY FAST)
    local timeoutDuration = 6000
    CreateThread(function()
        Wait(timeoutDuration)
        
        -- If offer wasn't accepted and buyer hasn't timed out yet
        if not offerAccepted and not buyerTimedOut and isSelling then
            buyerTimedOut = true
            
            -- Hide the menu
            lib.hideContext()
            
            Notify('Too slow! The buyer got nervous and left!', 'error')
            
            -- Buyer leaves
            if DoesEntityExist(currentBuyer) then
                -- Release NPC back to normal behavior
                SetEntityAsMissionEntity(currentBuyer, false, true)
                SetBlockingOfNonTemporaryEvents(currentBuyer, false)
                TaskWanderStandard(currentBuyer, 10.0, 10)
            end
            currentBuyer = nil
            
            -- Spawn next buyer
            if buyersServed < Config.Selling.maxBuyersPerSession then
                local delay = math.random(Config.Selling.timeBetweenBuyers.min, Config.Selling.timeBetweenBuyers.max)
                SetTimeout(delay, function()
                    if isSelling then
                        SpawnBuyer()
                    end
                end)
            else
                EndSelling()
            end
        end
    end)
    
    -- Build Menu Options
    local options = {}
    
    for _, item in ipairs(sellableItems) do
        -- Calculate price offer
        local priceData = Config.Selling.buyerPrices[item.name]
        -- Random price per bottle
        local pricePerBottle = math.random(priceData.min, priceData.max)
        
        -- Decide how many buyer wants (random 1-10, but not more than player has)
        local wantAmount = math.random(1, 10)
        if wantAmount > item.amount then wantAmount = item.amount end
        
        -- Lucky Price Chance (10% chance for double price)
        local isLucky = math.random(1, 100) <= 10
        local priceMultiplier = isLucky and 2.0 or 1.0
        
        local totalPrice = math.floor(pricePerBottle * wantAmount * priceMultiplier)
        local priceDesc = string.format('Offer: $%d ($%d/bottle)', totalPrice, pricePerBottle)
        
        if isLucky then
            priceDesc = string.format('LUCKY OFFER! $%d ($%d/bottle - 2x Bonus!)', totalPrice, pricePerBottle * 2)
        end
        
        table.insert(options, {
            title = 'Sell ' .. wantAmount .. 'x ' .. item.label,
            description = priceDesc,
            icon = 'bottle-droplet',
            onSelect = function()
                offerAccepted = true
                -- Pass the potentially doubled price per bottle to the server
                ProcessSale(item.name, wantAmount, math.floor(pricePerBottle * priceMultiplier))
            end
        })
    end
    
    -- Add Decline Option
    table.insert(options, {
        title = 'Decline / Send Away',
        description = 'Wait for another buyer',
        icon = 'xmark',
        onSelect = function()
            offerAccepted = true
            Notify('You sent the buyer away', 'inform')
            BuyerLeaves()
        end
    })
    
    -- Add Stop Selling Option
    table.insert(options, {
        title = 'Stop Selling',
        description = 'End the selling session',
        icon = 'door-open',
        onSelect = function()
            offerAccepted = true
            EndSelling()
        end
    })
    
    -- Register and show menu
    lib.registerContext({
        id = 'moonshine_buyer',
        title = 'Interested Buyer',
        options = options
    })
    
    lib.showContext('moonshine_buyer')
end

function ProcessSale(moonshineType, amount, pricePerBottle)
    local playerPed = PlayerPedId()
    
    -- Request animation dictionary
    lib.requestAnimDict('mech_inventory@drinking@bottle_cylinder_d1-3_h30-5_neck_a13_b2-5')
    
    -- Play bottle handoff animation with progress bar
    if lib.progressBar({
        duration = 3000,
        label = 'Making the deal...',
        useWhileDead = false,
        canCancel = false,
        disable = {
            move = true,
            car = true,
            combat = true
        },
        anim = {
            dict = 'mech_inventory@drinking@bottle_cylinder_d1-3_h30-5_neck_a13_b2-5',
            clip = 'uncork',
            flag = 31
        }
    }) then
        -- Clear player animation
        ClearPedTasks(playerPed)
        
        -- Process sale on server
        TriggerServerEvent('rsg-moonshiner:server:sellToNPC', moonshineType, amount, pricePerBottle)
        
        -- Handle NPC animations in a separate thread so we don't block the next buyer
        local buyerPed = currentBuyer
        if DoesEntityExist(buyerPed) then
            -- Mark as mission entity to keep control during animation
            SetEntityAsMissionEntity(buyerPed, true, true)
            
            CreateThread(function()
                -- Use pcall to catch any errors and ensure cleanup always happens
                local success, err = pcall(function()
                    print("Moonshiner: Starting buyer animation sequence")
                    
                    -- Create moonshine bottle prop
                    local propModel = GetHashKey('p_bottleJD01x') 
                    RequestModel(propModel)
                    
                    local timeout = 0
                    while not HasModelLoaded(propModel) and timeout < 2000 do 
                        Wait(10) 
                        timeout = timeout + 10
                    end
                    
                    local prop = nil
                    if HasModelLoaded(propModel) then
                        prop = CreateObject(propModel, 0.0, 0.0, 0.0, true, true, false)
                        -- Attach to right hand
                        AttachEntityToEntity(prop, buyerPed, GetPedBoneIndex(buyerPed, 57005), 0.12, 0.0, -0.02, -80.0, 0.0, 0.0, true, true, false, true, 1, true)
                        print("Moonshiner: Bottle prop attached successfully")
                    else
                        print("Moonshiner: Failed to load bottle prop model")
                    end
                    
                    -- Buyer does receiving animation (bottle)
                    local animDict = 'mech_inventory@drinking@bottle_cylinder_d1-3_h30-5_neck_a13_b2-5'
                    LoadAnimDict(animDict)
                    
                    print("Moonshiner: Playing uncork animation")
                    TaskPlayAnim(buyerPed, animDict, 'uncork', 8.0, -8.0, 1000, 0, 0, false, false, false)
                    
                    Wait(1000)
                    
                    -- NPC drinks the moonshine
                    print("Moonshiner: Playing drink animation")
                    TaskPlayAnim(buyerPed, animDict, 'chug_a', 8.0, -8.0, 3000, 0, 0, false, false, false)
                    
                    Wait(3000)
                    
                    -- Delete prop
                    if prop and DoesEntityExist(prop) then
                        DeleteObject(prop)
                    end
                    SetModelAsNoLongerNeeded(propModel)
                    
                    -- Clear animation IMMEDIATELY to prevent sticking
                    ClearPedTasksImmediately(buyerPed)
                    
                    -- NPC gets drunk and walks away
                    if DoesEntityExist(buyerPed) then
                        print("Moonshiner: Applying drunk effects")
                        
                        -- Apply drunk effect
                        Citizen.InvokeNative(0x406CCF555B04FAD3, buyerPed, 1, 1.0) -- SetPedDrunkness (Max)
                        SetPedConfigFlag(buyerPed, 100, true) -- Drunk flag
                        SetPedIsDrunk(buyerPed, true)
                        
                        -- Force drunk walk style
                        local clipset = "move_m@drunk@verydrunk"
                        RequestAnimSet(clipset)
                        local timeout = 0
                        while not HasAnimSetLoaded(clipset) and timeout < 2000 do
                            Wait(10)
                            timeout = timeout + 10
                        end
                        
                        if HasAnimSetLoaded(clipset) then
                            Citizen.InvokeNative(0x923583741DC87BCE, buyerPed, clipset, 1.0) -- SetPedMovementClipset
                            print("Moonshiner: Applied drunk walk style")
                        end
                        
                        -- Notification
                        local playerCoords = GetEntityCoords(PlayerPedId())
                        local npcCoords = GetEntityCoords(buyerPed)
                        if #(playerCoords - npcCoords) < 10.0 then
                            Notify('The buyer is getting drunk from your moonshine!', 'success')
                        end
                    end
                end)
                
                if not success then
                    print("Moonshiner: Error in animation thread:", err)
                end
                
                -- CLEANUP BLOCK - ALWAYS RUNS
                if DoesEntityExist(buyerPed) then
                    print("Moonshiner: Releasing NPC control")
                    -- Release NPC from mission control
                    SetEntityAsMissionEntity(buyerPed, false, true)
                    SetBlockingOfNonTemporaryEvents(buyerPed, false)
                    
                    -- Make NPC wander drunk
                    TaskWanderStandard(buyerPed, 10.0, 10)
                    
                    -- Despawn logic
                    SetTimeout(120000, function() -- 2 minutes
                        if DoesEntityExist(buyerPed) then
                            -- Fade out
                            for i = 255, 0, -5 do
                                SetEntityAlpha(buyerPed, i, false)
                                Wait(50)
                            end
                            DeletePed(buyerPed)
                        end
                    end)
                    
                    -- Random chance NPC falls over drunk (30% chance)
                    -- Run this in a separate non-blocking check
                    if math.random(100) <= 30 then
                        SetTimeout(2000, function()
                            if DoesEntityExist(buyerPed) then
                                print("Moonshiner: NPC falling over")
                                SetPedToRagdoll(buyerPed, 5000, 5000, 0, true, true, false)
                                Notify('The buyer just passed out!', 'inform')
                            end
                        end)
                    end
                end
            end)
        end
        
        -- Reset current buyer immediately to allow next spawn
        currentBuyer = nil
        buyersServed = buyersServed + 1
        
        -- Spawn next buyer if not at max
        if buyersServed < Config.Selling.maxBuyersPerSession then
            local delay = math.random(Config.Selling.timeBetweenBuyers.min, Config.Selling.timeBetweenBuyers.max)
            SetTimeout(delay, function()
                if isSelling then
                    SpawnBuyer()
                end
            end)
        else
            Notify('No more buyers today. Come back later!', 'success')
            EndSelling()
        end
    end
end

function BuyerLeaves()
    -- Buyer leaves
    if DoesEntityExist(currentBuyer) then
        local ped = currentBuyer
        -- Release NPC back to normal behavior
        SetEntityAsMissionEntity(ped, false, true)
        SetBlockingOfNonTemporaryEvents(ped, false)
        TaskWanderStandard(ped, 10.0, 10)
        
        -- Despawn after delay
        SetTimeout(60000, function() -- 1 minute for dismissed buyers
            if DoesEntityExist(ped) then
                -- Fade out
                for i = 255, 0, -5 do
                    SetEntityAlpha(ped, i, false)
                    Wait(50)
                end
                DeletePed(ped)
            end
        end)
    end
    currentBuyer = nil
    
    -- Spawn next buyer
    if buyersServed < Config.Selling.maxBuyersPerSession then
        local delay = math.random(Config.Selling.timeBetweenBuyers.min, Config.Selling.timeBetweenBuyers.max)
        SetTimeout(delay, function()
            if isSelling then
                SpawnBuyer()
            end
        end)
    else
        EndSelling()
    end
end

function EndSelling()
    print("Moonshiner: Ending selling session")
    isSelling = false
    buyersServed = 0
    CleanupNPCs()
    currentBuyer = nil
    
    Notify('Selling session ended', 'inform')
    
    -- Start cooldown
    sellingCooldown = true
    SetTimeout(Config.Selling.cooldownTime, function()
        sellingCooldown = false
        Notify('You can sell moonshine again now', 'success')
    end)
end

-- Command to start selling
RegisterCommand('sellmoonshine', function(source, args, rawCommand)
    if not Config.Selling.enabled then
        Notify('Moonshine selling is currently disabled', 'error')
        return
    end
    
    if isSelling then
        Notify('You are already selling moonshine!', 'error')
        return
    end
    
    if sellingCooldown then
        Notify('You must wait before selling again', 'error')
        return
    end
    
    -- Check if in allowed city
    local inCity, cityName = IsInAllowedCity()
    if not inCity then
        Notify('You must be in a city to sell moonshine (Valentine, Rhodes, Saint Denis, or Blackwater)', 'error')
        return
    end
    
    -- Check if player has moonshine
    TriggerServerEvent('rsg-moonshiner:server:checkHasMoonshine')
end, false)

-- Command to stop selling
RegisterCommand('stopsellingmoonshine', function(source, args, rawCommand)
    if not isSelling then
        Notify('You are not currently selling moonshine', 'error')
        return
    end
    
    EndSelling()
    Notify('Stopped selling moonshine', 'inform')
end, false)

-- Server response to moonshine check
RegisterNetEvent('rsg-moonshiner:client:startSelling', function()
    local inCity, cityName = IsInAllowedCity()
    
    print("Moonshiner: Starting selling session in", cityName)
    isSelling = true
    buyersServed = 0
    
    Notify(string.format('Started selling in %s. Buyers will approach you...', cityName), 'success')
    Notify('WARNING: Selling moonshine is illegal! Be careful of the law.', 'error')
    Notify('Buyers are impatient! You only have a few seconds to make the deal.', 'inform')
    
    -- Spawn first buyer
    Wait(2000)
    SpawnBuyer()
end)

-- Cleanup on resource stop
AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        CleanupNPCs()
    end
end)

-- Police Alert System
RegisterNetEvent('rsg-moonshiner:client:policeAlert', function(coords, cityName)
    -- Create blip for law enforcement
    local blip = Citizen.InvokeNative(0x554D9D53F696D002, 1664425300, coords.x, coords.y, coords.z) -- BlipAddForCoords
    SetBlipSprite(blip, -1282792512, true) -- Wanted/Crime blip
    Citizen.InvokeNative(0x9CB1A1623062F402, blip, string.format("Suspicious Activity - %s", cityName)) -- SetBlipName
    
    -- Remove blip after 2 minutes
    SetTimeout(120000, function()
        RemoveBlip(blip)
    end)
    
    print(string.format("Moonshiner: Police alert blip created for %s", cityName))
end)

-- Chat Suggestions
CreateThread(function()
    TriggerEvent('chat:addSuggestion', '/sellmoonshine', 'Start selling moonshine to locals', {})
    TriggerEvent('chat:addSuggestion', '/stopsellingmoonshine', 'Stop selling moonshine', {})
end)
