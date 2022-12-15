local assets =
{
	Asset("ANIM", "anim/box_gear.zip"),
	
	Asset("ATLAS", "images/inventoryimages/gearbox.xml"),
	Asset("IMAGE", "images/inventoryimages/gearbox.tex"),	
}

local function fn()
	local inst = CreateEntity()
    
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()	
    inst.entity:AddNetwork()
	
    MakeInventoryPhysics(inst)
    
    inst.AnimState:SetBank("box_gear")
    inst.AnimState:SetBuild("box_gear")
    inst.AnimState:PlayAnimation("anim")
	
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end	

    inst:AddComponent("inspectable")

	inst:AddComponent("tradable")
	inst.components.tradable.goldvalue = 20	
	
    inst:AddComponent("inventoryitem")	
	inst.components.inventoryitem.imagename = "gearbox"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/gearbox.xml"		
	
	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM	
	
    MakeHauntableLaunch(inst)	
    	
    return inst
end

return Prefab("common/inventory/gearbox", fn, assets) 