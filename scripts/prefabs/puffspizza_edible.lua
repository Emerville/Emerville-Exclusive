local assets =
{
	Asset("ANIM", "anim/puffspizza_edible.zip"),
	
	Asset("ATLAS", "images/inventoryimages/puffspizza_edible.xml"),
	Asset("IMAGE", "images/inventoryimages/puffspizza_edible.tex"),
}

local function oneaten(inst, eater)
   if eater.components.debuffable ~= nil and eater.components.debuffable:IsEnabled() and
    not eater.components.hunger ~= nil and
    not eater:HasTag("playerghost") then
    eater.components.debuffable:AddDebuff("hungerregenbuffpuffspizza", "hungerregenbuffpuffspizza")
	end
end

local function fn()
    local inst = CreateEntity()
	
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()
	
    MakeInventoryPhysics(inst)

 --	inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")   
    inst.AnimState:SetBank("puffspizza_edible")
    inst.AnimState:SetBuild("puffspizza_edible")
    inst.AnimState:PlayAnimation("idle")
	
	inst:AddTag("molebait")
	inst:AddTag("catfood")	
	inst:AddTag("preparedfood")	
    
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
	
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "puffspizza_edible"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/puffspizza_edible.xml"
	
    inst:AddComponent("edible")
    inst.components.edible.foodtype = "GOODIES"	
	inst.components.edible.healthvalue = 8
	inst.components.edible.sanityvalue = 75
    inst.components.edible.hungervalue = 100
    inst.components.edible:SetOnEatenFn(oneaten)
	 
	inst:AddComponent("stackable") 
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
	
	inst:AddComponent("tradable")
    inst.components.tradable.goldvalue = 40

    inst:AddComponent("bait")
    
    return inst
end

return Prefab("common/inventory/puffspizza_edible", fn, assets) 