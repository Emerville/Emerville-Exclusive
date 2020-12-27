local assets =
{
	Asset("ANIM", "anim/musicbox.zip"),
	
	Asset("ATLAS", "images/inventoryimages/musicbox.xml"),
	Asset("IMAGE", "images/inventoryimages/musicbox.tex"),	
}

local function fn()
	local inst = CreateEntity()
    
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()	
    inst.entity:AddNetwork()
	
    MakeInventoryPhysics(inst)
    
    inst.AnimState:SetBank("musicbox")
    inst.AnimState:SetBuild("musicbox")
    inst.AnimState:PlayAnimation("idle", true)
	
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end	

    inst:AddComponent("inspectable")
	
    inst:AddComponent("inventoryitem")	
	inst.components.inventoryitem.imagename = "musicbox"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/musicbox.xml"			
	
    MakeHauntableLaunch(inst)	
    	
    return inst
end

return Prefab("common/inventory/musicbox2", fn, assets) 