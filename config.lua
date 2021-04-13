Config = {
    -- Digging configuration
    Scenario = 'WORLD_HUMAN_GARDENER_PLANT',
    DigTimeMin = 10000, -- How long should it take at least to dig something up? 1000 = 1 second
    DigTimeMax = 20000, -- How long should it take at most to dig something up? 1000 = 1 second
    MinDistanceBetweenSites = 2.5, -- Distance between each dig site (player only, not shared) - 1.0 = 1 vector unit
    RareItems = {
        -- Must be arranged in asc order 
        -- Range is from 0 to 1000
        -- The lower the value, the rarer the item             
        [1] = { value = 10, item = 'dinoegg', label = "dinosaur egg" },
        [2] = { value = 30, item = 'pricelessjewel', label = "priceless jewel" },
        [3] = { value = 50, item = 'mythicfossil', label = "mythic fossil" },
        [4] = { value = 80, item = 'rarefossil', label = "rare fossil" },        
        [5] = { value = 120, item = 'oldnecklace', label = "old necklace" },
        [6] = { value = 150, item = 'skull', label = "skull" },
        [7] = { value = 180, item = 'oldbracelet', label = "old bracelet" }
    },
    MaxGroundAngle = 0.6, -- Ground angle before it becomes undiggable (honestly just to avoid exploiting odd places)
    Ground = {
        -- Define ground hashes where digging can take place     
        -- Floating point values define 2nd value in RNG for reward, lower values increases the odds   
        [2409420175] = 1000,
        [3833216577] = 1000,
        [1333033863] = 1000,
        [4170197704] = 1000,
        [1109728704] = 1000,
        [2352068586] = 1000,
        [581794674] = 1000,
        [-461750719] = 1000,
        [-1286696947] = 1000,
        [3008270349] = 850,
        [223086562] = 850,
        [3594309083] = 850,
        [2461440131] = 850,
        [1144315879] = 850,
        [2128369009] = 850        
    },

    -- Plug n play configuration
    UseCustomNotification = false, -- Only enable if you plan on having the notifications use something other than chat
    UseDBItems = false, -- Only enable if you plan on having items be added to DB i.e for selling as part of the "job"
    RequiresTools = false, -- Only enable if you plan on forcing players to have an item on hand
    RequiredTool = { item = 'trowel', label = 'Trowel' } -- An item that should exist in your DB if RequiresTools is set to true
}