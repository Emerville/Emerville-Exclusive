require "prefabutil"

local prefabs =
{
	"collapse_small",
}

local assets =
{
	Asset("ANIM", "anim/quagmire_bollard.zip"),
	Asset("IMAGE", "images/inventoryimages/bollard.tex"),
	Asset("ATLAS", "images/inventoryimages/bollard.xml"),
}

local function onhammered(inst, worker)
    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("stone")
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
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst:AddTag("structure")
	inst:AddTag("statue")

	MakeObstaclePhysics(inst, .2)
	
    inst.AnimState:SetBank("quagmire_bollard")
    inst.AnimState:SetBuild("quagmire_bollard")
    inst.AnimState:PlayAnimation("idle")
    
	inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

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

return Prefab("post", fn, assets, prefabs),
	MakePlacer("post_placer", "quagmire_bollard", "quagmire_bollard", "idle")