local assets =
{
	-- Animation files used for the item.
	Asset("ANIM", "anim/attylaskull.zip"),

	-- Inventory image and atlas file used for the item.
    Asset("ATLAS", "images/inventoryimages/attylaskull.xml"),
    Asset("IMAGE", "images/inventoryimages/attylaskull.tex"),
	
}

local function init(anim, tags, removephysicscolliders)
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)
	
    inst.AnimState:SetBank("attylaskull")
    inst.AnimState:SetBuild("attylaskull")
    inst.AnimState:PlayAnimation("swap")
	
	--inst:AddTag("irreplaceable") -- to make sure nothing will destroy the skull
	
	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon("attylaskull.tex")
	
	if removephysicscolliders then
        RemovePhysicsColliders(inst)
    end

    if not TheWorld.ismastersim then
        return inst
    end

    inst.entity:SetPristine()
	
    inst:AddComponent("inspectable")
	
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/attylaskull.xml"
    inst.components.inventoryitem.imagename = "attylaskull"
	
    MakeHauntableLaunch(inst)
    
    return inst
end

return Prefab("common/inventory/attylaskull", init, assets)