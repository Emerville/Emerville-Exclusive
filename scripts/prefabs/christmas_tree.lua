require "prefabutil"

local assets =
{
	Asset("ANIM", "anim/christmas_tree.zip"),
	
    Asset("ATLAS", "images/inventoryimages/christmas_tree.xml"), 
    Asset("IMAGE", "images/inventoryimages/christmas_tree.tex"),	
}

local prefabs = 
{
	"collapse_small",
}

local function onhammered(inst, worker)
	inst.components.lootdropper:DropLoot()
	SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
	inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")
	inst:Remove()
end

local function onhit(inst, worker)
	inst.AnimState:PushAnimation("christmas")
end

local function onbuilt(inst)
	inst.AnimState:PushAnimation("christmas")
	inst.SoundEmitter:PlaySound("dontstarve/common/farm_improved_craft")		
end

local function fn(Sim)
	local inst = CreateEntity()
	
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddLight()
	inst.entity:AddNetwork()
	
	MakeObstaclePhysics(inst, 0.9)	

	inst.AnimState:SetBank("christmas_tree")
	inst.AnimState:SetBuild("christmas_tree")
	inst.AnimState:PlayAnimation("christmas", true)
	
	inst.Light:Enable(true)
	--inst.Light:SetIntensity(.75)
	inst.Light:SetIntensity(0.85)
	--inst.Light:SetColour(252/255,251/255,237/255)
	inst.Light:SetColour(248/255,255/255,255/255)
	inst.Light:SetFalloff(0.6)
	inst.Light:SetRadius(1.5)	
	
	inst.entity:SetPristine()	
	
    if not TheWorld.ismastersim then
        return inst
    end	
	
	inst:AddComponent("inspectable")

	inst:ListenForEvent("onbuilt", onbuilt)	

	inst:AddComponent("sanityaura")
	inst.components.sanityaura.aura = TUNING.SANITYAURA_MED

	inst:AddComponent("lootdropper")
	inst:AddComponent("workable")
	inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
	inst.components.workable:SetWorkLeft(3)
	inst.components.workable:SetOnFinishCallback(onhammered)
	inst.components.workable:SetOnWorkCallback(onhit)
	
	MakeHauntableWork(inst)	

	return inst
end

return Prefab("common/christmas_tree", fn, assets),
	   MakePlacer("common/christmas_tree_placer", "christmas_tree", "christmas_tree", "christmas") 