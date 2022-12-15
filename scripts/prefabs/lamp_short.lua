require "prefabutil"

local prefabs =
{
	"collapse_small",
}

local assets =
{
	Asset("ANIM", "anim/quagmire_lamp_short.zip"),
	
	Asset("IMAGE", "images/inventoryimages/lamp_post.tex"),
	Asset("ATLAS", "images/inventoryimages/lamp_post.xml"),
}

local function onhammered(inst, worker)
    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("metal")
    inst:Remove()
end

local function onhit(inst, worker)
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:PushAnimation("idle", false)
end

local function onbuilt(inst)
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:PushAnimation("idle", false)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
	inst.entity:AddLight()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst:AddTag("structure")

	MakeObstaclePhysics(inst, .2)
	
    inst.AnimState:SetBank("quagmire_lamp_short")
    inst.AnimState:SetBuild("quagmire_lamp_short")
    inst.AnimState:PlayAnimation("idle")

	inst.Light:SetRadius(4)
    inst.Light:SetIntensity(.9)
    inst.Light:SetFalloff(.9)
    inst.Light:SetColour(1, 1, 1)
    inst.Light:Enable(true)
    inst.Light:EnableClientModulation(true)
    
	inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    --[[inst:AddComponent("container")
    inst.components.container:WidgetSetup("icebox")
    inst.components.container.onopenfn = onopen
    inst.components.container.onclosefn = onclose
    inst.components.container.skipopensnd = true
    inst.components.container.skipclosesnd = true]]--

    --[[inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(3)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)]] 

    inst:ListenForEvent("onbuilt", onbuilt)
    --MakeSnowCovered(inst)

    --AddHauntableDropItemOrWork(inst)

    return inst
end

return Prefab("lamp_short", fn, assets, prefabs),
	MakePlacer("lamp_short_placer", "quagmire_lamp_short", "quagmire_lamp_short", "idle")