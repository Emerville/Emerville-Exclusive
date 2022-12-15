local assets =
{
	-- Animation files used for the item.
	Asset("ANIM", "anim/goldenegg.zip"),

	-- Inventory image and atlas file used for the item.
    Asset("ATLAS", "images/inventoryimages/goldenegg.xml"),
    Asset("IMAGE", "images/inventoryimages/goldenegg.tex"),
	
}

local function init()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)
	
	inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetBank("goldenegg")
    inst.AnimState:SetBuild("goldenegg")
	inst.AnimState:PlayAnimation("idle")
	
	inst:AddTag("molebait")
	inst:AddTag("catfood")
	
    inst.entity:SetPristine()	

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
	
    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "goldenegg"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/goldenegg.xml"

	inst:AddComponent("edible")
    inst.components.edible.foodtype = "GOODIES"
	inst.components.edible.healthvalue = 50
    inst.components.edible.sanityvalue = 1
    inst.components.edible.hungervalue = 25
	
	inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
	
	inst:AddComponent("tradable")
    inst.components.tradable.goldvalue = 15
	
	inst:AddComponent("bait")
	
	MakeHauntableLaunch(inst)
	
    return inst
end

return Prefab("common/inventory/goldenegg", init, assets)