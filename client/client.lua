local RSGCore = exports['rsg-core']:GetCoreObject()
local still = 0
local actualBrewingTime = 0
local timeToBrew = 0
local actualBrewingMoonshine = ""
local getMoonshineMenu = false
local isBrewing = false
local isProcessingMash = false
local placedStill = false
local placedBarrel = false
local inplacing = false

-- Notification helper function
local function Notify(message, type)
    lib.notify({
        title = 'Moonshiner',
        description = message,
        type = type or 'inform',
        duration = 5000
    })
end

-- Helper Functions
local function DrawPlacementHelp(x, y, z)
    local onScreen, _x, _y = GetScreenCoordFromWorldCoord(x, y, z)
    
    -- Draw background box
    DrawSprite("generic_textures", "hud_menu_4a", _x, _y, 0.28, 0.06, 0.0, 0, 0, 0, 180, false)
    
    -- Draw title
    SetTextScale(0.35, 0.35)
    SetTextFontForCurrentCommand(6)
    SetTextColor(255, 215, 0, 255)
    local titleStr = CreateVarString(10, "LITERAL_STRING", "SETTING UP THE OPERATION")
    SetTextCentre(1)
    DisplayText(titleStr, _x, _y - 0.025)
    
    -- Draw instructions
    SetTextScale(0.28, 0.28)
    SetTextFontForCurrentCommand(1)
    SetTextColor(255, 255, 255, 255)
    local instructStr = CreateVarString(10, "LITERAL_STRING", "[ENTER] Set It Down  |  [BACKSPACE] Not Here")
    SetTextCentre(1)
    DisplayText(instructStr, _x, _y + 0.005)
end

local function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = GetScreenCoordFromWorldCoord(x, y, z)
    SetTextScale(0.35, 0.35)
    SetTextFontForCurrentCommand(1)
    SetTextColor(255, 255, 255, 215)
    local str = CreateVarString(10, "LITERAL_STRING", text)
    SetTextCentre(1)
    DisplayText(str, _x, _y)
end

local function round(num, idp)
    local mult = 10^(idp or 0)
    return math.floor(num * mult + 0.5) / mult
end

-- Update Props from Server
CreateThread(function()
    while true do
        Wait(1000)
        TriggerServerEvent("rsg-moonshiner:server:updateProps")
    end
end)

-- Open Still Menu
function OpenStillMenu()
    print("Moonshiner: Opening Still Menu")
    local stillMenu = {}
    
    -- Add moonshine recipes
    for k, v in pairs(Config.moonshine) do
        local itemsText = ""
        for itemName, itemCount in pairs(v.items) do
            itemsText = itemsText .. itemCount .. "x " .. itemName .. " "
        end
        
        table.insert(stillMenu, {
            title = v.label,
            description = "Required: " .. itemsText,
            icon = 'whiskey-glass',
            onSelect = function()
                print("Moonshiner: Selected", v.label)
                TriggerEvent('rsg-moonshiner:client:startBrewing', {moonshine = k, data = v})
            end
        })
    end
    
    -- Add remove still option
    table.insert(stillMenu, {
        title = "Remove Still",
        description = "Pick up the still",
        icon = 'hand-holding',
        onSelect = function()
            TriggerEvent('rsg-moonshiner:client:removeStill')
        end
    })
    
    lib.registerContext({
        id = 'still_menu',
        title = 'Moonshine Still',
        options = stillMenu
    })
    
    lib.showContext('still_menu')
end

-- Open Barrel Menu
function OpenBarrelMenu()
    local barrelMenu = {}
    
    -- Add mash recipes
    for k, v in pairs(Config.mashes) do
        local itemsText = ""
        for itemName, itemCount in pairs(v.items) do
            itemsText = itemsText .. itemCount .. "x " .. itemName .. " "
        end
        
        table.insert(barrelMenu, {
            title = v.label,
            description = "Required: " .. itemsText,
            icon = 'mortar-pestle',
            onSelect = function()
                TriggerEvent('rsg-moonshiner:client:startMash', {mash = k, data = v})
            end
        })
    end
    
    -- Add remove barrel option
    table.insert(barrelMenu, {
        title = "Remove Barrel",
        description = "Pick up the barrel",
        icon = 'hand-holding',
        onSelect = function()
            TriggerEvent('rsg-moonshiner:client:removeBarrel')
        end
    })
    
    lib.registerContext({
        id = 'barrel_menu',
        title = 'Mash Barrel',
        options = barrelMenu
    })
    
    lib.showContext('barrel_menu')
end

-- Place Prop
RegisterNetEvent('rsg-moonshiner:client:placeProp', function(propName)
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local heading = GetEntityHeading(playerPed)
    local object = GetHashKey(propName)
    
    if not HasModelLoaded(object) then
        RequestModel(object)
        while not HasModelLoaded(object) do
            Wait(1)
        end
    end
    
    inplacing = true
    local tempObj = CreateObject(object, coords.x, coords.y, coords.z, false, false, false)
    SetEntityHeading(tempObj, heading)
    SetEntityAlpha(tempObj, 150, false)
    
    local placing = true
    while placing do
        Wait(5)
        local newCoords = GetEntityCoords(playerPed)
        local newHeading = GetEntityHeading(playerPed)
        local forward = GetEntityForwardVector(playerPed)
        local objCoords = vector3(newCoords.x + forward.x * 2.0, newCoords.y + forward.y * 2.0, newCoords.z)
        
        SetEntityCoords(tempObj, objCoords.x, objCoords.y, objCoords.z, false, false, false, false)
        SetEntityHeading(tempObj, newHeading)
        PlaceObjectOnGroundProperly(tempObj)
        
        -- Draw styled help text
        DrawPlacementHelp(objCoords.x, objCoords.y, objCoords.z + 1.5)
        
        if IsControlJustReleased(0, 0xC7B5340A) then -- ENTER
            local finalCoords = GetEntityCoords(tempObj)
            DeleteObject(tempObj)
            
            if lib.progressBar({
                duration = 8000,
                label = 'Setting up ' .. (propName == Config.brewProp and 'moonshine still' or 'mash barrel') .. '...',
                useWhileDead = false,
                canCancel = false,
                disable = {
                    move = true,
                    car = true,
                    combat = true
                },
                anim = {
                    dict = 'amb_work@world_human_box_pickup@1@male_a@stand_exit_withprop',
                    clip = 'exit_front',
                    flag = 1
                }
            }) then
                TriggerServerEvent('rsg-moonshiner:server:placeProp', propName, finalCoords.x, finalCoords.y, finalCoords.z)
                Notify('You set up the ' .. (propName == Config.brewProp and 'moonshine still' or 'mash barrel'), 'success')
            end
            
            placing = false
            inplacing = false
        end
        
        if IsControlJustReleased(0, 0x156F7119) then -- BACKSPACE
            DeleteObject(tempObj)
            TriggerServerEvent('rsg-moonshiner:server:givePropBack', propName)
            placing = false
            inplacing = false
        end
    end
end)

-- Remove Still
RegisterNetEvent('rsg-moonshiner:client:removeStill', function()
    local coords = GetEntityCoords(PlayerPedId())
    TriggerServerEvent('rsg-moonshiner:server:getCoordsId', coords.x, coords.y, coords.z)
end)

-- Remove Barrel
RegisterNetEvent('rsg-moonshiner:client:removeBarrel', function()
    local coords = GetEntityCoords(PlayerPedId())
    TriggerServerEvent('rsg-moonshiner:server:getCoordsId', coords.x, coords.y, coords.z)
end)

-- Delete Prop
RegisterNetEvent('rsg-moonshiner:client:deleteProp', function(id, object, xpos, ypos, zpos)
    local playerPed = PlayerPedId()
    local prop = GetClosestObjectOfType(xpos, ypos, zpos, 1.0, GetHashKey(object), false, false, false)
    
    if lib.progressBar({
        duration = 5000,
        label = 'Removing...',
        useWhileDead = false,
        canCancel = false,
        disable = {
            move = true,
            car = true,
            combat = true
        },
        anim = {
            dict = 'amb_work@world_human_box_pickup@1@male_a@stand_exit_withprop',
            clip = 'exit_front'
        }
    }) then
        DeleteObject(prop)
        TriggerServerEvent('rsg-moonshiner:server:removeProp', id)
        TriggerServerEvent('rsg-moonshiner:server:givePropBack', object)
        Notify('You picked up the ' .. (object == Config.brewProp and 'still' or 'barrel'), 'success')
    end
end)

-- Start Mash Production
RegisterNetEvent('rsg-moonshiner:client:startMash', function(data)
    TriggerServerEvent('rsg-moonshiner:server:checkMashItems', data.mash, data.data)
end)

RegisterNetEvent('rsg-moonshiner:client:processMash', function(mash, mashData)
    isProcessingMash = true
    local playerPed = PlayerPedId()
    local mashTime = mashData.mashTime * 60 * 1000
    
    if lib.progressBar({
        duration = mashTime,
        label = 'Producing ' .. mashData.label,
        useWhileDead = false,
        canCancel = false,
        disable = {
            move = true,
            car = true,
            combat = true
        },
        anim = {
            dict = 'amb_work@world_human_box_pickup@1@male_a@stand_exit_withprop',
            clip = 'exit_front'
        }
    }) then
        TriggerServerEvent('rsg-moonshiner:server:giveMash', mash, mashData)
    end
    
    isProcessingMash = false
end)

-- Start Brewing
RegisterNetEvent('rsg-moonshiner:client:startBrewing', function(data)
    print("Moonshiner: startBrewing event triggered", data.moonshine)
    TriggerServerEvent('rsg-moonshiner:server:checkMoonshineItems', data.moonshine, data.data)
end)

RegisterNetEvent('rsg-moonshiner:client:processBrewing', function(moonshine, moonshineData)
    if isBrewing then
        Notify('Already brewing moonshine!', 'error')
        return
    end
    
    print("Moonshiner Client: Starting brewing process")
    isBrewing = true
    local brewTime = moonshineData.brewTime * 60 * 1000
    
    if lib.progressBar({
        duration = brewTime,
        label = 'Brewing ' .. moonshineData.label,
        useWhileDead = false,
        canCancel = false,
        disable = {
            move = true,
            car = true,
            combat = true
        },
        anim = {
            dict = 'script_re@moonshine_camp@player_put_in_herbs',
            clip = 'put_in_still',
            flag = 1
        }
    }) then
        print("Moonshiner Client: Brewing complete, giving moonshine")
        isBrewing = false
        TriggerServerEvent('rsg-moonshiner:server:giveMoonshine', moonshine, moonshineData)
    else
        isBrewing = false
        Notify('Brewing cancelled!', 'error')
    end
end)

-- Replace Props (sync with other players)
RegisterNetEvent('rsg-moonshiner:client:replaceProps', function(object, x1, y1, z1, actif)
    local prop = GetClosestObjectOfType(x1, y1, z1, 1.0, GetHashKey(object), false, false, false)
    local ped = PlayerPedId()
    local radius = 100.0
    local entityCoords = GetEntityCoords(ped, true)
    local distance = #(vector3(x1, y1, z1) - entityCoords)
    
    if distance <= radius then
        if not DoesObjectOfTypeExistAtCoords(x1, y1, z1, 1.0, GetHashKey(object), false) then
            if actif == 1 then
                DeleteObject(prop)
                local tempObj = CreateObject(GetHashKey(object), x1, y1, z1, false, false, false)
                PlaceObjectOnGroundProperly(tempObj)
                
                -- Add ox_target to the prop
                if object == Config.brewProp then
                    exports.ox_target:addLocalEntity(tempObj, {
                        {
                            name = 'moonshine_still',
                            label = 'Use Moonshine Still',
                            icon = 'fa-solid fa-flask',
                            distance = 2.5,
                            onSelect = function()
                                OpenStillMenu()
                            end
                        }
                    })
                elseif object == Config.mashProp then
                    exports.ox_target:addLocalEntity(tempObj, {
                        {
                            name = 'mash_barrel',
                            label = 'Use Mash Barrel',
                            icon = 'fa-solid fa-barrel-oil',
                            distance = 2.5,
                            onSelect = function()
                                OpenBarrelMenu()
                            end
                        }
                    })
                end
            end
        end
    end
end)

RegisterNetEvent('rsg-moonshiner:client:getId', function(x1, y1, z1, object, x2, y2, z2)
    local coords = GetEntityCoords(PlayerPedId())
    local distance = #(coords - vector3(x2, y2, z2))
    
    if distance <= 2 then
        TriggerServerEvent("rsg-moonshiner:server:getObjectId", object, x2, y2, z2)
    end
end)

-- Drunk System
local isDrunk = false
local drunkLevel = 0

RegisterNetEvent('rsg-moonshiner:client:drinkMoonshine', function(level)
    print("Moonshiner Client: Drink event received, level:", level)
    local playerPed = PlayerPedId()
    
    -- Drinking animation
    local prop = CreateObject(`p_bottleJD01x`, GetEntityCoords(playerPed), true, true, false, false, true)
    AttachEntityToEntity(prop, playerPed, GetEntityBoneIndexByName(playerPed, "PH_R_HAND"), 0.0, 0.0, 0.04, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
    
    if not IsPedOnMount(playerPed) and not IsPedInAnyVehicle(playerPed) then
        lib.requestAnimDict('mech_inventory@drinking@bottle_cylinder_d1-3_h30-5_neck_a13_b2-5')
        TaskPlayAnim(playerPed, 'mech_inventory@drinking@bottle_cylinder_d1-3_h30-5_neck_a13_b2-5', 'uncork', 8.0, -8.0, 500, 31, 0, true, false, false)
        Wait(500)
        TaskPlayAnim(playerPed, 'mech_inventory@drinking@bottle_cylinder_d1-3_h30-5_neck_a13_b2-5', 'chug_a', 8.0, -8.0, 5000, 31, 0, true, false, false)
        Wait(5000)
    else
        TaskItemInteraction_2(playerPed, 1737033966, prop, `p_bottleJD01x_ph_r_hand`, `DRINK_Bottle_Cylinder_d1-55_H18_Neck_A8_B1-8_QUICK_RIGHT_HAND`, true, 0, 0)
        Wait(4000)
    end
    
    ClearPedTasks(playerPed)
    if DoesEntityExist(prop) then
        DetachEntity(prop, true, true)
        DeleteObject(prop)
    end
    
    drunkLevel = level
    isDrunk = true
    
    print("Moonshiner Client: Applying drunk effects for level", level)
    
    -- Apply drunk effects based on level
    if level == 1 then
        print("Moonshiner Client: Level 1 drunk effects")
        Notify('That\'s some strong moonshine! *hic*', 'inform')
        
        Citizen.InvokeNative(0x406CCF555B04FAD3, playerPed, 1, 0.3)
        AnimpostfxPlay("PlayerDrunk01")
        
    elseif level == 2 then
        print("Moonshiner Client: Level 2 drunk effects")
        Notify('You\'re feeling pretty drunk... *hic*', 'inform')
        
        Citizen.InvokeNative(0x406CCF555B04FAD3, playerPed, 1, 0.6)
        AnimpostfxPlay("PlayerDrunk01")
        
    elseif level >= 3 then
        print("Moonshiner Client: Level 3+ drunk effects - BLACKOUT!")
        Notify('Everything is spinning...', 'error')
        
        Citizen.InvokeNative(0x406CCF555B04FAD3, playerPed, 1, 0.95)
        AnimpostfxPlay("PlayerDrunk01")
        
        Wait(3000)
        
        -- Pass out animation
        lib.requestAnimDict('amb_misc@world_human_vomit@male_a@idle_b')
        TaskPlayAnim(playerPed, 'amb_misc@world_human_vomit@male_a@idle_b', 'idle_f', 8.0, -8.0, 3000, 31, 0, true, false, false)
        Wait(3000)
        ClearPedTasks(playerPed)
        
        -- Sleep animation
        lib.requestAnimDict('amb_rest@world_human_sleep_ground@arm@male_b@idle_b')
        TaskPlayAnim(playerPed, 'amb_rest@world_human_sleep_ground@arm@male_b@idle_b', 'idle_f', 8.0, -8.0, 5000, 1, 0, true, false, false)
        
        -- Black out and teleport to Rhodes
        print("Moonshiner Client: Starting blackout sequence")
        AnimpostfxPlay("PlayerPassOut")
        DoScreenFadeOut(2000)
        Wait(2000)
        
        print("Moonshiner Client: Screen is black, teleporting")
        ClearPedTasks(playerPed)
        Citizen.InvokeNative(0x58F7DB5BD8FA2288, playerPed)
        
        -- Rhodes camp location
        local rhodesCoords = vector4(1225.0, -1305.0, 76.0, 0.0)
        print("Moonshiner Client: Teleporting to Rhodes", rhodesCoords)
        SetEntityCoords(playerPed, rhodesCoords.x, rhodesCoords.y, rhodesCoords.z, false, false, false, false)
        SetEntityHeading(playerPed, rhodesCoords.w)
        
        Wait(1000)
        
        -- Wake up
        print("Moonshiner Client: Waking up")
        Citizen.InvokeNative(0x406CCF555B04FAD3, playerPed, 1, 0.5)
        AnimpostfxPlay("PlayerWakeUp")
        DoScreenFadeIn(2000)
        Wait(2000)
        AnimpostfxStop("PlayerWakeUp")
        
        Notify('You wake up near Rhodes... What happened?!', 'error')
        
        drunkLevel = 0
        
        -- Groggy effect
        Wait(30000)
        AnimpostfxStop("PlayerDrunk01")
        Citizen.InvokeNative(0x406CCF555B04FAD3, playerPed, 1, 0.0)
        isDrunk = false
        Notify('You\'re finally sober...', 'success')
    end
    
    -- Clear drunk effects after 60 seconds (if not level 3+)
    if level < 3 then
        CreateThread(function()
            Wait(60000)
            if drunkLevel == level then
                print("Moonshiner Client: Sobering up...")
                AnimpostfxStop("PlayerDrunk01")
                Citizen.InvokeNative(0x406CCF555B04FAD3, playerPed, 1, 0.0)
                isDrunk = false
                Notify('You\'re feeling sober now', 'success')
            end
        end)
    end
end)
