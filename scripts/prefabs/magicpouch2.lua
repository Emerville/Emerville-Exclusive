local assets =
{
    Asset("ANIM", "anim/ui_chest_4x4.zip"),	
    Asset("ANIM", "anim/magicpouch.zip"),
	
    Asset("ATLAS", "images/inventoryimages/magicpouch.xml"),
    Asset("IMAGE", "images/inventoryimages/magicpouch.tex"),		
}

local function ondropped(inst, owner)
    inst.components.container:Close(owner)
end

local function onopen(inst)
    inst.SoundEmitter:PlaySound("dontstarve/wilson/backpack_open", "open")
end

local function onclose(inst)
    inst.SoundEmitter:PlaySound("dontstarve/wilson/backpack_close", "open")
end

local function fn()
    local inst = CreateEntity()
 
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
 
    MakeInventoryPhysics(inst)
	
    local minimap = inst.entity:AddMiniMapEntity()
    minimap:SetIcon("magicpouch.tex")
	
    inst.AnimState:SetBank("magicpouch")
    inst.AnimState:SetBuild("magicpouch")
    inst.AnimState:PlayAnimation("idle2")

    inst:AddTag("magicalpouch")	
	
	inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
	
    inst:AddComponent("inspectable")	
	
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "magicpouch"	
    inst.components.inventoryitem.atlasname = "images/inventoryimages/magicpouch.xml"
    inst.components.inventoryitem.cangoincontainer = true	
	inst.components.inventoryitem:SetOnDroppedFn(ondropped)
	
    inst:AddComponent("container")
    inst.components.container:WidgetSetup("magicpouch")
    inst.components.container.onopenfn = onopen
    inst.components.container.onclosefn = onclose
    inst.components.container.skipopensnd = true
    inst.components.container.skipclosesnd = true
	
    return inst
end

return Prefab("common/magicpouch2", fn, assets)
