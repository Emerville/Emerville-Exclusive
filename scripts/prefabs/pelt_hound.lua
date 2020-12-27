local assets =
{
	Asset("ANIM", "anim/pelt_hound.zip"),
	
	Asset("ATLAS", "images/inventoryimages/pelt_hound.xml"),
    Asset("IMAGE", "images/inventoryimages/pelt_hound.tex"),
}

local function fn()
	local inst = CreateEntity()
    
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()	
	
    MakeInventoryPhysics(inst)
    
    inst.AnimState:SetBank("pelt_hound")
    inst.AnimState:SetBuild("pelt_hound")
    inst.AnimState:PlayAnimation("anim")
	
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end		

    inst:AddComponent("inspectable")
	
    inst:AddComponent("inventoryitem")	
	inst.components.inventoryitem.imagename = "pelt_hound"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/pelt_hound.xml"	
	
	inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
	
	MakeHauntableLaunch(inst)	
	
    return inst
end

return Prefab("common/inventory/pelt_hound", fn, assets) 