local assets=
{
    Asset("ANIM", "anim/chocolatebar.zip"),
    Asset("ATLAS", "images/inventoryimages/chocolatebar.xml"),
    Asset("IMAGE", "images/inventoryimages/chocolatebar.tex"),
}

----------------------------------

local function init()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)
	
    inst.AnimState:SetBank("chocolatebar")
    inst.AnimState:SetBuild("chocolatebar")
    inst.AnimState:PlayAnimation("idle")
	
	inst:AddTag("molebait")
	inst:AddTag("catfood")	
	
	inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
	
    inst:AddComponent("inspectable")
	
    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "chocolatebar"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/chocolatebar.xml"
	
	inst:AddComponent("edible")
    inst.components.edible.foodtype = "GOODIES"
    inst.components.edible.healthvalue = 1
    inst.components.edible.sanityvalue = 50
    inst.components.edible.hungervalue = 25
	
	inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

	inst:AddComponent("tradable")
	inst.components.tradable.goldvalue = 15
	
    inst:AddComponent("bait")
	
	MakeHauntableLaunch(inst)
	
    return inst
end

return Prefab("common/objects/chocolatebar", init, assets)
