local assets=
{
    Asset("ANIM", "anim/chocolatebar.zip"),
    Asset("ATLAS", "images/inventoryimages/chocolatebar.xml"),
    Asset("IMAGE", "images/inventoryimages/chocolatebar.tex"),
}

local prefabs =
{
    "spoiled_food",
}

----------------------------------

local function init()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

	inst:AddTag("preparedfood")
	
    inst.AnimState:SetBank("chocolatebar")
    inst.AnimState:SetBuild("chocolatebar")
    inst.AnimState:PlayAnimation("idle")

    if not TheWorld.ismastersim then
        return inst
    end

	inst.entity:SetPristine()
	
	inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
	
	inst:AddComponent("edible")
    inst.components.edible.healthvalue = 10
    inst.components.edible.hungervalue = 20
    inst.components.edible.sanityvalue = 100
    inst.components.edible.foodtype = FOODTYPE.GENERIC
	
	
	inst:AddComponent("perishable")
	inst.components.perishable:SetPerishTime(TUNING.PERISH_SUPERSLOW*1.5)
    inst.components.perishable:StartPerishing()
    inst.components.perishable.onperishreplacement = "spoiled_food"

	inst:AddComponent("tradable")
	inst.components.tradable.goldvalue = 2
	
    inst:AddComponent("inspectable")
	
    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "chocolatebar"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/chocolatebar.xml"
	
	MakeHauntableLaunchAndPerish(inst)
	
    return inst
end

return Prefab( "common/objects/chocolatebar", init, assets)
