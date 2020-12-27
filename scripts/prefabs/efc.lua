local assets =
{
	Asset("ANIM", "anim/efc.zip"),
	
	Asset("ATLAS", "images/inventoryimages/efc.xml"),
	Asset("IMAGE", "images/inventoryimages/efc.tex"),
}

local function oneaten(inst, eater)
   if eater.components.debuffable ~= nil and eater.components.debuffable:IsEnabled() and
    not eater.components.hunger ~= nil and
    not eater:HasTag("playerghost") then
    eater.components.debuffable:AddDebuff("hungerregenbuffefc", "hungerregenbuffefc")
	end
end

local function fn()
    local inst = CreateEntity()
	
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()
	
    MakeInventoryPhysics(inst)

 --	inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")   
    inst.AnimState:SetBank("efc")
    inst.AnimState:SetBuild("efc")
    inst.AnimState:PlayAnimation("efc")
	
	inst:AddTag("molebait")
	inst:AddTag("catfood")	
	inst:AddTag("preparedfood")	
    
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
	
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "efc"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/efc.xml"
	
    inst:AddComponent("edible")
    inst.components.edible.foodtype = FOODTYPE.MEAT	
	inst.components.edible.healthvalue = 3
	inst.components.edible.sanityvalue = 50
    inst.components.edible.hungervalue = 50
    inst.components.edible:SetOnEatenFn(oneaten)
	 
	inst:AddComponent("stackable") 
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
	
	inst:AddComponent("tradable")
    inst.components.tradable.goldvalue = 40

    inst:AddComponent("bait")
    
    return inst
end

return Prefab("common/inventory/efc", fn, assets) 