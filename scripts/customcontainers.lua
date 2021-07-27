-------------------------------------
--~ [Widget Setup -- CONTAINERS] ~--
-------------------------------------
_G = GLOBAL
local params={} 

--------------------------------------------------------------------------
--[[ freezereye ]]
--------------------------------------------------------------------------
params.freezereye =
{
    widget =
    {
        slotpos = {},
        animbank = "ui_chest_3x2",
        animbuild = "ui_chest_3x2",
        pos = _G.Vector3(0, 200, 0),
        side_align_tip = 160,
    },
    type = "chest",
}

for y = 1, 0, -1 do
    for x = 0, 2 do
        table.insert(params.freezereye.widget.slotpos, _G.Vector3(80 * x - 80 * 2 + 80, 80 * y - 80 * 2 + 120, 0))
    end
end

function params.freezereye.itemtestfn(container, item, slot)
	return (item.components.edible and item.components.perishable) or
	       item:HasTag("icebox_valid") or		   		   
           item:HasTag("fresh") or 
	       item:HasTag("stale") or
	       item:HasTag("spoiled")
end

local containers = _G.require "containers"
containers.MAXITEMSLOTS = math.max(containers.MAXITEMSLOTS, params.freezereye.widget.slotpos ~= nil and #params.freezereye.widget.slotpos or 0)
local old_widgetsetup = containers.widgetsetup
function containers.widgetsetup(container, prefab, data)
        local pref = prefab or container.inst.prefab
        if pref == "freezereye" then
                local t = params[pref]
                if t ~= nil then
                        for k, v in pairs(t) do
                                container[k] = v
                        end
                        container:SetNumSlots(container.widget.slotpos ~= nil and #container.widget.slotpos or 0)
                end
        else
                return old_widgetsetup(container, prefab)
    end
end

--------------------------------------------------------------------------
--[[ ice_chest ]]
--------------------------------------------------------------------------
params.ice_chest =
--[[{
    widget =
    {
        slotpos = {},
        animbank = "ui_chest_4x4",
        animbuild = "ui_chest_4x4",
        pos = _G.Vector3(0, 200, 0),
        side_align_tip = 160,
    },
    type = "chest",
}

    for y = 3, 0, -1 do
	    for x = 0, 3 do
        table.insert(params.ice_chest.widget.slotpos, _G.Vector3(80 * x - 80 * 2 + 40, 80 * y - 80 * 2 + 40, 0))
	end
end]]

{
    widget =
    {
        slotpos = {},
        animbank = "ui_chest_5x12",
        animbuild = "ui_chest_5x12",
        pos = _G.Vector3(90, 220, 0),
        side_align_tip = 160,
    },
    type = "chest",
}

    for y = 4, 0, -1 do
        for x = 0, 11 do
        table.insert(params.ice_chest.widget.slotpos, _G.Vector3(80 * x - 346 * 2 + 98, 80 * y - 100 * 2 + 42, 0))
    end
end

function params.ice_chest.itemtestfn(container, item, slot)
	return (item.components.edible and item.components.perishable) or
	       item:HasTag("icebox_valid") or		   		   
           item:HasTag("fresh") or 
	       item:HasTag("stale") or
	       item:HasTag("spoiled")
end

local containers = _G.require "containers"
containers.MAXITEMSLOTS = math.max(containers.MAXITEMSLOTS, params.ice_chest.widget.slotpos ~= nil and #params.ice_chest.widget.slotpos or 0)
local old_widgetsetup = containers.widgetsetup
function containers.widgetsetup(container, prefab, data)
        local pref = prefab or container.inst.prefab
        if pref == "ice_chest" then
                local t = params[pref]
                if t ~= nil then
                        for k, v in pairs(t) do
                                container[k] = v
                        end
                        container:SetNumSlots(container.widget.slotpos ~= nil and #container.widget.slotpos or 0)
                end
        else
                return old_widgetsetup(container, prefab)
    end
end

--------------------------------------------------------------------------
--[[ compost_box ]]
--------------------------------------------------------------------------
params.compost_box =
{
    widget =
    {
        slotpos = {},
        animbank = "ui_chest_4x4",
        animbuild = "ui_chest_4x4",
        pos = _G.Vector3(0, 200, 0),
        side_align_tip = 160,
    },
    type = "chest",
}

    for y = 3, 0, -1 do
        for x = 0, 3 do
        table.insert(params.compost_box.widget.slotpos, _G.Vector3(80 * x - 80 * 2 + 40, 80 * y - 80 * 2 + 40, 0))
    end
end

function params.compost_box.itemtestfn(container, item, slot)
	return (item.components.edible and item.components.perishable) or
	       item.prefab == "spoiled_food" or	
	       item.prefab == "spoiled_fish_small" or	
	       item.prefab == "spoiled_fish" or 
	       item.prefab == "compost" or
	       item.prefab == "compostwrap" or
	       item.prefab == "rottenegg" or
	       item.prefab == "guano" or 
	       item.prefab == "poop" or 		   
           item:HasTag("fresh") or 
	       item:HasTag("stale") or
	       item:HasTag("spoiled")	  
end

local containers = _G.require "containers"
containers.MAXITEMSLOTS = math.max(containers.MAXITEMSLOTS, params.compost_box.widget.slotpos ~= nil and #params.compost_box.widget.slotpos or 0)
local old_widgetsetup = containers.widgetsetup
function containers.widgetsetup(container, prefab, data)
        local pref = prefab or container.inst.prefab
        if pref == "compost_box" then
                local t = params[pref]
                if t ~= nil then
                        for k, v in pairs(t) do
                                container[k] = v
                        end
                        container:SetNumSlots(container.widget.slotpos ~= nil and #container.widget.slotpos or 0)
                end
        else
                return old_widgetsetup(container, prefab)
    end
end

--------------------------------------------------------------------------
--[[ magicpouch ]]
--------------------------------------------------------------------------
params.magicpouch =
{
    widget =
    {
        slotpos = {},
        animbank = "ui_chest_4x4",
        animbuild = "ui_chest_4x4",
        pos = _G.Vector3(410, -200, 0),
        side_align_tip = 160,
    },
    type = "chest",
}

    for y = 3, 0, -1 do
        for x = 0, 3 do
        table.insert(params.magicpouch.widget.slotpos, _G.Vector3(80 * x - 80 * 2 + 40, 80 * y - 80 * 2 + 40, 0))
    end
end

function params.magicpouch.itemtestfn(container, item, slot)
	if item.prefab == "chester_eyebone" or 
	   item.prefab == "magicpouch" or 
	   item.prefab == "magicbag" or 
	   item.prefab == "icypack" or 
	   item.prefab == "frostpack" then    
	   return false    
	end    
	return true    
end

local containers = _G.require "containers"
containers.MAXITEMSLOTS = math.max(containers.MAXITEMSLOTS, params.magicpouch.slotpos ~= nil and #params.magicpouch.widget.slotpos or 0)
local old_widgetsetup = containers.widgetsetup
function containers.widgetsetup(container, prefab, data)
        local pref = prefab or container.inst.prefab
        if pref == "magicpouch" then
                local t = params[pref]
                if t ~= nil then
                        for k, v in pairs(t) do
                                container[k] = v
                        end
                        container:SetNumSlots(container.widget.slotpos ~= nil and #container.widget.slotpos or 0)
                end
        else
                return old_widgetsetup(container, prefab)
    end
end


--------------------------------------------------------------------------
--[[ magicbag ]]
--------------------------------------------------------------------------
params.magicbag =
{
    widget =
    {
		slotpos = {},
		animbank = "ui_chest_5x8",
		animbuild = "ui_chest_5x8",
		pos = _G.Vector3(665, -200, 0),
		side_align_tip = 160,
    },
    type = "chest",
}

	for y = 4, 0, -1 do
		for x = 0, 7 do
		table.insert(params.magicbag.widget.slotpos, _G.Vector3(80 * x - 346 * 2 + 109, 80 * y - 100 * 2 + 42, 0))
	end
end

function params.magicbag.itemtestfn(container, item, slot)
	if item.prefab == "chester_eyebone" or 
	   item.prefab == "magicpouch" or 
	   item.prefab == "magicbag" or
	   item.prefab == "icypack" or
	   item.prefab == "frostpack" then    
	   return false    
	end    
	return true    
end

local containers = _G.require "containers"
containers.MAXITEMSLOTS = math.max(containers.MAXITEMSLOTS, params.magicbag.slotpos ~= nil and #params.magicbag.widget.slotpos or 0)
local old_widgetsetup = containers.widgetsetup
function containers.widgetsetup(container, prefab, data)
        local pref = prefab or container.inst.prefab
        if pref == "magicbag" then
                local t = params[pref]
                if t ~= nil then
                        for k, v in pairs(t) do
                                container[k] = v
                        end
                        container:SetNumSlots(container.widget.slotpos ~= nil and #container.widget.slotpos or 0)
                end
        else
                return old_widgetsetup(container, prefab)
    end
end

--------------------------------------------------------------------------
--[[ crate_wooden ]]
--------------------------------------------------------------------------
params.crate_wooden =
{
    widget =
    {
        slotpos = {},
        animbank = "ui_chest_5x12",
        animbuild = "ui_chest_5x12",
        pos = _G.Vector3(90, 220, 0),
        side_align_tip = 160,
    },
    type = "chest",
}

    for y = 4, 0, -1 do
        for x = 0, 11 do
        table.insert(params.crate_wooden.widget.slotpos, _G.Vector3(80 * x - 346 * 2 + 98, 80 * y - 100 * 2 + 42, 0))
    end
end

function params.crate_wooden.itemtestfn(container, item, slot)
	if item.prefab == "chester_eyebone" then    
		return false    
	end    
	    return true    
end

local containers = _G.require "containers"
containers.MAXITEMSLOTS = math.max(containers.MAXITEMSLOTS, params.crate_wooden.widget.slotpos ~= nil and #params.crate_wooden.widget.slotpos or 0)
local old_widgetsetup = containers.widgetsetup
function containers.widgetsetup(container, prefab, data)
        local pref = prefab or container.inst.prefab
        if pref == "crate_wooden" then
                local t = params[pref]
                if t ~= nil then
                        for k, v in pairs(t) do
                                container[k] = v
                        end
                        container:SetNumSlots(container.widget.slotpos ~= nil and #container.widget.slotpos or 0)
                end
        else
                return old_widgetsetup(container, prefab)
    end
end

--------------------------------------------------------------------------
--[[ crate_wooden_gingerbread ]]
--------------------------------------------------------------------------
params.crate_wooden_gingerbread =
{
    widget =
    {
        slotpos = {},
        animbank = "ui_chest_5x12",
        animbuild = "ui_chest_5x12",
        pos = _G.Vector3(90, 220, 0),
        side_align_tip = 160,
    },
    type = "chest",
}

    for y = 4, 0, -1 do
        for x = 0, 11 do
        table.insert(params.crate_wooden_gingerbread.widget.slotpos, _G.Vector3(80 * x - 346 * 2 + 98, 80 * y - 100 * 2 + 42, 0))
    end
end

function params.crate_wooden_gingerbread.itemtestfn(container, item, slot)
	if item.prefab == "chester_eyebone" then    
		return false    
	end    
	    return true    
end

local containers = _G.require "containers"
containers.MAXITEMSLOTS = math.max(containers.MAXITEMSLOTS, params.crate_wooden_gingerbread.widget.slotpos ~= nil and #params.crate_wooden_gingerbread.widget.slotpos or 0)
local old_widgetsetup = containers.widgetsetup
function containers.widgetsetup(container, prefab, data)
        local pref = prefab or container.inst.prefab
        if pref == "crate_wooden_gingerbread" then
                local t = params[pref]
                if t ~= nil then
                        for k, v in pairs(t) do
                                container[k] = v
                        end
                        container:SetNumSlots(container.widget.slotpos ~= nil and #container.widget.slotpos or 0)
                end
        else
                return old_widgetsetup(container, prefab)
    end
end

--------------------------------------------------------------------------
--[[ crate_wooden_3d ]]
--------------------------------------------------------------------------
params.crate_wooden_3d =
{
    widget =
    {
        slotpos = {},
        animbank = "ui_chest_5x12",
        animbuild = "ui_chest_5x12",
        pos = _G.Vector3(90, 220, 0),
        side_align_tip = 160,
    },
    type = "chest",
}

    for y = 4, 0, -1 do
        for x = 0, 11 do
        table.insert(params.crate_wooden_3d.widget.slotpos, _G.Vector3(80 * x - 346 * 2 + 98, 80 * y - 100 * 2 + 42, 0))
    end
end

function params.crate_wooden_3d.itemtestfn(container, item, slot)
	if item.prefab == "chester_eyebone" then    
		return false    
	end    
	    return true    
end

local containers = _G.require "containers"
containers.MAXITEMSLOTS = math.max(containers.MAXITEMSLOTS, params.crate_wooden_3d.widget.slotpos ~= nil and #params.crate_wooden_3d.widget.slotpos or 0)
local old_widgetsetup = containers.widgetsetup
function containers.widgetsetup(container, prefab, data)
        local pref = prefab or container.inst.prefab
        if pref == "crate_wooden_3d" then
                local t = params[pref]
                if t ~= nil then
                        for k, v in pairs(t) do
                                container[k] = v
                        end
                        container:SetNumSlots(container.widget.slotpos ~= nil and #container.widget.slotpos or 0)
                end
        else
                return old_widgetsetup(container, prefab)
    end
end

--------------------------------------------------------------------------
--[[ crate_wooden_scary ]]
--------------------------------------------------------------------------
params.crate_wooden_scary =
{
    widget =
    {
        slotpos = {},
        animbank = "ui_chest_5x12",
        animbuild = "ui_chest_5x12",
        pos = _G.Vector3(90, 220, 0),
        side_align_tip = 160,
    },
    type = "chest",
}

    for y = 4, 0, -1 do
        for x = 0, 11 do
        table.insert(params.crate_wooden_scary.widget.slotpos, _G.Vector3(80 * x - 346 * 2 + 98, 80 * y - 100 * 2 + 42, 0))
    end
end

function params.crate_wooden_scary.itemtestfn(container, item, slot)
	if item.prefab == "chester_eyebone" then    
		return false    
	end    
	    return true    
end

local containers = _G.require "containers"
containers.MAXITEMSLOTS = math.max(containers.MAXITEMSLOTS, params.crate_wooden_scary.widget.slotpos ~= nil and #params.crate_wooden_scary.widget.slotpos or 0)
local old_widgetsetup = containers.widgetsetup
function containers.widgetsetup(container, prefab, data)
        local pref = prefab or container.inst.prefab
        if pref == "crate_wooden_scary" then
                local t = params[pref]
                if t ~= nil then
                        for k, v in pairs(t) do
                                container[k] = v
                        end
                        container:SetNumSlots(container.widget.slotpos ~= nil and #container.widget.slotpos or 0)
                end
        else
                return old_widgetsetup(container, prefab)
    end
end

--------------------------------------------------------------------------
--[[ crate_wooden_present ]]
--------------------------------------------------------------------------
params.crate_wooden_present =
{
    widget =
    {
        slotpos = {},
        animbank = "ui_chest_5x12",
        animbuild = "ui_chest_5x12",
        pos = _G.Vector3(90, 220, 0),
        side_align_tip = 160,
    },
    type = "chest",
}

    for y = 4, 0, -1 do
        for x = 0, 11 do
        table.insert(params.crate_wooden_present.widget.slotpos, _G.Vector3(80 * x - 346 * 2 + 98, 80 * y - 100 * 2 + 42, 0))
    end
end

function params.crate_wooden_present.itemtestfn(container, item, slot)
	if item.prefab == "chester_eyebone" then    
		return false    
	end    
	    return true    
end

local containers = _G.require "containers"
containers.MAXITEMSLOTS = math.max(containers.MAXITEMSLOTS, params.crate_wooden_present.widget.slotpos ~= nil and #params.crate_wooden_present.widget.slotpos or 0)
local old_widgetsetup = containers.widgetsetup
function containers.widgetsetup(container, prefab, data)
        local pref = prefab or container.inst.prefab
        if pref == "crate_wooden_present" then
                local t = params[pref]
                if t ~= nil then
                        for k, v in pairs(t) do
                                container[k] = v
                        end
                        container:SetNumSlots(container.widget.slotpos ~= nil and #container.widget.slotpos or 0)
                end
        else
                return old_widgetsetup(container, prefab)
    end
end

--------------------------------------------------------------------------
--[[ Vacuum Chest ]]
--------------------------------------------------------------------------
params.vacuum_chest =
{
    widget =
    {
        slotpos = {},
        animbank = "ui_chest_5x12",
        animbuild = "ui_chest_5x12",
        pos = _G.Vector3(90, 220, 0),
        side_align_tip = 160,
    },
    type = "chest",
}

    for y = 4, 0, -1 do
        for x = 0, 11 do
        table.insert(params.vacuum_chest.widget.slotpos, _G.Vector3(80 * x - 346 * 2 + 98, 80 * y - 100 * 2 + 42, 0))
    end
end

local containers = _G.require "containers"
containers.MAXITEMSLOTS = math.max(containers.MAXITEMSLOTS, params.vacuum_chest.widget.slotpos ~= nil and #params.vacuum_chest.widget.slotpos or 0)
local old_widgetsetup = containers.widgetsetup
function containers.widgetsetup(container, prefab, data)
        local pref = prefab or container.inst.prefab
        if pref == "vacuum_chest" then
                local t = params[pref]
                if t ~= nil then
                        for k, v in pairs(t) do
                                container[k] = v
                        end
                        container:SetNumSlots(container.widget.slotpos ~= nil and #container.widget.slotpos or 0)
                end
        else
                return old_widgetsetup(container, prefab)
    end
end

--------------------------------------------------------------------------
--[[ trash_can ]]
--------------------------------------------------------------------------
params.trash_can =
{
    widget =
    {
        slotpos =
        {
            _G.Vector3(0, 64 + 32 + 8 + 4, 0), 
            _G.Vector3(0, 32 + 4, 0),
            _G.Vector3(0, -(32 + 4), 0), 
            _G.Vector3(0, -(64 + 32 + 8 + 4), 0),
        },
        animbank = "ui_cookpot_1x4",
        animbuild = "ui_cookpot_1x4",
        pos = _G.Vector3(200, 0, 0),
        side_align_tip = 100,
        buttoninfo =
        {
            text = "Destroy",
            position = _G.Vector3(0, -165, 0),
        }
	},	
    type = "cooker",
}

local ACTIONS = GLOBAL.ACTIONS
local BufferedAction = GLOBAL.BufferedAction
local RPC = GLOBAL.RPC
local SendRPCToServer = GLOBAL.SendRPCToServer

local function destroyfn(act)
	local inst = act.target
	if inst ~= nil then
		if inst.components.container ~= nil then
			inst.components.container:DestroyContents()
		end
		if inst.SoundEmitter ~= nil then
			inst.SoundEmitter:PlaySound("dontstarve/common/destroy_stone")
		end
	end
	return true
end

AddAction("TRASHDESTROY", "Destroy", destroyfn)

function params.trash_can.widget.buttoninfo.fn(inst)
    if inst.components.container ~= nil then
        BufferedAction(inst.components.container.opener, inst, ACTIONS.TRASHDESTROY):Do()
    elseif inst.replica.container ~= nil then
        SendRPCToServer(RPC.DoWidgetButtonAction, ACTIONS.TRASHDESTROY.code, inst, ACTIONS.TRASHDESTROY.mod_name)
    end
end

function params.trash_can.widget.buttoninfo.validfn(inst)
	if inst.replica.container ~= nil then
		local container = inst.replica.container
		local _numslots = container:GetNumSlots()
		for i = 1, _numslots, 1 do
			local iteminslot = container:GetItemInSlot(i)
			if iteminslot ~= nil then
				return true
			end
		end
	end
	return false
end

function params.trash_can.itemtestfn(container, item, slot)
	if item.prefab == "lucy" or item:HasTag("irreplaceable") then    
		return false    
	end    
	    return true    
end


local containers = _G.require "containers"
containers.MAXITEMSLOTS = math.max(containers.MAXITEMSLOTS, params.trash_can.widget.slotpos ~= nil and #params.trash_can.widget.slotpos or 0)
local old_widgetsetup = containers.widgetsetup
function containers.widgetsetup(container, prefab, data)
        local pref = prefab or container.inst.prefab
        if pref == "trash_can" then
                local t = params[pref]
                if t ~= nil then
                        for k, v in pairs(t) do
                                container[k] = v
                        end
                        container:SetNumSlots(container.widget.slotpos ~= nil and #container.widget.slotpos or 0)
                end
        else
                return old_widgetsetup(container, prefab)
    end
end

--------------------------------------------------------------------------
--[[ crate_metal ]]
--------------------------------------------------------------------------
params.crate_metal =
{
    widget =
    {
        slotpos = {},
        animbank = "ui_safechest_3x3",
        animbuild = "ui_safechest_3x3",
        pos = _G.Vector3(0, 200, 0),
        side_align_tip = 160,
    },
    type = "chest",
}

    for y = 2, 0, -1 do
        for x = 0, 2 do
        table.insert(params.crate_metal.widget.slotpos, _G.Vector3(80 * x - 80 * 2 + 80, 80 * y - 80 * 2 + 80, 0))
    end
end

function params.crate_metal.itemtestfn(container, item, slot)
	if item.prefab == "chester_eyebone" then    
		return false    
	end    
	    return true    
end

local containers = _G.require "containers"
containers.MAXITEMSLOTS = math.max(containers.MAXITEMSLOTS, params.crate_metal.widget.slotpos ~= nil and #params.crate_metal.widget.slotpos or 0)
local old_widgetsetup = containers.widgetsetup
function containers.widgetsetup(container, prefab, data)
        local pref = prefab or container.inst.prefab
        if pref == "crate_metal" then
                local t = params[pref]
                if t ~= nil then
                        for k, v in pairs(t) do
                                container[k] = v
                        end
                        container:SetNumSlots(container.widget.slotpos ~= nil and #container.widget.slotpos or 0)
                end
        else
                return old_widgetsetup(container, prefab)
    end
end

--------------------------------------------------------------------------
--[[ icypack ]]
-------------------------------------------------------------------------- 
params.icypack =
{
    widget =
    {
        slotpos = {},
        animbank = "ui_ice_pack_1x2",
        animbuild = "ui_ice_pack_1x2",
        pos = _G.Vector3(300, -320, 0),
        side_align_tip = 160,		
    },
    type = "cooker",
}

    for y = 0, 1 do
	table.insert(params.icypack.widget.slotpos, _G.Vector3(-162 + (75/2), -75 * y + 114 ,0))
end

function params.icypack.itemtestfn(container, item, slot)
	return (item.components.edible and item.components.perishable) or
	       item:HasTag("icebox_valid") or		   		   
           item:HasTag("fresh") or 
	       item:HasTag("stale") or
	       item:HasTag("spoiled")
end

local containers = _G.require "containers"
containers.MAXITEMSLOTS = math.max(containers.MAXITEMSLOTS, params.icypack.widget.slotpos ~= nil and #params.icypack.widget.slotpos or 0)
local old_widgetsetup = containers.widgetsetup
function containers.widgetsetup(container, prefab, data)
        local pref = prefab or container.inst.prefab
        if pref == "icypack" then
                local t = params[pref]
                if t ~= nil then
                        for k, v in pairs(t) do
                                container[k] = v
                        end
                        container:SetNumSlots(container.widget.slotpos ~= nil and #container.widget.slotpos or 0)
                end
        else
                return old_widgetsetup(container, prefab)
    end
end

--------------------------------------------------------------------------
--[[ frostpack ]]
-------------------------------------------------------------------------- 
params.frostpack =
{
    widget =
    {
        slotpos =
        {
            _G.Vector3(-37.5, 32 + 4, 0),
            _G.Vector3(37.5, 32 + 4, 0),
            _G.Vector3(-37.5, -(32 + 4), 0),
            _G.Vector3(37.5, -(32 + 4), 0),
        },
        animbank = "ui_chest_2x2",
        animbuild = "ui_chest_2x2",
        pos = _G.Vector3(210, -270, 0),
        side_align_tip = 160,		
    },
    type = "cooker",
}

function params.frostpack.itemtestfn(container, item, slot)
	return (item.components.edible and item.components.perishable) or
	       item:HasTag("icebox_valid") or		   		   
           item:HasTag("fresh") or 
	       item:HasTag("stale") or
	       item:HasTag("spoiled")
end

local containers = _G.require "containers"
containers.MAXITEMSLOTS = math.max(containers.MAXITEMSLOTS, params.frostpack.widget.slotpos ~= nil and #params.frostpack.widget.slotpos or 0)
local old_widgetsetup = containers.widgetsetup
function containers.widgetsetup(container, prefab, data)
        local pref = prefab or container.inst.prefab
        if pref == "frostpack" then
                local t = params[pref]
                if t ~= nil then
                        for k, v in pairs(t) do
                                container[k] = v
                        end
                        container:SetNumSlots(container.widget.slotpos ~= nil and #container.widget.slotpos or 0)
                end
        else
                return old_widgetsetup(container, prefab)
    end
end

--------------------------------------------------------------------------
--[[ Wolfgang the Merchant ]]
--------------------------------------------------------------------------
params.traderwolfgang =
{
	widget =
	{
		slotpos = 
        {
            _G.Vector3(-37.5, 32 + 4, 0), 
            _G.Vector3(37.4, 32 + 4, 0),
            _G.Vector3(-37.5, -(32 + 4), 0), 
            _G.Vector3(37.5, -(32 + 4), 0),
        },		
        animbank = "ui_bundle_2x2",
        animbuild = "ui_bundle_2x2",
        pos = _G.Vector3(0, 200, 0),
        side_align_tip = 120,
		buttoninfo =
		{			
			text = "Convert",
			position = _G.Vector3(0, -100, 0),	
		}
	},
	type = "chest",
}

local SpawnPrefab = GLOBAL.SpawnPrefab

local function checktable(t, n, p, v)
    local c = 0
    for k, v in pairs(t) do
        c = c + 1
    end
    for i = 1, c do
        if p == t[i] then
            v = n
        end
    end
    return v
end

local function convertfn(act)
    local convert99 = {"skeletalamulet", "reaperamulet", "horsehead"}
    local convert25 = {"baronsuit", "coffee_cooked", "magicdolls", "notwilson", "spartahelmut", "thorn_crown"}
    local convert20 = {"box_gear"}
    local convert15 = {"deerclops_eyeball", "minotaurhorn", "hivehat", "skeletonhat"}

	local inst = act.target
    local container = inst.components.container
    local product_prefab = "goldcoin"
    local value = 0

    for i = 1, container:GetNumSlots() do
        local item = container:GetItemInSlot(i)
        if item and product_prefab then 
            local product = SpawnPrefab(product_prefab)
            if item.prefab == "goldcoin" then
                value = 1
            else
                value = checktable(convert99, 99, item.prefab, value)
                value = checktable(convert25, 25, item.prefab, value)
                value = checktable(convert20, 20, item.prefab, value)
                value = checktable(convert15, 15, item.prefab, value)
            end
            if item.components.stackable then 
                value = value * item.components.stackable.stacksize
            end
            product.components.stackable.stacksize = value
            inst.components.container:RemoveItemBySlot(i):Remove()
            inst.components.container:GiveItem(product, i)
        end
    end
    inst.SoundEmitter:PlaySound("dontstarve/quagmire/common/coins/drop")
end

AddAction("CONVERTGOLD", "Convert", convertfn)

function params.traderwolfgang.widget.buttoninfo.fn(inst)
	if inst.components.container ~= nil then
        BufferedAction(inst.components.container.opener, inst, ACTIONS.CONVERTGOLD):Do()
    elseif inst.replica.container ~= nil and not inst.replica.container:IsBusy() then
        SendRPCToServer(RPC.DoWidgetButtonAction, ACTIONS.CONVERTGOLD.code, inst, ACTIONS.CONVERTGOLD.mod_name)
    end
end

function params.traderwolfgang.widget.buttoninfo.validfn(inst)
	if inst.replica.container ~= nil then
		local container = inst.replica.container
		local _numslots = container:GetNumSlots()
		for i = 1, _numslots, 1 do
			local iteminslot = container:GetItemInSlot(i)
			if iteminslot ~= nil then
				return true
			end
		end
	end
	return false
end

function params.traderwolfgang.itemtestfn(container, item, slot)
 if	item.prefab == "goldcoin" or
	item.prefab == "deerclops_eyeball" or
	item.prefab == "minotaurhorn" or
	item.prefab == "hivehat" or
	item.prefab == "box_gear" or		
	item.prefab == "skeletonhat" or	
	item.prefab == "notwilson" or
	item.prefab == "thorn_crown" or	
	item.prefab == "baronsuit" or	
    item.prefab == "spartahelmut" or
	item.prefab == "horsehead" or		
	item.prefab == "skeletalamulet" or	
    item.prefab == "reaperamulet" or
	item.prefab == "magicdolls" then	
		return true
	end
end

local containers = _G.require "containers"
containers.MAXITEMSLOTS = math.max(containers.MAXITEMSLOTS, params.traderwolfgang.slotpos ~= nil and #params.traderwolfgang.widget.slotpos or 0)
local old_widgetsetup = containers.widgetsetup
function containers.widgetsetup(container, prefab, data)
        local pref = prefab or container.inst.prefab
        if pref == "traderwolfgang" then
                local t = params[pref]
                if t ~= nil then
                        for k, v in pairs(t) do
                                container[k] = v
                        end
                        container:SetNumSlots(container.widget.slotpos ~= nil and #container.widget.slotpos or 0)
                end
        else
                return old_widgetsetup(container, prefab)
    end
end

--------------------------------------------------------------------------
--[[ Casino Woodlegs ]]
--------------------------------------------------------------------------
params.casinowoodlegs =
{
	widget =
	{
        slotpos =
        {
            _G.Vector3(0, 64 + 8, 0),
            _G.Vector3(0, 0, 0),
            _G.Vector3(0, -(64 + 8), 0),
        },
        animbank = "quagmire_ui_pot_1x3",
        animbuild = "quagmire_ui_pot_1x3",
        pos = _G.Vector3(200, 0, 0),
        side_align_tip = 100,
	},
	type = "chest",
}

function params.casinowoodlegs.itemtestfn(container, item, slot)
 if	item.prefab == "trinket_pigbank" or
	item.prefab == "piggybank" or
	item.prefab == "magicpouch" or
	item.prefab == "magicbag" or
	item.prefab == "elegantlantern" or	
	item.prefab == "opulentlantern" or	
	item.prefab == "icypack" or	
	item.prefab == "frostpack" then	
		return true
	end
end

local containers = _G.require "containers"
containers.MAXITEMSLOTS = math.max(containers.MAXITEMSLOTS, params.casinowoodlegs.slotpos ~= nil and #params.casinowoodlegs.widget.slotpos or 0)
local old_widgetsetup = containers.widgetsetup
function containers.widgetsetup(container, prefab, data)
        local pref = prefab or container.inst.prefab
        if pref == "casinowoodlegs" then
                local t = params[pref]
                if t ~= nil then
                        for k, v in pairs(t) do
                                container[k] = v
                        end
                        container:SetNumSlots(container.widget.slotpos ~= nil and #container.widget.slotpos or 0)
                end
        else
                return old_widgetsetup(container, prefab)
    end
end

--------------------------------------------------------------------------
--[[ Gem Trader Wickerbottom ]]
--------------------------------------------------------------------------
params.casinowickerbottom =
{
	widget =
	{
		slotpos = {},		
        animbank = "ui_chest_3x2",
        animbuild = "ui_chest_3x2",
        pos = _G.Vector3(0, 200, 0),
        side_align_tip = 160, --120
		buttoninfo =
		{			
			text = "Sell",
			position = _G.Vector3(0, -100, 0),	
		}
	},
	type = "chest",
}

for y = 1, 0, -1 do
    for x = 0, 2 do
        table.insert(params.casinowickerbottom.widget.slotpos, _G.Vector3(80 * x - 80 * 2 + 80, 80 * y - 80 * 2 + 120, 0))
    end
end

local SpawnPrefab = GLOBAL.SpawnPrefab

local function checktable(t, n, p, v)
    local c = 0
    for k, v in pairs(t) do
        c = c + 1
    end
    for i = 1, c do
        if p == t[i] then
            v = n
        end
    end
    return v
end

local function convertfn(act)
    local convert2 = {"yellowgem", "greengem", "orangegem", "opalpreciousgem"}
    local convert1 = {"bluegem", "redgem", "purplegem"}

	local inst = act.target
    local container = inst.components.container
    local product_prefab = "goldcoin"
    local value = 0

    for i = 1, container:GetNumSlots() do
        local item = container:GetItemInSlot(i)
        if item and product_prefab then 
            local product = SpawnPrefab(product_prefab)
            if item.prefab == "goldcoin" then
                value = 1
            else
                value = checktable(convert2, 3, item.prefab, value)
                value = checktable(convert1, 1, item.prefab, value)
            end
            if item.components.stackable then 
                value = value * item.components.stackable.stacksize
            end
            product.components.stackable.stacksize = value
            inst.components.container:RemoveItemBySlot(i):Remove()
            inst.components.container:GiveItem(product, i)
        end
    end
    inst.SoundEmitter:PlaySound("dontstarve/quagmire/common/coins/drop")
end

AddAction("SELLGOLD", "Sell", convertfn)

function params.casinowickerbottom.widget.buttoninfo.fn(inst)
	if inst.components.container ~= nil then
        BufferedAction(inst.components.container.opener, inst, ACTIONS.SELLGOLD):Do()
    elseif inst.replica.container ~= nil and not inst.replica.container:IsBusy() then
        SendRPCToServer(RPC.DoWidgetButtonAction, ACTIONS.SELLGOLD.code, inst, ACTIONS.SELLGOLD.mod_name)
    end
end

function params.casinowickerbottom.widget.buttoninfo.validfn(inst)
	if inst.replica.container ~= nil then
		local container = inst.replica.container
		local _numslots = container:GetNumSlots()
		for i = 1, _numslots, 1 do
			local iteminslot = container:GetItemInSlot(i)
			if iteminslot ~= nil then
				return true
			end
		end
	end
	return false
end

function params.casinowickerbottom.itemtestfn(container, item, slot)
 if	item.prefab == "goldcoin" or
	item.prefab == "bluegem" or
	item.prefab == "redgem" or
	item.prefab == "purplegem" or
	item.prefab == "orangegem" or		
	item.prefab == "yellowgem" or	
	item.prefab == "greengem" then		
		return true
	end
end

local containers = _G.require "containers"
containers.MAXITEMSLOTS = math.max(containers.MAXITEMSLOTS, params.casinowickerbottom.slotpos ~= nil and #params.casinowickerbottom.widget.slotpos or 0)
local old_widgetsetup = containers.widgetsetup
function containers.widgetsetup(container, prefab, data)
        local pref = prefab or container.inst.prefab
        if pref == "casinowickerbottom" then
                local t = params[pref]
                if t ~= nil then
                        for k, v in pairs(t) do
                                container[k] = v
                        end
                        container:SetNumSlots(container.widget.slotpos ~= nil and #container.widget.slotpos or 0)
                end
        else
                return old_widgetsetup(container, prefab)
    end
end

--------------------------------------------------------------------------
--[[ Opulent Lantern]]
--------------------------------------------------------------------------
params.opulentlantern =
{
    widget =
    {
        slotpos =
        {
            _G.Vector3(0, 64 + 32 + 8 + 4, 0), 
            _G.Vector3(0, 32 + 4, 0),
            _G.Vector3(0, -(32 + 4), 0), 
            _G.Vector3(0, -(64 + 32 + 8 + 4), 0),
        },
        animbank = "ui_lamp_1x4",
        animbuild = "ui_lamp_1x4",
        pos = _G.Vector3(250, -200, 0),
        side_align_tip = 100,
    },
    acceptsstacks = false,
    type = "cooker",
}

function params.opulentlantern.itemtestfn(container, item, slot)
    return (item:HasTag("lightbattery") or item:HasTag("spore"))
end

local containers = _G.require "containers"
containers.MAXITEMSLOTS = math.max(containers.MAXITEMSLOTS, params.opulentlantern.slotpos ~= nil and #params.opulentlantern.widget.slotpos or 0)
local old_widgetsetup = containers.widgetsetup
function containers.widgetsetup(container, prefab, data)
        local pref = prefab or container.inst.prefab
        if pref == "opulentlantern" then
                local t = params[pref]
                if t ~= nil then
                        for k, v in pairs(t) do
                                container[k] = v
                        end
                        container:SetNumSlots(container.widget.slotpos ~= nil and #container.widget.slotpos or 0)
                end
        else
                return old_widgetsetup(container, prefab)
    end
end

--------------------------------------------------------------------------
--[[ Woodie the Merchant ]]
--------------------------------------------------------------------------

--[[
params.shipwreckedwoodie =
{
	widget =
	{
		slotpos = 
        {
            _G.Vector3(-37.5, 32 + 4, 0), 
            _G.Vector3(37.4, 32 + 4, 0),
            _G.Vector3(-37.5, -(32 + 4), 0), 
            _G.Vector3(37.5, -(32 + 4), 0),
        },		
        animbank = "ui_bundle_2x2",
        animbuild = "ui_bundle_2x2",
        pos = _G.Vector3(0, 200, 0),
        side_align_tip = 120,
		buttoninfo =
		{			
			text = "Convert",
			position = _G.Vector3(0, -100, 0),	
		}
	},
	type = "chest",
}

local function convertfn(act)
	local inst = act.target
    local container = inst.components.container
    	local has_burned_smth = false

--     if inst.components.fueled ~= nil then		
		for i = 1, container:GetNumSlots() do
			local item = container:GetItemInSlot(i)
			if item ~= nil then
     			local product_prefab = nil 
	     		if item.components.cookable ~= nil then 
					local product = item.components.cookable.product or "ash"
					product_prefab = type(product) ~= "function" and
            						 product or
            						 product(item, inst, doer)
	     		elseif item.prefab:find("goldnugget") and
				item.components.stackable ~= nil and item.components.stackable:StackSize() >= 5 then 
	     			product_prefab = "goldcoin"
				elseif item.prefab:find("rocks") and item.components.stackable:StackSize() >= 5 then 
	     			product_prefab = "moonrocknugget"					
				elseif item.prefab:find("goldcoin") and item.components.stackable:StackSize() >= 40 then 
	     			product_prefab = "elegantlantern"			
	     		end
				
	     		if product_prefab ~= nil then 
     				local product = SpawnPrefab(product_prefab)
					
     				if item.components.stackable ~= nil	and
					product.components.stackable ~= nil then 
     					local stack = item.components.stackable:StackSize()
						if product_prefab == "goldcoin" or product_prefab == "moonrocknugget" then
							stack = math.floor(stack/5)
						elseif product_prefab == "rocks" then
							stack = math.floor(stack/2)
						end	
						if stack > 1 then
							local new_stack = math.min(stack, product.components.stackable.maxsize)
							product.components.stackable:SetStackSize(new_stack)
						end
     				end					
					
					if item.components.perishable ~= nil and
					product.components.perishable ~= nil and not item:HasTag("smallcreature") then
               			local new_percent = 1 - (1 - item.components.perishable:GetPercent()) * .5
               			product.components.perishable:SetPercent(new_percent)
           			end
										
					if item.components.edible ~= nil then
						local OnEaten = item.components.edible.oneaten
						if OnEaten ~= nil then
							OnEaten(inst, inst)
						end
					end
					
     				inst.components.container:RemoveItemBySlot(i):Remove()
     				inst.components.container:GiveItem(product, i)
					
					has_burned_smth = true
     			end 
			end
		end 
		
		if has_burned_smth then
			inst.SoundEmitter:PlaySound("dontstarve/quagmire/common/coins/drop")  
			--inst.SoundEmitter:PlaySound("dontstarve/common/together/dragonfly_furnace/light")		
			--inst:SpawnChild("firesplash_fx").Transform:SetScale(.5,.5,.5)
		else
			inst.SoundEmitter:PlaySound("dontstarve/HUD/click_negative")
	end
end

AddAction("CONVERTGOLD", "Convert", convertfn)

function params.shipwreckedwoodie.widget.buttoninfo.fn(inst)
	if inst.components.container ~= nil then
        BufferedAction(inst.components.container.opener, inst, ACTIONS.CONVERTGOLD):Do()
    elseif inst.replica.container ~= nil and not inst.replica.container:IsBusy() then
        SendRPCToServer(RPC.DoWidgetButtonAction, ACTIONS.CONVERTGOLD.code, inst, ACTIONS.CONVERTGOLD.mod_name)
    end
end

function params.shipwreckedwoodie.widget.buttoninfo.validfn(inst)
	if inst.replica.container ~= nil then
		local container = inst.replica.container
		local _numslots = container:GetNumSlots()
		for i = 1, _numslots, 1 do
			local iteminslot = container:GetItemInSlot(i)
			if iteminslot ~= nil then
				return true
			end
		end
	end
	return false
end

function params.shipwreckedwoodie.itemtestfn(container, item, slot)
 if	item.prefab == "magicpouch" or
	item.prefab == "magicbag" or
	item.prefab == "goldnugget" or	
	item.prefab == "goldcoin" or
--	item.prefab == "rocks" or	
	item.prefab == "moonrocknugget" or	
	item.prefab == "elegantlantern" then	
		return true
	end
end

local containers = _G.require "containers"
containers.MAXITEMSLOTS = math.max(containers.MAXITEMSLOTS, params.shipwreckedwoodie.slotpos ~= nil and #params.shipwreckedwoodie.widget.slotpos or 0)
local old_widgetsetup = containers.widgetsetup
function containers.widgetsetup(container, prefab, data)
        local pref = prefab or container.inst.prefab
        if pref == "shipwreckedwoodie" then
                local t = params[pref]
                if t ~= nil then
                        for k, v in pairs(t) do
                                container[k] = v
                        end
                        container:SetNumSlots(container.widget.slotpos ~= nil and #container.widget.slotpos or 0)
                end
        else
                return old_widgetsetup(container, prefab)
    end
end]]
