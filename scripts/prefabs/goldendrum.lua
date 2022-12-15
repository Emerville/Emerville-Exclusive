local assets =
{
	Asset("ANIM", "anim/gflesh.zip"),
	
	Asset("ATLAS", "images/inventoryimages/gflesh.xml"),
	Asset("IMAGE", "images/inventoryimages/gflesh.tex"),
}

local function fn()
    local inst = CreateEntity()
	
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()
	
    MakeInventoryPhysics(inst)

 	inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")   
    inst.AnimState:SetBank("gflesh")
    inst.AnimState:SetBuild("gflesh")
    inst.AnimState:PlayAnimation("idle")
	
	inst:AddTag("molebait")
	inst:AddTag("catfood")	
	inst:AddTag("goldendrum")
    
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
	
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "gflesh"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/gflesh.xml"
	
    inst:AddComponent("edible")
    inst.components.edible.foodtype = "GOODIES"	
	inst.components.edible.healthvalue = 1
	inst.components.edible.sanityvalue = 25	
    inst.components.edible.hungervalue = 50	
	 
	inst:AddComponent("stackable") 
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
	
	inst:AddComponent("tradable")
    inst.components.tradable.goldvalue = 15

    inst:AddComponent("bait")
	
	MakeHauntableLaunch(inst)
    
    return inst
end

return Prefab("common/inventory/goldendrum", fn, assets) 