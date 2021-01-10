local assets =
{
	Asset("ANIM", "anim/ice_chest.zip"),
    Asset("ANIM", "anim/ui_chest_4x4.zip"),		
	
	Asset("ATLAS", "images/inventoryimages/ice_chest.xml"),
	Asset("IMAGE", "images/inventoryimages/ice_chest.tex"),		
}

local prefabs =
{
	"collapse_small",
}

local function onopen(inst)
	inst.AnimState:PlayAnimation("open")
	inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open")	
end 

local function onclose(inst) 
	inst.AnimState:PlayAnimation("close")
	inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close")		
end 

local function onhammered(inst, worker)
	inst.components.lootdropper:DropLoot()
	inst.components.container:DropEverything()
	SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
	inst.SoundEmitter:PlaySound("dontstarve/common/destroy_metal")	
	inst:Remove()
end

local function onhit(inst, worker)
	inst.AnimState:PlayAnimation("hit")
	inst.components.container:DropEverything() 
	inst.AnimState:PushAnimation("closed", false)
	inst.components.container:Close()
end

local function onbuilt(inst)
	inst.AnimState:PlayAnimation("place")
	inst.AnimState:PushAnimation("closed", false)
end

local function fn()
	local inst = CreateEntity()
		
	inst:AddTag("fridge")
    inst:AddTag("structure")
	
    inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()
	
	MakeObstaclePhysics(inst, .3)
		
	local minimap = inst.entity:AddMiniMapEntity()	
	minimap:SetIcon("ice_chest.tex")
	
    inst.AnimState:SetBank("ice_chest")
    inst.AnimState:SetBuild("ice_chest")
    inst.AnimState:PlayAnimation("close")

	inst.entity:SetPristine()
	
    if not TheWorld.ismastersim then
        return inst
    end	
    
    inst:AddComponent("inspectable")
	
    inst:AddComponent("container")
	
    inst.components.container:WidgetSetup("ice_chest")   
    inst.components.container.onopenfn = onopen
    inst.components.container.onclosefn = onclose
    inst.components.container.skipopensnd = true
    inst.components.container.skipclosesnd = true

    inst:AddComponent("lootdropper")
	
--[[    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(6)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit) ]]
	
	inst:ListenForEvent( "onbuilt", onbuilt)
		
    return inst
end

return Prefab("common/ice_chest", fn, assets),
	   MakePlacer("common/ice_chest_placer", "ice_chest", "ice_chest", "closed") 