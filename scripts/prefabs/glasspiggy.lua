local assets =
{
    Asset("ANIM", "anim/glasspiggy.zip"),
    Asset("ATLAS", "images/inventoryimages/glasspiggy.xml"),
    Asset("IMAGE", "images/inventoryimages/glasspiggy.tex"),
}

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
    if inst.stored > 0 then
        local coins = SpawnPrefab("goldcoin")
        local maxstack = coins.components.stackable.maxsize
        local num = inst.stored and math.min(maxstack, inst.stored) or 0

        coins.components.stackable:SetStackSize(num)

        inst.components.lootdropper:FlingItem(coins)
        inst.stored = inst.stored - num
        inst.components.workable:SetWorkLeft(1)
    end
    
    if inst.stored == 0 then
        worker.SoundEmitter:PlaySound("dontstarve/creatures/slurtle/shatter")
        inst:Remove()
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

    inst.AnimState:SetBank("glasspiggy")
    inst.AnimState:SetBuild("glasspiggy")
    inst.AnimState:PlayAnimation("idle")
	
	inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
	
    inst:AddComponent("inspectable")
    inst.components.inspectable.descriptionfn = oninspect
	
    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "glasspiggy"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/glasspiggy.xml"	
	
    inst:AddComponent("lootdropper")

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(1)
    inst.components.workable:SetOnWorkCallback(onhit)
	
    inst.stored = 0

    inst.OnSave = onsave
    inst.OnLoad = onload
	
	MakeHauntableLaunch(inst)
	
    return inst
end

return Prefab("common/objects/glasspiggy", init, assets)