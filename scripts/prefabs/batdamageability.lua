local assets =
{
    Asset("ANIM", "anim/shadow_bishop.zip")

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




local function multihit(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
 local ents = TheSim:FindEntities(x, y, z, 2.7, nil, NON_SMASHABLE_TAGS, SMASHABLE_TAGS)
        for i, v in ipairs(ents) do
            if v:IsValid() and not v:IsInLimbo() then
               
        if v.components.combat ~= nil and not v:HasTag("bat") then
 
                    v.components.combat:GetAttacked(inst, 30, nil)
					
  end

end
end
end

local function KillSound(inst)
    inst.SoundEmitter:KillSound("bats")
end

local function RemoveMe(inst)
   inst.AnimState:PlayAnimation("atk_side_loop_pst")
	inst:DoTaskInTime(0.5, ErodeAway)	
end

local function SpawnAnimation(inst)
    SpawnPrefab("statue_transition_2").Transform:SetPosition(inst.Transform:GetWorldPosition())
    inst.SoundEmitter:PlaySound("dontstarve/sanity/bishop/attack_1", "bats")
end

local function fn()
    local inst = CreateEntity()
	
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork() 
	
    MakeInventoryPhysics(inst)
    RemovePhysicsColliders(inst)
	
	inst:AddTag("fx")
    inst:AddTag("scarytoprey")	
		
    inst.AnimState:SetBank("shadow_bishop")
    inst.AnimState:SetBuild("shadow_bishop")
    inst.AnimState:PushAnimation("atk_side_loop_pre", true)
	inst.AnimState:PushAnimation("atk_side_loop", true)
	inst.Transform:SetScale(0.8, 0.8, 0.8)
    inst.AnimState:SetMultColour(1, 1, 1, .7)

    if not TheWorld.ismastersim then
        return inst
    end

	inst.entity:SetPristine()
	
	inst:DoTaskInTime(5, KillSound)	
	inst:DoTaskInTime(0, SpawnAnimation)
    inst:DoTaskInTime(10, RemoveMe) 
    inst:DoPeriodicTask(1, multihit)
	 
    return inst
end

return Prefab( "common/inventory/batdamageability", fn, assets) 
