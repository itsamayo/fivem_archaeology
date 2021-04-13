# FiveM - Archeology (no framework)
## Description
An archeology activity for players. Using a specific tool, players can dig for rare items. Only certain grounds can be dug up. Item rarity is effected by the type of ground (Currently configured to accept most natural ground types)

## Configuration
* Set min and max task times
* Configure/Add/Remove items that are to be found + their rarity
* Configure/Add/Remove the diggable ground hashes + their respective impact on rarity
* Configure the distance between each spot that gets dug up by a player (player only current session only, not shared server side)

## Notes
* You can set up the `np-archeology:givePlayerFossil` server event in `server.lua` to work with your backend should you want to
* If you do decide to set `Config.UseDBItems` to true in `config.lua` then make sure all items in `Config.RareItems` exist in your DB
* If you do decide to set `Config.RequiresTools` to true in `config.lua` then make the `Config.RequiredTool.item` exists in your DB

## Updates for later maybe
* A selling point for items - not included due to shops/selling/buying etc usually covered by an existing framework
* Server side dig sites
* More ground hashes + more range on rarity impact