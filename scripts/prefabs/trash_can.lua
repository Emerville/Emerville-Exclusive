require "prefabutil"

local assets =
{
	Asset("ANIM", "anim/trash_can.zip"),
    Asset("ANIM", "anim/ui_cookpot_1x4.zip"),
	
	Asset("ATLAS", "images/inventoryimages/trash_can.xml"),
	Asset("IMAGE", "images/inventoryimages/trash_can.tex"),
}

local prefabs =
{
	"collapse_small",
}

local function onopen(inst)
	inst.AnimState:PlayAnimation("open")
	inst.SoundEmitter:PlaySound("dontstarve/common/cookingpot_open")
end 

local function onclose(inst) 
	inst.AnimState:PlayAnimation("close")
	inst.SoundEmitter:PlaySound("dontstarve/common/cookingpot_close")	
end 

local function onhammered(inst, worker)
	if inst:HasTag("fire") and inst.components.burnable then
		inst.components.burnable:Extinguish()
	end
	inst.components.lootdropper:DropLoot()
	if inst.components.container then inst.components.container:DropEverything() end
	SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
	inst.SoundEmitter:PlaySound("dontstarve/common/destroy_metal")
	inst:Remove()
end

local function onhit(inst, worker)
	inst.AnimState:PlayAnimation("hit")
	inst.AnimState:PushAnimation("closed", false)
	if inst.components.container then 
		inst.components.container:DropEverything() 
		inst.components.container:Close()
	end
end

local function onbuilt(inst)
	inst.AnimState:PlayAnimation("place")
	inst.AnimState:PushAnimation("closed", false)
end
	
local function fn()
	local inst = CreateEntity()
	
    inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()	
	
	MakeObstaclePhysics(inst, .1)
		
	local minimap = inst.entity:AddMiniMapEntity()	
	minimap:SetIcon("trash_can.tex")
	
	inst:AddTag("structure")
	inst:AddTag("chest")
    inst.AnimState:SetBank("trash_can")
    inst.AnimState:SetBuild("trash_can")
    inst.AnimState:PlayAnimation("close")
	
	inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
    
    inst:AddComponent("inspectable")
    inst:AddComponent("container")
	inst.components.container:WidgetSetup("trash_can")	
    inst.components.container.onopenfn = onopen
    inst.components.container.onclosefn = onclose
    inst.components.container.skipopensnd = true
    inst.components.container.skipclosesnd = true

    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(2)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)
	
	inst:ListenForEvent("onbuilt", onbuilt)

	AddHauntableDropItemOrWork(inst)
	
    return inst
end

return	Prefab("common/trash_can", fn, assets),
		MakePlacer("common/trash_can_placer", "trash_can", "trash_can", "closed") 
