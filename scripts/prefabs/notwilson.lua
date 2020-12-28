local assets =
{
    Asset("ANIM", "anim/notwilson.zip"),
    Asset("ATLAS", "images/inventoryimages/notwilson.xml"),
    Asset("IMAGE", "images/inventoryimages/notwilson.tex"),
}

local function OnDropped(inst)
    inst.components.fueled:StartConsuming()
    inst.Light:Enable(true)
end

local function OnPickup(inst)
    inst.components.fueled:StopConsuming()
    inst.Light:Enable(false)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("notwilson")
    inst.AnimState:SetBuild("notwilson")
    inst.AnimState:PlayAnimation("idle")

    inst.Light:SetFalloff(0.7)
    inst.Light:SetIntensity(.5)
    inst.Light:SetRadius(1)
    inst.Light:SetColour(237/255, 237/255, 209/255)
    inst.Light:Enable(true)

    inst:AddTag("casino")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "notwilson"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/notwilson.xml"
    inst.components.inventoryitem:SetOnDroppedFn(OnDropped)
    inst.components.inventoryitem:SetOnPutInInventoryFn(OnPickup)

    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = TUNING.SANITYAURA_LARGE*2.5

    inst:AddComponent("fueled")
    inst.components.fueled:InitializeFuelLevel(720)
    inst.components.fueled:SetDepletedFn(inst.Remove)

    MakeSmallBurnable(inst, TUNING.LARGE_BURNTIME)
    MakeSmallPropagator(inst)

    MakeHauntableLaunchAndIgnite(inst)

    return inst
end

return Prefab("common/inventory/notwilson", fn, assets)
