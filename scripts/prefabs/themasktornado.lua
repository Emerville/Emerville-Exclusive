local assets =
{
    Asset("ANIM", "anim/tornado.zip"),
}
local SMASHABLE_WORK_ACTIONS =
{
    CHOP = true,
    DIG = true,
    HAMMER = false,
    MINE = true,
	ATTACK = true,
}
local SMASHABLE_TAGS = { "_combat", "_inventoryitem", "NPC_workable" }
for k, v in pairs(SMASHABLE_WORK_ACTIONS) do
    table.insert(SMASHABLE_TAGS, k.."_workable")
end
local NON_SMASHABLE_TAGS = { "INLIMBO", "playerghost" }

local function multihit(inst)
    local shakeduration = .5
    local shakespeed = .02 
    local shakescale = .5 
    local shakemaxdist = 20 
    ShakeAllCameras(CAMERASHAKE.FULL, shakeduration, shakespeed, shakescale, inst, shakemaxdist)

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
                if v.components.workable ~= nil then
                    if v.components.workable:CanBeWorked() and not (v.sg ~= nil and v.sg:HasStateTag("busy")) then
                        local work_action = v.components.workable:GetWorkAction()
                        --V2C: nil action for NPC_workable (e.g. campfires)
                        if (    (work_action == nil and v:HasTag("NPC_workable")) or
                                (work_action ~= nil and SMASHABLE_WORK_ACTIONS[work_action.id]) ) and
                            (work_action ~= ACTIONS.DIG
                            or (v.components.spawner == nil and
                                v.components.childspawner == nil)) then
                            v.components.workable:WorkedBy(inst, inst.workdone or 20)
                        end
                    end
					elseif v.components.combat ~= nil then
       					if v:HasTag("player") or v:HasTag("character") then
						else
						v.components.combat:GetAttacked(inst, 20, nil)
						end
                    elseif v.components.mine ~= nil and not v.components.mine.inactive then
                        -- Always smash things on the periphery so that we don't end up with a ring of flung loot
                        v.components.mine:Deactivate()
                    elseif (inst.peripheral or math.random() <= TUNING.METEOR_SMASH_INVITEM_CHANCE) then
                        -- Always smash things on the periphery so that we don't end up with a ring of flung loot
                        SpawnPrefab("ground_chunks_breaking").Transform:SetPosition(x, y, z)
                    end
                end
            end
        end	
           
        --[[if v.components.combat ~= nil then
				 if v:HasTag("player") or v:HasTag("character") then
				 else
                    v.components.combat:GetAttacked(inst, 4, nil)]]
					


local function kill_fx(inst)
    inst.AnimState:PlayAnimation("close")
    inst:DoTaskInTime(.6, inst.Remove)
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
    inst.Transform:SetScale(1.5, 1.5, 1.5)
	inst.AnimState:SetMultColour(1,1,0,1)
	
    inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/tornado", "spinLoop")

    MakeInventoryPhysics(inst)
    RemovePhysicsColliders(inst)
	--inst:AddTag("fx")

    inst.entity:SetPristine()

	--inst.OFFSPELLCASTER = nil
	
    if not TheWorld.ismastersim then
        return inst
    end

	inst:DoPeriodicTask(.2, multihit)
    inst:DoTaskInTime(1.0, inst.Remove)
	
    inst.kill_fx = kill_fx
	
    return inst
end

return Prefab( "common/inventory/themasktornado", fn, assets) 
