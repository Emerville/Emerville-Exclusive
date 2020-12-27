--[[
----------------------------------------------------------------------------------------------------
READ ME:
This file documents the changes made by KoreanWaffles. I have been given permission by the original author, Luis95R, to modify this mod to add in new content that the Emerville staff team has been working on. The contents of this file have been loaded into modmain.lua via modimport.


CHANGE LOG:
[X] Added dolls for Winona, Wormwood, and Wortox (scripts/prefabs/dst_characterdoll.lua) (Search "Character Dolls")
-- The original mod uses the dolls from the Don't Starve Dolls mod as a special reward for players who collect 6 unique Magical Dolls. However, the Don't Starve Dolls mod is outdated and is missing dolls for every character since Winona was released.
Credits to ADHDkittin for drawing the animations for these two dolls!

[X] Fixed the Vacuum Chest not picking up items properly
-- The Vacuum Chest wouldn't pick up items if a Casino or Irreplaceable item (e.g. Chester's Eyebone) was nearby, or not pick up stackable items that were already in the Vacuum Chest if the chest had no empty slots, even if the slot with the stackable item wasn't fully stacked. I had to modify scripts/prefabs/vacuum_chest.lua directly.

[X] Added Antlion Figure Sketch to Antlion's drops (Search "Antlion")
-- The Emerville Achievements mod overrides the antlion.lua file in order to add the thermal stone feeding achievement. However, the file is outdated and is missing the Antlion Figure Sketch added during the May QoL update, so I added it in a postinit.

[X] Removed file scripts/prefabs/bat.lua
-- The original mod overrode the bat.lua file. I found no functional differences between this mod's version of the file, and Klei's version except that the mod version's is outdated and the drop chance of Batalisk Wings is still 15% when it should be 25%, so I removed this mod's bat.lua file. I commented out bat.lua from the PrefabFiles table as well. What it's supposed to do is prevent bats from attacking you if you're wearing the Cowl, but the Cowl doesn't give you the "prebat" tag anyway. The file scripts/prefab/shadowbatminion.lua also overrides the "bat" loot table. I changed the name of its loot table to "shadowbatminion" so batilisks preserve their vanilla drops.

[X] Removed file scripts/prefabs/staff.lua & added staff changes in postinits (Search "Staves")
-- The original mod overrode the staff.lua file in order to make changes to the Fire Staff and Deconstruction Staff to prevent them from targetting structures as an anti-grief measure. However, because the file was overrode, updates such as new staff skins and other changes Klei made were also overrode, causing conflicts such as missing skin animations when staves were held. I added the changes in postinits to preserve forward compatability.

----------------------------------------------------------------------------------------------------
]]

--------------------------------------------------
-- Upvalue Hacker --
--------------------------------------------------
local assert = GLOBAL.assert
local debug = GLOBAL.debug

local UpvalueHacker = {}

local function GetUpvalueHelper(fn, name)
	local i = 1
	while debug.getupvalue(fn, i) and debug.getupvalue(fn, i) ~= name do
		i = i + 1
	end
	local name, value = debug.getupvalue(fn, i)
	return value, i
end

UpvalueHacker.GetUpvalue = function(fn, ...)
	local prv, i, prv_var = nil, nil, "(the starting point)"
	for j,var in ipairs({...}) do
		assert(type(fn) == "function", "We were looking for "..var..", but the value before it, "
			..prv_var..", wasn't a function (it was a "..type(fn)
			.."). Here's the full chain: "..table.concat({"(the starting point)", ...}, ", "))
		prv = fn
		prv_var = var
		fn, i = GetUpvalueHelper(fn, var)
	end
	return fn, i, prv
end

UpvalueHacker.SetUpvalue = function(start_fn, new_fn, ...)
	local _fn, _fn_i, scope_fn = UpvalueHacker.GetUpvalue(start_fn, ...)
	debug.setupvalue(scope_fn, _fn_i, new_fn)
end
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
-- Character Dolls --
--------------------------------------------------
--The rest of the dolls' data is handled by their respective prefab files.

table.insert(PrefabFiles, "dst_winonadoll")
table.insert(PrefabFiles, "dst_wormwooddoll")
table.insert(PrefabFiles, "dst_wortoxdoll_uncorrupted")
AddMinimapAtlas("images/inventoryimages/winonadoll.xml")
AddMinimapAtlas("images/inventoryimages/wormwooddoll.xml")
AddMinimapAtlas("images/inventoryimages/wortoxdoll_uncorrupted.xml")

STRINGS.NAMES.DST_WINONADOLL = "Winona Doll"
STRINGS.NAMES.DST_WORMWOODDOLL = "Wormwood Doll"
STRINGS.NAMES.DST_WORTOXDOLL_UNCORRUPTED = "Uncorrupted Wortox Doll"

STRINGS.CHARACTERS.GENERIC.DESCRIBE.DST_WINONADOLL = "A hard-working doll!"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.DST_WORMWOODDOLL = "A peculiar yet cuddly plant!"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.DST_WORTOXDOLL_UNCORRUPTED = "What a mischievous looking doll!"


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

--Removed scripts/prefabs/staff.lua and added the Emerville changes to the Fire Staff and Deconstruction Staff in postinits, thus preserving new changes Klei made such as changes to the Telelocator Staff with the introduction of Turn of Tides and fixing skin animations.

AddPrefabPostInit("firestaff", function(inst)

    local function onattack_red(inst, attacker, target, skipsanity)

        if target:HasTag("structure") and not (target.components.fueled and target.components.fueled.accepting) then
            return 
        end

        if not skipsanity and attacker ~= nil and attacker.components.sanity ~= nil then
            attacker.components.sanity:DoDelta(-TUNING.SANITY_SUPERTINY)
        end

        attacker.SoundEmitter:PlaySound("dontstarve/wilson/fireball_explo")

        if not target:IsValid() then
            --target killed or removed in combat damage phase
            return
        elseif target.components.burnable ~= nil and not target.components.burnable:IsBurning() then
            if target.components.freezable ~= nil and target.components.freezable:IsFrozen() then
                target.components.freezable:Unfreeze()
            elseif target.components.fueled == nil
                or (target.components.fueled.fueltype ~= FUELTYPE.BURNABLE and
                    target.components.fueled.secondaryfueltype ~= FUELTYPE.BURNABLE) then
                --does not take burnable fuel, so just burn it
                if target.components.burnable.canlight or target.components.combat ~= nil then
                    target.components.burnable:Ignite(true)
                end
            elseif target.components.fueled.accepting then
                --takes burnable fuel, so fuel it
                local fuel = SpawnPrefab("cutgrass")
                if fuel ~= nil then
                    if fuel.components.fuel ~= nil and
                        fuel.components.fuel.fueltype == FUELTYPE.BURNABLE then
                        target.components.fueled:TakeFuelItem(fuel)
                    else
                        fuel:Remove()
                    end
                end
            end
        end

        if target.components.freezable ~= nil then
            target.components.freezable:AddColdness(-1) --Does this break ice staff?
            if target.components.freezable:IsFrozen() then
                target.components.freezable:Unfreeze()
            end
        end

        if target.components.sleeper ~= nil and target.components.sleeper:IsAsleep() then
            target.components.sleeper:WakeUp()
        end

        if target.components.combat ~= nil then
            target.components.combat:SuggestTarget(attacker)
        end

        target:PushEvent("attacked", { attacker = attacker, damage = 0, weapon = inst })
    end

    UpvalueHacker.SetUpvalue(GLOBAL.Prefabs.firestaff.fn, onattack_red, "onattack_red")
end)

AddPrefabPostInit("greenstaff", function(inst)

    local DESTSOUNDS =
    {
        {   --magic
            soundpath = "dontstarve/common/destroy_magic",
            ing = { "nightmarefuel", "livinglog" },
        },
        {   --cloth
            soundpath = "dontstarve/common/destroy_clothing",
            ing = { "silk", "beefalowool" },
        },
        {   --tool
            soundpath = "dontstarve/common/destroy_tool",
            ing = { "twigs" },
        },
        {   --gem
            soundpath = "dontstarve/common/gem_shatter",
            ing = { "redgem", "bluegem", "greengem", "purplegem", "yellowgem", "orangegem" },
        },
        {   --wood
            soundpath = "dontstarve/common/destroy_wood",
            ing = { "log", "boards" },
        },
        {   --stone
            soundpath = "dontstarve/common/destroy_stone",
            ing = { "rocks", "cutstone" },
        },
        {   --straw
            soundpath = "dontstarve/common/destroy_straw",
            ing = { "cutgrass", "cutreeds" },
        },
    }
    local DESTSOUNDSMAP = {}
    for i, v in ipairs(DESTSOUNDS) do
        for i2, v2 in ipairs(v.ing) do
            DESTSOUNDSMAP[v2] = v.soundpath
        end
    end
    DESTSOUNDS = nil

    local function CheckSpawnedLoot(loot)
        if loot.components.inventoryitem ~= nil then
            loot.components.inventoryitem:TryToSink()
        else
            local lootx, looty, lootz = loot.Transform:GetWorldPosition()
            if GLOBAL.ShouldEntitySink(loot, true) or GLOBAL.TheWorld.Map:IsPointNearHole(Vector3(lootx, 0, lootz)) then
                GLOBAL.SinkEntity(loot)
            end
        end
    end

    local function SpawnLootPrefab(inst, lootprefab)
        if lootprefab == nil then
            return
        end

        local loot = SpawnPrefab(lootprefab)
        if loot == nil then
            return
        end

        local x, y, z = inst.Transform:GetWorldPosition()

        if loot.Physics ~= nil then
            local angle = math.random() * 2 * 3.141592
            loot.Physics:SetVel(2 * math.cos(angle), 10, 2 * math.sin(angle))

            if inst.Physics ~= nil then
                local len = loot:GetPhysicsRadius(0) + inst:GetPhysicsRadius(0)
                x = x + math.cos(angle) * len
                z = z + math.sin(angle) * len
            end

            loot:DoTaskInTime(1, CheckSpawnedLoot)
        end

        loot.Transform:SetPosition(x, y, z)

        loot:PushEvent("on_loot_dropped", {dropper = inst})

        return loot
    end

    local function destroystructure(staff, target)
        local recipe = AllRecipes[target.prefab]
        local caster = staff.components.inventoryitem.owner
        if recipe == nil or recipe.no_deconstruction or target:HasTag("structure") or target:HasTag("currency") then
            caster.components.talker:Say("The Emerville government is looking at me suspiciously...")
            --Action filters should prevent us from reaching here normally
            return
        end

        local ingredient_percent =
            (   (target.components.finiteuses ~= nil and target.components.finiteuses:GetPercent()) or
                (target.components.fueled ~= nil and target.components.inventoryitem ~= nil and target.components.fueled:GetPercent()) or
                (target.components.armor ~= nil and target.components.inventoryitem ~= nil and target.components.armor:GetPercent()) or
                1
            ) / recipe.numtogive

        --V2C: Can't play sounds on the staff, or nobody
        --     but the user and the host will hear them!
        local caster = staff.components.inventoryitem.owner

        for i, v in ipairs(recipe.ingredients) do
            if caster ~= nil and DESTSOUNDSMAP[v.type] ~= nil then
                caster.SoundEmitter:PlaySound(DESTSOUNDSMAP[v.type])
            end
            if string.sub(v.type, -3) ~= "gem" or string.sub(v.type, -11, -4) == "precious" then
                --V2C: always at least one in case ingredient_percent is 0%
                local amt = math.max(1, math.ceil(v.amount * ingredient_percent))
                for n = 1, amt do
                    SpawnLootPrefab(target, v.type)
                end
            end
        end

        if caster ~= nil then
            caster.SoundEmitter:PlaySound("dontstarve/common/staff_dissassemble")

            if caster.components.sanity ~= nil then
                caster.components.sanity:DoDelta(-TUNING.SANITY_MEDLARGE)
            end
        end

        staff.components.finiteuses:Use(1)

        if target.components.inventory ~= nil then
            target.components.inventory:DropEverything()
        end

        if target.components.container ~= nil then
            target.components.container:DropEverything()
        end

        if target.components.spawner ~= nil and target.components.spawner:IsOccupied() then
            target.components.spawner:ReleaseChild()
        end

        if target.components.occupiable ~= nil and target.components.occupiable:IsOccupied() then
            local item = target.components.occupiable:Harvest()
            if item ~= nil then
                item.Transform:SetPosition(target.Transform:GetWorldPosition())
                item.components.inventoryitem:OnDropped()
            end
        end

        if target.components.trap ~= nil then
            target.components.trap:Harvest()
        end

        if target.components.dryer ~= nil then
            target.components.dryer:DropItem()
        end

        if target.components.harvestable ~= nil then
            target.components.harvestable:Harvest()
        end

        if target.components.stewer ~= nil then
            target.components.stewer:Harvest()
        end

        target:PushEvent("ondeconstructstructure", caster)

        if target.components.stackable ~= nil then
            --if it's stackable we only want to destroy one of them.
            target.components.stackable:Get():Remove()
        else
            target:Remove()
        end
    end

    UpvalueHacker.SetUpvalue(GLOBAL.Prefabs.greenstaff.fn, destroystructure, "destroystructure")
end)
--------------------------------------------------

--KoreanWaffles