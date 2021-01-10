require "prefabutil"

local assets =
{
	Asset("ANIM", "anim/crate_metal.zip"),
	Asset("ANIM", "anim/ui_safechest_3x3.zip"),	
	
	Asset("ATLAS", "images/inventoryimages/crate_metal.xml"),
    Asset("IMAGE", "images/inventoryimages/crate_metal.tex"),	
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
    inst.SoundEmitter:PlaySound("dontstarve/common/chest_craft")	
end

local function fn()
	local inst = CreateEntity()
	
    inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()	
		
	local minimap = inst.entity:AddMiniMapEntity()	
	minimap:SetIcon("crate_metal.tex")
	
	inst:AddTag("chest")
    inst.AnimState:SetBank("crate_metal")
    inst.AnimState:SetBuild("crate_metal")
    inst.AnimState:PlayAnimation("closed")
	
    inst.entity:SetPristine()	
	
    if not TheWorld.ismastersim then
        return inst
    end		
    
    inst:AddComponent("inspectable")
	
    inst:AddComponent("container")
    inst.components.container:WidgetSetup("crate_metal")    
    inst.components.container.onopenfn = onopen
    inst.components.container.onclosefn = onclose
    inst.components.container.skipopensnd = true
    inst.components.container.skipclosesnd = true

    inst:AddComponent("lootdropper")
	
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(8)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit) 
	
	inst:ListenForEvent("onbuilt", onbuilt)

	AddHauntableDropItemOrWork(inst)	
	
    return inst
end

return Prefab("common/crate_metal", fn, assets),
	   MakePlacer("common/crate_metal_placer", "crate_metal", "crate_metal", "closed") 