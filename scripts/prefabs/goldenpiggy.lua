local assets =
{
    Asset("ANIM", "anim/goldenpiggy.zip"),
	
    Asset("ATLAS", "images/inventoryimages/goldenpiggy.xml"),
    Asset("IMAGE", "images/inventoryimages/goldenpiggy.tex"),
}

local function Sparkle(inst)
    if not inst.AnimState:IsCurrentAnimation("idle_sparkle") then
        inst.AnimState:PlayAnimation("idle_sparkle")
        inst.AnimState:PushAnimation("idle", true)
    end
    inst:DoTaskInTime(4 + math.random(), Sparkle)
end

-- TODO: Move strings to string.lua and add character descriptions
local function oninspect(inst, viewer)
    local num = inst.stored

    if num <= 0 or num == nil then
        return "This piggy is completely empty."
    elseif num == 1 then
        return "This piggy probably has a single coin inside."
    end

    return "This piggy probably has "..num.." coins inside."
end

local function onhit(inst, worker, workleft, workdone)
    local coins = SpawnPrefab("goldcoin")
    local maxstack = coins.components.stackable.maxsize
    local num = inst.stored and math.min(maxstack, inst.stored) or 0

    if num > 0 then
        coins.components.stackable:SetStackSize(num)
        inst.components.lootdropper:FlingItem(coins)

        inst.stored = inst.stored - num
    end

    if inst.stored > 0 then
        inst.components.workable:SetWorkLeft(1)
    end
end

local function onsave(inst, data)
    if inst.stored ~= nil then
        data.stored = inst.stored
    end
end

local function onload(inst, data)
    if data and data.stored then
        inst.stored = data.stored
    end
end

----------------------------------

local function init()
    local inst = CreateEntity()
	
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("goldenpiggy")
    inst.AnimState:SetBuild("goldenpiggy")
    inst.AnimState:PlayAnimation("idle")
	
	inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
	
    inst:AddComponent("inspectable")
    inst.components.inspectable.descriptionfn = oninspect
	
    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "goldenpiggy"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/goldenpiggy.xml"	
	
    inst:AddComponent("lootdropper")

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(1)
    inst.components.workable:SetOnWorkCallback(onhit)
	
    inst.stored = 0

    inst.OnSave = onsave
    inst.OnLoad = onload
	
    inst:DoTaskInTime(1, Sparkle)
	
	MakeHauntableLaunch(inst)
	
    return inst
end

return Prefab("common/objects/goldenpiggy", init, assets)