local assets =
{
    Asset("ANIM", "anim/ui_chest_4x4.zip"),	
    Asset("ANIM", "anim/chromebag2.zip"),	
	
    Asset("ATLAS", "images/inventoryimages/magicbag.xml"),
    Asset("IMAGE", "images/inventoryimages/magicbag.tex"),	
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
    minimap:SetIcon("magicbag.tex")
	
    inst.AnimState:SetBank("chromebag2")
    inst.AnimState:SetBuild("chromebag2")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("magicalpouch")	
    inst:AddTag("casino")
	
	inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
	
    inst:AddComponent("inspectable")	
	
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "magicbag"	
    inst.components.inventoryitem.atlasname = "images/inventoryimages/magicbag.xml"
    inst.components.inventoryitem.cangoincontainer = true	
	inst.components.inventoryitem:SetOnDroppedFn(ondropped)
	
    inst:AddComponent("container")
    inst.components.container:WidgetSetup("magicbag")
    inst.components.container.onopenfn = onopen
    inst.components.container.onclosefn = onclose
	
    return inst
end

return Prefab("common/chromebag2", fn, assets)
