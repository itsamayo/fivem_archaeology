-- Only called from client side if Config.UseDBItems is set to true
RegisterNetEvent('np-archeology:givePlayerFossil')
AddEventHandler ('np-archeology:givePlayerFossil',function(reward)
    -- Add the item to the players inv here
    -- let's just print it out should you want to see the item name coming through
    print(reward)
end)