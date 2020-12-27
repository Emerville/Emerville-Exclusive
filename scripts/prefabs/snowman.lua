require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/snowman.zip"),
	
    Asset("ATLAS", "images/inventoryimages/snowman.xml"),
    Asset("IMAGE", "images/inventoryimages/snowman.tex"),
}

local prefabs = 
{
	"collapse_small",
}
--------------------------------

local function onhit(inst, worker)
	if not inst:HasTag("burnt") then
		inst.AnimState:PlayAnimation("idle_hammered")
		inst.AnimState:PushAnimation("idle")
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
end

----------------------------------

local function onfiremelt(inst)
    inst.components.perishable.frozenfiremult = true
end

local function onstopfiremelt(inst)
    inst.components.perishable.frozenfiremult = false
end
---------------------------------

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, 0.2)
	
	MakeSmallPropagator(inst)
	
    local minimap = inst.entity:AddMiniMapEntity()
    minimap:SetIcon( "snowman.tex" )

    inst.AnimState:SetBank("snowman")
    inst.AnimState:SetBuild("snowman")
    inst.AnimState:PlayAnimation("idle")

	inst:ListenForEvent("firemelt", onfiremelt)
    inst:ListenForEvent("stopfiremelt", onstopfiremelt)
	
    inst:AddTag("structure")
    inst:AddTag("frozen")

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

	inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = TUNING.SANITYAURA_TINY*0.40
	
	inst:ListenForEvent("onbuilt", onbuilt)
	
	inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.PERISH_SUPERFAST)
    inst.components.perishable:StartPerishing()
    inst.components.perishable.onperishreplacement = "snowmanmelt1"
	
	MakeHauntableWork(inst)
	
    return inst
end

return Prefab("common/objects/snowman", fn, assets, prefabs),
       MakePlacer("common/snowman_placer", "snowman", "snowman", "idle") 