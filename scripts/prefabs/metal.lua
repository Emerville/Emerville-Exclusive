local assets =
{
	Asset("ANIM", "anim/metal.zip"),
	
	Asset("ATLAS", "images/inventoryimages/metal.xml"),
    Asset("IMAGE", "images/inventoryimages/metal.tex"),
}

local function fn()
    local inst = CreateEntity()
	
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()	
	inst.entity:AddNetwork()
	
	MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("metal")
    inst.AnimState:SetBuild("metal")
    inst.AnimState:PlayAnimation("idle")
	
    inst.entity:SetPristine()	
	
	if not TheWorld.ismastersim then
        return inst
    end		
    
    inst:AddComponent("inspectable")
	
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "metal"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/metal.xml"	
    		
    inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
	
    MakeHauntableLaunch(inst)	
		
    return inst
end

return Prefab("common/inventory/metal", fn, assets) 