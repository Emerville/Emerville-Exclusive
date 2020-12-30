require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/xmastree.zip"),
	
    Asset("ATLAS", "images/inventoryimages/xmastree.xml"),
    Asset("IMAGE", "images/inventoryimages/xmastree.tex"),
}

local prefabs = 
{
	"collapse_small",
}
--------------------------------

local function onhit(inst, worker)
	if not inst:HasTag("burnt") then
		inst.AnimState:PlayAnimation("hammered")
		inst.AnimState:PushAnimation("idle")
	elseif inst:HasTag("burnt") then
		inst.AnimState:PlayAnimation("idle")
		inst.AnimState:PushAnimation("burnt")
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

local function onbuilt(inst)
    inst.AnimState:PlayAnimation("building")
    inst.AnimState:PushAnimation("idle")
    inst.SoundEmitter:PlaySound("dontstarve/common/farm_improved_craft")	
end

local function OnBurnt(inst)
	inst.AnimState:PlayAnimation("burnt")
--	inst.components.sanityaura.aura = 0
end
	
local function onsave(inst, data)
    if inst:HasTag("burnt") or inst:HasTag("fire") then
        data.burnt = true
    end
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
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

	MakeObstaclePhysics(inst, .1)
	
    local minimap = inst.entity:AddMiniMapEntity()
    minimap:SetIcon("xmastree.tex")

    inst:AddTag("structure")
	inst:AddTag("shelter")	
    inst.AnimState:SetBank("xmastree")
    inst.AnimState:SetBuild("xmastree")
    inst.AnimState:PlayAnimation("idle")

	inst.entity:SetPristine()	
	
    if not TheWorld.ismastersim then
        return inst
    end
	
    inst:AddComponent("lootdropper")	
    inst:AddComponent("inspectable")
	
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
	inst.components.workable:SetOnFinishCallback(onhammered)
	inst.components.workable:SetOnWorkCallback(onhit)

	inst:ListenForEvent("onbuilt", onbuilt)
	
--	inst:AddComponent("sanityaura")
--   inst.components.sanityaura.aura = TUNING.SANITYAURA_MED*0.25
	
	MakeMediumBurnable(inst, nil, nil, true)
    MakeMediumPropagator(inst)
	inst.components.propagator.flashpoint = 115
	inst.components.propagator.decayrate = 1.1
	
	inst:ListenForEvent("onburnt", OnBurnt)
	
	inst.OnSave = onsave 
    inst.OnLoad = onload
	
	MakeHauntableWork(inst)
	
    return inst
end

return Prefab( "common/objects/xmastree", fn, assets, prefabs),
       MakePlacer( "common/xmastree_placer", "xmastree", "xmastree", "idle") 