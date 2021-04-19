-- RNG for rare finds is currently using default seed
-- To set a more "real" random seed before generating random numbers we could use math.randomseed(os.time())
-- Leaving as is for simplicity (will always give pseudo-random numbers)

local inScenario = false
local ableToDig = false
local oldLocations = {} -- This could (maybe should) be moved to a server sided

-- Dig via command
RegisterCommand("dig", function()
    StartDigging()
end, false)

-- Net event if you want to call it from a usable item
RegisterNetEvent('activity_archaeology:dig')
AddEventHandler('activity_archaeology:dig', function()
	StartDigging()
end)

-- UTILITY METHODS

-- Main dig method
function StartDigging()
    Citizen.CreateThread(function()
        local playerServerId = GetPlayerServerId(PlayerId())
        -- Check if the player has the required tools if necessary        
        if Config.UseNoPixelExports then            
            local hasItem = exports["np-activities"]:hasInventoryItem(playerServerId, Config.RequiredTool.item)
            if hasItem then
                ableToDig = true
            else 
                ableToDig = false
            end           
        else
            ableToDig = true
        end
        if ableToDig then
            local canStart = false
            if Config.UseNoPixelExports then
                canStart = exports["np-activities"]:canDoActivity('activity_archaeology', playerServerId)
            else
                canStart = true
            end                    
            if canStart then
                -- Check if the ground is compatibile before digging
                local diggable, message, location, _, ground = GetDiggingLocation()                     
                if diggable then                                        
                    Notification(playerServerId, 'You start digging')                    
                    table.insert(oldLocations, location)                
                    local timeToStart = GetGameTimer()
                    local timeToComplete = Config.DigTimeMax
                    if Config.RandomTime then
                        timeToComplete = math.random(Config.DigTimeMin, Config.DigTimeMax) -- should use math.randomseed(os.time()) to get around repetiveness but we'll keep it simple for now                                              
                    end                    
                    exports["np-activities"]:activityInProgress('activity_archaeology', playerServerId, timeToComplete)
                    RunScenario(Config.Scenario)
                    while GetGameTimer() <= timeToStart + timeToComplete do
                        Citizen.Wait(0)
                    end
                    if inScenario then
                        ClearPedTasks(PlayerPedId())
                        local val = math.random(1, Config.Ground[ground]) -- should use math.randomseed(os.time()) to get around repetiveness but we'll keep it simple for now                                            
                        local reward = 'nothing'                                
                        for i=1, #Config.RareItems, 1 do                          
                            if val <= Config.RareItems[i].value then
                                reward = Config.RareItems[i]
                                break
                            end
                        end
                        if reward ~= 'nothing' then
                            exports["np-activities"]:giveInventoryItem(playerServerId, reward.item, 1)
                            Notification(playerServerId, 'You found a ' .. reward.label)            
                        else
                            Notification(playerServerId, 'You found nothing')    
                        end                    
                    end
                    exports["np-activities"]:activityCompleted('activity_archaeology', playerServerId, true) -- not sure if 4th param is required for success?
                    inScenario = false
                else -- If it's not compatible ground then notify the player
                    Notification(playerServerId, message)
                end  
            else
                -- debugging
                -- print('np-activities returned false')
            end            
        else
            Notification(playerServerId, 'You need a ' .. Config.RequiredTool.label)
        end              
    end)
end

-- Scenario player
function RunScenario(name)
    local playerPed = PlayerPedId()
    ClearPedTasks(playerPed)
    SetCurrentPedWeapon(playerPed, `WEAPON_UNARMED`)    
    TaskStartScenarioInPlace(playerPed, name, 0, true)
    inScenario = true
end

-- Check ground level
function CheckLevel(surfaceNormal)
    local x = math.abs(surfaceNormal.x)
    local y = math.abs(surfaceNormal.y)
    local z = math.abs(surfaceNormal.z)
    return (
        x <= Config.MaxGroundAngle
        and
        y <= Config.MaxGroundAngle
        and
        z >= 1.0 - Config.MaxGroundAngle
    )
end

-- Check ground compatibility 
function GetDiggingLocation()    
    local ped = PlayerPedId()

    -- Obviously no digging in cars
    if IsPedInAnyVehicle(ped) then
        return false, 'Unable to dig inside vehicle'
    end

    local playerCoord = GetEntityCoords(ped)
    local target = GetOffsetFromEntityInWorldCoords(ped, vector3(0,2,-3)) -- Tried and tested vector
    local testRay = StartShapeTestRay(playerCoord, target, 17, ped, 7) -- This values 17 and 7 are kind of just tried and tested to work nicely
    local _, hit, hitLocation, surfaceNormal, material, _ = GetShapeTestResultEx(testRay)    
    
    -- Initial check, if hit is 0 just escape
    if hit == 1 then 
        if Config.Ground[material] then      
            -- First check if location has already been dug up
            for i, location in ipairs(oldLocations) do
                local distanceToOld = #(playerCoord - location)
                if distanceToOld <= Config.MinDistanceBetweenSites then
                    return false, 'You already dug here, try somewhere else', hitLocation, surfaceNormal, material
                end                    
            end    
            -- Check to see ground angle    
            if CheckLevel(surfaceNormal) then                  
                return true,'OK', hitLocation, surfaceNormal, material            
            else                
                return false, 'Too steep to dig', hitLocation, surfaceNormal, material
            end
        else           
            return false, 'Ground not suitable for digging', hitLocation, surfaceNormal, material
        end
    else        
        return false, 'Too steep to dig', hitLocation, surfaceNormal, material
    end    
end

-- Send notification
function Notification(playerServerId, msg)
    if Config.UseNoPixelExports then
        -- NP notification
        exports["np-activities"]:notifyPlayer(playerServerId, msg)
    else
        -- Native notification        
        SetNotificationTextEntry("STRING")
        AddTextComponentString(msg)
        DrawNotification(false, false)
    end
end