local assets =
{
    Asset("ANIM", "anim/star_cold.zip")

}
local SMASHABLE_WORK_ACTIONS =
{
    CHOP = false,
    DIG = false,
    HAMMER = false,
    MINE = false,
	ATTACK = true,
}
local SMASHABLE_TAGS = { "_combat" }
for k, v in pairs(SMASHABLE_WORK_ACTIONS) do
    table.insert(SMASHABLE_TAGS, k.."_workable")
end
local NON_SMASHABLE_TAGS = { "INLIMBO", "playerghost" }




local function OnThrown(inst)
    inst:DoTaskInTime(0.6, inst.Remove)
	
	
end

local function OnHit(inst, owner, target)
    inst.SoundEmitter:PlaySound("dontstarve/common/blackpowder_explo")
	inst:Remove()
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    MakeInventoryPhysics(inst)
    RemovePhysicsColliders(inst)
    inst.entity:AddNetwork()
	
    inst.AnimState:SetBank("star_cold")
    inst.AnimState:SetBuild("star_cold")
	inst.AnimState:PlayAnimation("idle_loop")
    inst.AnimState:PushAnimation("idle_loop", true)
	    inst.Transform:SetScale(0.5, 0.5, 0.5)

    inst:AddTag("projectile")
	
	
    inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(40)
	    inst.components.projectile:SetHoming(false)
    inst.components.projectile:SetHitDist(0.3)
	    inst.components.projectile:SetOnThrownFn(OnThrown)
		    inst.components.projectile:SetOnHitFn(OnHit)
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false


    return inst
end



return Prefab("swing_charge", fn, assets)
