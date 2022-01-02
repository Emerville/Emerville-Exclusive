-- File sourced from slingshotammo.lua

local assets =
{
    Asset("ANIM", "anim/slingshotammo.zip"),
}

local function OnAttack(inst, attacker, target)
    if target ~= nil and target:IsValid() and attacker ~= nil and attacker:IsValid() then
        local impactfx = SpawnPrefab("slingshotammo_hitfx_marble")
        impactfx.Transform:SetPosition(target.Transform:GetWorldPosition())
        inst.SoundEmitter:PlaySound("dontstarve/characters/walter/slingshot/marble")
    end
end

local function OnHit(inst, attacker, target)
    inst:Remove()
end

local function OnMiss(inst, owner, target)
    inst:Remove()
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.Transform:SetFourFaced()

    MakeProjectilePhysics(inst)

    inst.AnimState:SetBank("slingshotammo")
    inst.AnimState:SetBuild("slingshotammo")
    inst.AnimState:PlayAnimation("spin_loop", true)
    inst.AnimState:OverrideSymbol("rock", "slingshotammo", "marble")

    inst:AddTag("projectile")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(100)
    inst.components.weapon:SetOnAttack(OnAttack)

    inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(25)
    inst.components.projectile:SetHoming(false)
    inst.components.projectile:SetHitDist(1.5)
    inst.components.projectile:SetOnHitFn(OnHit)
    inst.components.projectile:SetOnMissFn(OnMiss)
    inst.components.projectile.range = 30
    inst.components.projectile.has_damage_set = true

    return inst
end

return Prefab("common/inventory/orangecane_proj", fn, assets)