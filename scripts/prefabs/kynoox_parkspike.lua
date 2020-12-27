local assets =
{
    Asset("ANIM", "anim/quagmire_park_fence.zip"),
	
	Asset("IMAGE", "images/inventoryimages/fence.tex"),
	Asset("ATLAS", "images/inventoryimages/fence.xml"),
	
	Asset("IMAGE", "images/inventoryimages/fence2.tex"),
	Asset("ATLAS", "images/inventoryimages/fence2.xml"),
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
    --inst.AnimState:PushAnimation("idle", false)
end

local function onbuilt(inst)
    inst.AnimState:PlayAnimation("idle")
    --inst.AnimState:PushAnimation("idle", false)
end

local function fn(anim)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("quagmire_park_fence")
    inst.AnimState:SetBuild("quagmire_park_fence")
    inst.AnimState:PlayAnimation("idle")

    MakeObstaclePhysics(inst, .2)
	
	inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
	
	inst:AddComponent("inspectable")
	
    inst:AddComponent("lootdropper")
    --[[inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)]]

    inst:ListenForEvent("onbuilt", onbuilt)
	
	return inst
end

local function tallfn()
    return fn("idle")
end

local function shortfn()
    return fn("idle_short")
end

return Prefab("kynoox_parkspike", tallfn, assets),
	MakePlacer("kynoox_parkspike_placer", "quagmire_park_fence", "quagmire_park_fence", "idle")