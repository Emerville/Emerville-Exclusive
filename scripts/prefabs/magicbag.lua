local assets =
{
    Asset("ANIM", "anim/ui_chest_5x8.zip"),	
    Asset("ANIM", "anim/magicbag.zip"),	
	
    Asset("ATLAS", "images/inventoryimages/magicbag.xml"),
    Asset("IMAGE", "images/inventoryimages/magicbag.tex"),	
}

local function Sparkle(inst)
    if not inst.AnimState:IsCurrentAnimation("idle_sparkle") then
        inst.AnimState:PlayAnimation("idle_sparkle")
        inst.AnimState:PushAnimation("idle", true)
    end
    inst:DoTaskInTime(4 + math.random(), Sparkle)
end

local function ondropped(inst, owner)
    inst.components.container:Close(owner)
end

local function onopen(inst)
    inst.SoundEmitter:PlaySound("dontstarve/wilson/backpack_open")
end

local function onclose(inst)
    inst.SoundEmitter:PlaySound("dontstarve/wilson/backpack_close")
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
	
    inst.AnimState:SetBank("magicbag")
    inst.AnimState:SetBuild("magicbag")
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
    inst.components.container.skipopensnd = true
    inst.components.container.skipclosesnd = true
	
    inst:DoTaskInTime(1, Sparkle)
	
    return inst
end

return Prefab("common/magicbag", fn, assets)
