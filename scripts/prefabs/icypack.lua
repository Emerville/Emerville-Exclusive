local assets =
{
	Asset("ANIM", "anim/icypack.zip"),
    Asset("ANIM", "anim/ui_ice_pack_1x2.zip"),	
	
	Asset("ATLAS", "images/inventoryimages/ice_pack.xml"),
	Asset("IMAGE", "images/inventoryimages/ice_pack.tex"),		
}

local function onopen(inst)
    inst.SoundEmitter:PlaySound("dontstarve/common/icebox_open")
end

local function onclose(inst)
    inst.SoundEmitter:PlaySound("dontstarve/common/icebox_close") 
end

local function fn()
	local inst = CreateEntity()
	
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()
	
    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("icypack")
    inst.AnimState:SetBuild("icypack")
    inst.AnimState:PlayAnimation("idle")	

	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon("ice_pack.tex")
	
	inst:AddTag("fridge")
    inst:AddTag("nocool")	
	
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end	
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")	
	inst.components.inventoryitem.imagename = "ice_pack"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/ice_pack.xml"
    
    inst:AddComponent("container")
	inst.components.container:WidgetSetup("ice_pack")  	
    inst.components.container.onopenfn = onopen
    inst.components.container.onclosefn = onclose
    inst.components.container.skipopensnd = true
    inst.components.container.skipclosesnd = true
	
    return inst
end

return Prefab("common/inventory/icypack", fn, assets) 