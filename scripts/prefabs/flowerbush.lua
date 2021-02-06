require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/flowerbush.zip"),
    Asset("ATLAS", "images/inventoryimages/flowerbush.xml"),
    Asset("IMAGE", "images/inventoryimages/flowerbush.tex"),
}

local prefabs =
{
    "collapse_small",
}

local function onhit(inst, worker)
    if not inst:HasTag("burnt") and not inst:HasTag("pickedbush") then
        inst.AnimState:PlayAnimation("hammered")
        inst.AnimState:PushAnimation("idle")
    elseif inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("burnt_hammered")
        inst.AnimState:PushAnimation("burnt")
    elseif not inst:HasTag("burnt") and inst:HasTag("pickedbush")  then
        inst.AnimState:PlayAnimation("picked_hammered")
        inst.AnimState:PushAnimation("picked")
    end
end

local function onhammered(inst, worker)
    if inst:HasTag("fire") and inst.components.burnable then
        inst.components.burnable:Extinguish()
    end
    inst.components.lootdropper:DropLoot()
    SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
    inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")
    inst:Remove()
end

local function onregenfn(inst)
    inst.AnimState:PlayAnimation("empty_ongrowth1")
    inst.AnimState:PushAnimation("empty_ongrowth2")
    inst.AnimState:PushAnimation("idle", true)
    if inst:HasTag("pickedbush") then
        inst:RemoveTag("pickedbush")
    end
    inst:AddTag("flower")
end

local function onpickedfn(inst)
    inst.SoundEmitter:PlaySound("dontstarve/wilson/pickup_reeds")
    inst.AnimState:PlayAnimation("picked_full")
    inst.AnimState:PushAnimation("picked_empty")
    inst.AnimState:PushAnimation("picked")
    inst:AddTag("pickedbush")
    inst:RemoveTag("flower")
end

local function makeemptyfn(inst)
    inst.AnimState:PlayAnimation("picked")
end

local function onbuilt(inst)
    inst.AnimState:PlayAnimation("building")
    inst.AnimState:PushAnimation("idle")
    inst.SoundEmitter:PlaySound("dontstarve/common/farm_basic_craft")
end

local function onsave(inst, data)
    if inst:HasTag("burnt") or inst:HasTag("fire") then
        data.burnt = true
    end
end

local function OnBurnt(inst)
    inst.AnimState:PlayAnimation("burnt")
    inst.components.sanityaura.aura = 0
    inst:RemoveTag("flower")
--  inst.components.pickable:MakeEmpty()
--  inst.components.pickable:Pause()
--  inst.components.pickable.caninteractwith = false
end

local function onload(inst, data)
    if data and data.burnt then
        inst.components.burnable.onburnt(inst)
    end
end

----------------------------------

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst:AddTag("structure")
    inst.AnimState:SetBank("flowerbush")
    inst.AnimState:SetBuild("flowerbush")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("flower")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("lootdropper")

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)

    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = TUNING.SANITYAURA_TINY * 0.20

    inst:AddComponent("pickable")
    inst.components.pickable.picksound = "dontstarve/wilson/pickup_reeds"

    inst.components.pickable:SetUp("petals", TUNING.GRASS_REGROW_TIME, 2) --(Product, Regen, NumberToHarvest)
    inst.components.pickable.onregenfn = onregenfn
    inst.components.pickable.onpickedfn = onpickedfn
    inst.components.pickable.makeemptyfn = makeemptyfn

    MakeSmallBurnable(inst, nil, nil, true)
    MakeSmallPropagator(inst)

    inst.components.propagator.flashpoint = 115
    inst.components.propagator.decayrate = 1.1

    inst.OnSave = onsave
    inst.OnLoad = onload

    inst:ListenForEvent("onbuilt", onbuilt)
    inst:ListenForEvent("onburnt", OnBurnt)

    MakeHauntableWork(inst)

    return inst
end

return Prefab( "common/objects/flowerbush", fn, assets, prefabs),
       MakePlacer( "common/flowerbush_placer", "flowerbush", "flowerbush", "idle" )
