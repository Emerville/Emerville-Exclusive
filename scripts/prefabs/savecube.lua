local assets =
{
    Asset("ANIM", "anim/savecube.zip"),
    Asset("ATLAS", "images/inventoryimages/savecube.xml"),
    Asset("IMAGE", "images/inventoryimages/savecube.tex"),
}

--[[local function onhammered(inst, worker)
    inst.components.lootdropper:DropLoot()
    --SpawnPrefab("collapse_big").Transform:SetPosition(inst.Transform:GetWorldPosition())
    inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")
    inst:Remove()
end]]

local function onhit(inst, worker)
    inst.AnimState:PlayAnimation("idle_loop") --hit
    inst.AnimState:PushAnimation("idle_loop", true)
end

local function onfinished(inst)
    inst.SoundEmitter:PlaySound("dontstarve/common/tent_dis_pre")
    inst:Remove()
end

local function onhaunt(inst, doer)
    local fx = SpawnPrefab("lavaarena_player_revive_from_corpse_fx")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    inst.components.finiteuses:Use(1)
    return inst._onhaunt(inst, doer)
end

local function onbuilt(inst)
    inst.AnimState:PlayAnimation("idle") --place
    inst.AnimState:PushAnimation("idle", false)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()

    if not GetGhostEnabled(TheNet:GetServerGameMode()) then
        inst.entity:Hide()
        inst:DoTaskInTime(0, inst.Remove)
        return inst
    end

    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, .5)

    inst.AnimState:SetBank("savecube")
    inst.AnimState:SetBuild("savecube")
    inst.AnimState:PlayAnimation("idle_loop", true)

    inst:AddTag("resurrector")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(20)
    inst.components.finiteuses:SetUses(20)
    inst.components.finiteuses:SetOnFinished(onfinished)

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_INSTANT_REZ)
    inst._onhaunt = inst.components.hauntable.onhaunt
    inst.components.hauntable:SetOnHauntFn(onhaunt)

    return inst
end

return Prefab("common/objects/savecube", fn, assets),
       MakePlacer( "common/savecube_placer", "savecube", "savecube", "idle")