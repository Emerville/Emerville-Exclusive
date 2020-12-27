local assets =
{
    Asset("ANIM", "anim/guano.zip"),
	
	-- Inventory image and atlas file used for the item.
    Asset("ATLAS", "images/inventoryimages/attyla_guano.xml"),
    Asset("IMAGE", "images/inventoryimages/attyla_guano.tex"),
}

local prefabs =
{
    "flies",
    "poopcloud",
}

local function OnBurn(inst)
    DefaultBurnFn(inst)
    if inst.flies then
        inst.flies:Remove()
        inst.flies = nil
    end
end

local function FuelTaken(inst, taker)
    local cloud = SpawnPrefab("poopcloud")
    if cloud then
        cloud.Transform:SetPosition(taker.Transform:GetWorldPosition())
		cloud.Transform:SetScale(0.6, 0.6, 0.6)
    end
end

local function ondropped(inst)
    if inst.flies == nil then
        inst.flies = inst:SpawnChild("flies")
    end
end

local function onpickup(inst)
    if inst.flies ~= nil then
        inst.flies:Remove()
        inst.flies = nil
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)
    
    inst.AnimState:SetBank("guano")
    inst.AnimState:SetBuild("guano")
    inst.AnimState:PlayAnimation("dump")
    inst.AnimState:PushAnimation("idle")
	inst.Transform:SetScale(0.5, 0.5, 0.5)

    MakeDragonflyBait(inst, 3)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/inventoryimages/attyla_guano.xml"
    inst.components.inventoryitem.imagename = "attyla_guano"
	
    inst:AddComponent("stackable")

    inst:AddComponent("fertilizer")
    inst.components.fertilizer.fertilizervalue = TUNING.ATTYLA_GUANO_FERTILIZE
    inst.components.fertilizer.soil_cycles = TUNING.ATTYLA_GUANO_SOILCYCLES
    inst.components.fertilizer.withered_cycles = TUNING.ATTYLA_GUANO_WITHEREDCYCLES

    inst:AddComponent("smotherer")

    inst.components.inventoryitem:SetOnDroppedFn(ondropped)
    inst.components.inventoryitem:SetOnPickupFn(onpickup)
    inst.components.inventoryitem:SetOnPutInInventoryFn(onpickup)

    inst.flies = inst:SpawnChild("flies")

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.ATTYLA_GUANO_FUEL
    inst.components.fuel:SetOnTakenFn(FuelTaken)

    MakeSmallBurnable(inst, TUNING.ATTYLA_GUANO_BURNTIME)
    inst.components.burnable:SetOnIgniteFn(OnBurn)
    MakeSmallPropagator(inst)

    MakeHauntableLaunchAndIgnite(inst)

    ---------------------

    return inst
end

return Prefab("attyla_guano", fn, assets, prefabs)