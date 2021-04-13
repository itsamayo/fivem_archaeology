-- RNG for rare finds is currently using default seed
-- To set a more "real" random seed before generating random numbers we could use math.randomseed(os.time())
-- Leaving as is for simplicity (will always give pseudo-random numbers)

local inScenario = false
local ableToDig = false
local oldLocations = {}

RegisterCommand("dig", function()
	Citizen.CreateThread(function()
        -- Check if the player has the required tools if necessary        
        if Config.RequiresTools then
            -- Handle your custom item checking here
            -- Check for Config.RequiredTool.item
        else
            ableToDig = true
        end
        if ableToDig then
            -- Check if the ground is compatibile before digging
            local diggable, message, location, _, ground = getDiggingLocation()                        
            if diggable then
                table.insert(oldLocations, location)                
                local begin = GetGameTimer()
                local finish = math.random(Config.DigTimeMin, Config.DigTimeMax)        
                RunScenario(Config.Scenario)
                while GetGameTimer() <= begin + finish do
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
                        GivePlayerFossil(reward.item)                   
                        notification('You found 1x ' .. reward.label)            
                    else
                        notification('You found nothing')    
                    end                    
                end
                inScenario = false
            else -- If it's not compatible ground then notify the player
                notification(message)
            end  
        else
            notification('You need a ' .. Config.RequiredTool.label)
        end
              
    end)
end, false)

-- UTILITY METHODS

-- Send notification
function notification(msg)
    if Config.UseCustomNotification then
        -- Custom notification
    else
        -- Chat notification
        local fal = 'Archeology'        
        TriggerEvent('chat:addMessage', {
            template = '<div style="padding: 8px; margin: 8px; background-color: rgba(25, 214, 220, 0.9); border-radius: 25px;">{0} : {1}</div>',
            args = { fal, msg }
        })
    end
end

-- Reward the player
function GivePlayerFossil(reward)
    if Config.UseDBItems then
        TriggerServerEvent('np-archeology:givePlayerFossil', reward)
    end
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
function checkLevel(surfaceNormal)
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
function getDiggingLocation()    
    local ped = PlayerPedId()
    local playerCoord = GetEntityCoords(ped)
    local target = GetOffsetFromEntityInWorldCoords(ped, vector3(0,2,-3)) -- Tried and tested vector
    local testRay = StartShapeTestRay(playerCoord, target, 17, ped, 7) -- This values 17 and 7 are kind of just tried and tested to work nicely
    local _, hit, hitLocation, surfaceNormal, material, _ = GetShapeTestResultEx(testRay)    

    -- Obviously no digging in cars
    if IsPedInAnyVehicle(ped) then
        return false, 'Unable to dig inside vehicle'
    end
    
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
            if checkLevel(surfaceNormal) then                  
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