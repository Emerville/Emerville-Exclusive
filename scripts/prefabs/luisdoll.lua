local assets =
{
	-- Animation files used for the item.
	Asset("ANIM", "anim/luisdoll.zip"),

	-- Inventory image and atlas file used for the item.
    Asset("ATLAS", "images/inventoryimages/luisdoll.xml"),
    Asset("IMAGE", "images/inventoryimages/luisdoll.tex"),
}


local function init()

	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)
	
    inst.AnimState:SetBank("luisdoll")
    inst.AnimState:SetBuild("luisdoll")
    inst.AnimState:PlayAnimation("idle")
	
    inst:AddTag("resurrector")
	inst:AddTag("molebait")
	inst:AddTag("cattoy")
    inst:AddTag("casino")

    if not TheWorld.ismastersim then
        return inst
    end

    inst.entity:SetPristine()

    inst:AddComponent("inspectable")	

	inst:AddComponent("tradable")
	inst.components.tradable.goldvalue = 25	
		
    inst:AddComponent("inventoryitem")	
    inst.components.inventoryitem.imagename = "luisdoll"	
    inst.components.inventoryitem.atlasname = "images/inventoryimages/luisdoll.xml"
   
	inst:AddComponent("hauntable")
	inst.components.hauntable:SetHauntValue(TUNING.HAUNT_INSTANT_REZ)
	
	-- where inst is the hauntable item
	local old_onhaunt = inst.components.hauntable.onhaunt
	inst.components.hauntable:SetOnHauntFn(function(inst, doer)
	local fx = SpawnPrefab("small_puff")
        fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
        fx.Transform:SetScale(.5, .5, .5)
    inst:Remove()
    return old_onhaunt(inst, doer)
	end)
	
	inst:AddComponent("bait")
	
    return inst
end

return Prefab("common/inventory/luisdoll", init, assets)