local assets =
{
	Asset("ANIM", "anim/icypack.zip"),
    Asset("ANIM", "anim/ui_ice_pack_1x2.zip"),	
	
	Asset("ATLAS", "images/inventoryimages/icypack.xml"),
	Asset("IMAGE", "images/inventoryimages/icypack.tex"),		
}

--[[local function Sparkle(inst)
    if not inst.AnimState:IsCurrentAnimation("idle_sparkle") then
        inst.AnimState:PlayAnimation("idle_sparkle")
        inst.AnimState:PushAnimation("idle", true)
    end
    inst:DoTaskInTime(4 + math.random(), Sparkle)
end]]

local function ondropped(inst, owner)
    inst.components.container:Close(owner)
end

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
	minimap:SetIcon("icypack.tex")
	
	inst:AddTag("icypack")
	inst:AddTag("fridge")
    inst:AddTag("nocool")
    inst:AddTag("casino")
	
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end	
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")	
	inst.components.inventoryitem.imagename = "icypack"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/icypack.xml"
	inst.components.inventoryitem:SetOnDroppedFn(ondropped)
    
    inst:AddComponent("container")
	inst.components.container:WidgetSetup("icypack")  	
    inst.components.container.onopenfn = onopen
    inst.components.container.onclosefn = onclose
    inst.components.container.skipopensnd = true
    inst.components.container.skipclosesnd = true
	
    --inst:DoTaskInTime(1, Sparkle)
	
	MakeHauntableLaunch(inst)
	
    return inst
end

return Prefab("common/inventory/icypack", fn, assets) 