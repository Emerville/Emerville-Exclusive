local assets =
{
    Asset("ANIM", "anim/trinket_pigbank.zip"),
	
    Asset("ATLAS", "images/inventoryimages/trinket_pigbank.xml"),
    Asset("IMAGE", "images/inventoryimages/trinket_pigbank.tex"),
}

----------------------------------

local function init()
    local inst = CreateEntity()
	
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("trinket_pigbank")
    inst.AnimState:SetBuild("trinket_pigbank")
    inst.AnimState:PlayAnimation("idle")
	
	inst:AddTag("molebait")
	inst:AddTag("cattoy")
	
	inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
	
    inst:AddComponent("inspectable")

	inst:AddComponent("tradable")
	inst.components.tradable.goldvalue = 40
	
    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "trinket_pigbank"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/trinket_pigbank.xml"	
	
	inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
	
	inst:AddComponent("bait")
	
	MakeHauntableLaunch(inst)
	
    return inst
end

return Prefab("common/objects/trinket_pigbank", init, assets)