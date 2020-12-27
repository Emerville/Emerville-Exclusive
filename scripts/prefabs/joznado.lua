local assets =
{
    Asset("ANIM", "anim/tornado.zip"),
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
 local ents = TheSim:FindEntities(x, y, z, 4, nil, NON_SMASHABLE_TAGS, SMASHABLE_TAGS)
        for i, v in ipairs(ents) do
            --V2C: things "could" go invalid if something earlier in the list
            --     removes something later in the list.
            --     another problem is containers, occupiables, traps, etc.
            --     inconsistent behaviour with what happens to their contents
            --     also, make sure stuff in backpacks won't just get removed
            --     also, don't dig up spawners
            if v:IsValid() and not v:IsInLimbo() then
               
        if v.components.combat ~= nil then
				 if v:HasTag("player") or v:HasTag("character") then
				 else
                    v.components.combat:GetAttacked(inst, 4, nil)
					
  end

end
end
end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("tornado")
    inst.AnimState:SetBuild("tornado")
    inst.AnimState:PlayAnimation("tornado_pre")
    inst.AnimState:PushAnimation("tornado_loop")
	inst:AddTag("fx")
    inst.Transform:SetScale(1.5, 1.5, 1.5)
	inst.AnimState:SetMultColour(1,1,0,1)
	
    inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/tornado", "spinLoop")

    MakeInventoryPhysics(inst)
    RemovePhysicsColliders(inst)

    inst.entity:SetPristine()

	    inst.OFFSPELLCASTER = nil
	
    if not TheWorld.ismastersim then
        return inst
    end


inst:DoPeriodicTask(.2, multihit)

    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = 0
    inst.components.locomotor.runspeed = 0






    inst:DoTaskInTime(1.0, inst.Remove)
    return inst
end

return Prefab( "common/inventory/joznado", fn, assets) 
