--[[
----------------------------------------------------------------------------------------------------
READ ME:
This file documents the changes made by KoreanWaffles. I have been given permission by the original author, Luis95R, 
to modify this mod to add in new content that the Emerville staff team has been working on. The contents of this file 
have been loaded into modmain.lua via modimport.


CHANGE LOG:
[X] Added dolls for Winona, Wormwood, and Wortox (scripts/prefabs/dst_characterdoll.lua) (Search "Character Dolls")
-- The original mod uses the dolls from the Don't Starve Dolls mod as a special reward for players who collect 6 unique Magical Dolls. 
However, the Don't Starve Dolls mod is outdated and is missing dolls for every character since Winona was released.
Credits to ADHDkittin for drawing the animations for these two dolls!

[X] Fixed the Vacuum Chest not picking up items properly
-- The Vacuum Chest wouldn't pick up items if a Casino or Irreplaceable item (e.g. Chester's Eyebone) was nearby, or not pick up stackable items 
that were already in the Vacuum Chest if the chest had no empty slots, even if the slot with the stackable item wasn't fully stacked. 
I had to modify scripts/prefabs/vacuum_chest.lua directly.

[X] Added Antlion Figure Sketch to Antlion's drops (Search "Antlion")
-- The Emerville Achievements mod overrides the antlion.lua file in order to add the thermal stone feeding achievement. 
However, the file is outdated and is missing the Antlion Figure Sketch added during the May QoL update, so I added it in a postinit.

[X] Removed file scripts/prefabs/bat.lua
-- The original mod overrode the bat.lua file. I found no functional differences between this mod's version of the file, 
and Klei's version except that the mod version's is outdated and the drop chance of Batalisk Wings is still 15% when it should be 25%, 
so I removed this mod's bat.lua file. I commented out bat.lua from the PrefabFiles table as well. What it's supposed to do is 
prevent bats from attacking you if you're wearing the Cowl, but the Cowl doesn't give you the "prebat" tag anyway. 
The file scripts/prefab/shadowbatminion.lua also overrides the "bat" loot table. I changed the name of its loot table to "shadowbatminion" 
so batilisks preserve their vanilla drops.

[X] Removed file scripts/prefabs/staff.lua & added staff changes in postinits (Search "Staves")
-- The original mod overrode the staff.lua file in order to make changes to the Fire Staff and Deconstruction Staff to prevent them 
from targetting structures as an anti-grief measure. However, because the file was overrode, updates such as new staff skins and 
other changes Klei made were also overrode, causing conflicts such as missing skin animations when staves were held. 
I added the changes in postinits to preserve forward compatability.

----------------------------------------------------------------------------------------------------
]]

--------------------------------------------------
--local variables
local TUNING = GLOBAL.TUNING
local STRINGS = GLOBAL.STRINGS
local FUELTYPE = GLOBAL.FUELTYPE
local AllRecipes = GLOBAL.AllRecipes
local Vector3 = GLOBAL.Vector3
local SpawnPrefab = GLOBAL.SpawnPrefab
local TheNet = GLOBAL.TheNet
--------------------------------------------------


--------------------------------------------------
-- Character Dolls -- Moved to Modmain.lua -Luis
--------------------------------------------------
--The rest of the dolls' data is handled by their respective prefab files.

--------------------------------------------------
-- Antlion -- Patched by Achievement Mod Update -Luis
--------------------------------------------------
--[[AddPrefabPostInit("antlion", function(inst)
    if not TheNet:GetIsServer() then return inst end
    inst.components.lootdropper:AddChanceLoot("chesspiece_antlion_sketch", 1)
end)]]

--------------------------------------------------
-- Staves --
--------------------------------------------------
--I could just replace the staff.lua fire and modify all the functions directly, but that would remove forward compatability.

--Removed scripts/prefabs/staff.lua and added the Emerville changes to the Fire Staff and Deconstruction Staff in postinits, 
--thus preserving new changes Klei made such as changes to the Telelocator Staff with the introduction of Turn of Tides and fixing skin animations.

AddPrefabPostInit("firestaff", function(inst)
    if not GLOBAL.TheWorld.ismastersim then
        return inst
    end
    
	local _onattack_red = inst.components.weapon.onattack

	local function OnAttack(inst, attacker, target, skipsanity)
		if target:HasTag("structure") then
			return
		end
		_onattack_red(inst, attacker, target, skipsanity)
	end

	inst.components.weapon.onattack = OnAttack
end)

AddPrefabPostInit("greenstaff", function(inst)
    if not GLOBAL.TheWorld.ismastersim then
        return inst
    end

	local _destroystructure = inst.components.spellcaster.spell

	local function DestroyStructure(staff, target)
		if target:HasTag("structure") or target:HasTag("currency") then
			local caster = staff.components.inventoryitem.owner
			if caster.components.talker then
				caster.components.talker:Say("The Emerville government is looking at me suspiciously...")
			end
			return
		end
		_destroystructure(staff, target)
	end

	inst.components.spellcaster.spell = DestroyStructure
end)
--------------------------------------------------

--KoreanWaffles
