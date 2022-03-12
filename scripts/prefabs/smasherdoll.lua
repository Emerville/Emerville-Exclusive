local assets =
{
    -- Animation files used for the item.
    Asset("ANIM", "anim/smasherdoll.zip"),

    -- Inventory image and atlas file used for the item.
    Asset("ATLAS", "images/inventoryimages/smasherdoll.xml"),
    Asset("IMAGE", "images/inventoryimages/smasherdoll.tex"),
}

local function SpawnAquaHeal(inst, owner)
    if not owner.components.hunger or not owner.components.sanity or not owner.components.health then
        inst.fx_task:Cancel()
        inst.fx_task = nil
        return
    end

    local fx = SpawnPrefab("splash_green_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())

    local statuseffect = math.random(1,3)
    if statuseffect == 1 and owner.components.hunger then
        owner.components.hunger:DoDelta(20) --Gives 5 hunger to user.
    elseif statuseffect == 2 and owner.components.sanity then
        owner.components.sanity:DoDelta(20) --Gives 5 sanity to user.
    elseif statuseffect == 3 and owner.components.health then
        owner.components.sanity:DoDelta(20) --Gives 5 health to user.
    end
end

local function OnHaunt(inst, doer)
    local fx = SpawnPrefab("ocean_splash_med2")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx.Transform:SetScale(.5, .5, .5)
    inst:Remove()
    return old_onhaunt(inst, doer)
end

local function OnPutInInventory(inst, owner)
    if inst.fx_task ~= nil then
        inst.fx_task:Cancel()
        inst.fx_task = nil
    end
    
    if owner.components.health ~= nil then
        inst.fx_task = inst:DoPeriodicTask(120, function() SpawnAquaHeal(inst, owner) end) --480 Day/Regular --240 HalfDay/Event
    end
end

local function OnDropped(inst)
    if inst.fx_task ~= nil then
        inst.fx_task:Cancel()
        inst.fx_task = nil
    end
end

local function init()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("smasherdoll")
    inst.AnimState:SetBuild("smasherdoll")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("resurrector")
    inst:AddTag("molebait")
    inst:AddTag("cattoy")
    inst:AddTag("casino")

    if not TheWorld.ismastersim then
        return inst
    end

    inst.entity:SetPristine()

    inst:AddComponent("inspectable")

    inst:AddComponent("tradable")
    inst.components.tradable.goldvalue = 25

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "smasherdoll"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/smasherdoll.xml"
    inst.components.inventoryitem:SetOnDroppedFn(OnDropped)
    inst.components.inventoryitem:SetOnPutInInventoryFn(OnPutInInventory)

--    inst:AddComponent("equippable")
--    inst.components.equippable:SetOnPocket(onpocket)

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_INSTANT_REZ)

    -- where inst is the hauntable item
    local old_onhaunt = inst.components.hauntable.onhaunt
    inst.components.hauntable:SetOnHauntFn(OnHaunt)

    inst:AddComponent("bait")

    return inst
end

return Prefab("common/inventory/smasherdoll", init, assets)