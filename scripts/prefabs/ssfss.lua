local assets =
{
    Asset("ANIM", "anim/ssfss.zip"),
}

local prefabs =
{
    "marble",
	"reviver",
}

SetSharedLootTable('ssfss',
{
    { 'marble', 1.00 },
    { 'marble', 1.00 },
	{ 'marble', 1.00 },
	{ 'marble', 1.00 },
	{ 'reviver', 1.00 },
    { 'marble', 0.33 },
	{ 'marble', 0.33 },
})

local function OnWork(inst, worker, workleft)
    if workleft <= 0 then
        inst.SoundEmitter:PlaySound("dontstarve/wilson/rock_break")
        inst.components.lootdropper:DropLoot(inst:GetPosition())
        inst:Remove()
    elseif workleft <= 2 then
        inst.AnimState:PlayAnimation("destroyed3")
    elseif workleft <= 6 and workleft >= 5  then
        inst.AnimState:PlayAnimation("destroyed1")
	elseif workleft < 5 and workleft > 2 then
        inst.AnimState:PlayAnimation("destroyed2")
    else
        inst.AnimState:PlayAnimation("idle")
    end
end

local function broken_onrepaired(inst, doer, repair_item)
    if inst.components.workable.workleft < TUNING.MARBLEPILLAR_MINE / 3 then
        inst.AnimState:PlayAnimation("destroyed2")
        inst.SoundEmitter:PlaySound("dontstarve/common/ancienttable_repair")
    elseif inst.components.workable.workleft < TUNING.MARBLEPILLAR_MINE * 2 / 3 then
        inst.AnimState:PlayAnimation("destroyed1")
		inst.SoundEmitter:PlaySound("dontstarve/common/ancienttable_repair")
	else
        inst.AnimState:PlayAnimation("idle")
		inst.SoundEmitter:PlaySound("dontstarve/common/ancienttable_repair")
    end
end


local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst:AddTag("structure")

    MakeObstaclePhysics(inst, 0.33)

    inst.AnimState:SetBank("ssfss")
    inst.AnimState:SetBuild("ssfss")
    inst.AnimState:PlayAnimation("idle")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('ssfss')

    inst:AddComponent("inspectable")
    inst:AddComponent("workable")
    --TODO: Custom variables for mining speed/cost
    inst.components.workable:SetWorkAction(ACTIONS.MINE)
    inst.components.workable:SetWorkLeft(8)
    inst.components.workable:SetOnWorkCallback(OnWork)

	--inst:AddComponent("repairable")
    --inst.components.repairable.repairmaterial = "marble"
    --inst.components.repairable.onrepaired = broken_onrepaired
	
    MakeHauntableWork(inst)

    return inst
end

return Prefab("forest/objects/ssfss", fn, assets, prefabs)