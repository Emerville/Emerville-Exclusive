require "prefabutil"

local assets =
{
	Asset("ANIM", "anim/crate_wooden_3d.zip"),
	Asset("ANIM", "anim/firefighter_placement.zip"),
    Asset("ANIM", "anim/ui_chest_5x12.zip"),

	Asset("ATLAS", "images/inventoryimages/crate_wooden.xml"),
	Asset("IMAGE", "images/inventoryimages/crate_wooden.tex"),	
}

local prefabs =
{
	"collapse_small",
}

local function onopen(inst)
	if not inst:HasTag("burnt") then
		inst.AnimState:PlayAnimation("open")
		inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open")	
	end
end 

local function onclose(inst) 
	if not inst:HasTag("burnt") then
		inst.AnimState:PlayAnimation("closed")
		inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close")		
	end
end 

local function onbuilt(inst)
	inst.AnimState:PlayAnimation("place")
	inst.AnimState:PushAnimation("closed", false)
	inst.SoundEmitter:PlaySound("dontstarve/common/dragonfly_chest_craft")
end

local function fn(Sim)
	local inst = CreateEntity()
	
    inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()	
	
	MakeObstaclePhysics(inst, .4)
		
	local minimap = inst.entity:AddMiniMapEntity()	
	minimap:SetIcon("crate_wooden.tex")
	
	inst:AddTag("structure")
	inst:AddTag("chest")
    inst.AnimState:SetBank("crate_wooden_3d")
    inst.AnimState:SetBuild("crate_wooden_3d")
    inst.AnimState:PlayAnimation("closed")
	
    inst.entity:SetPristine()	
	
    if not TheWorld.ismastersim then
        return inst
    end		
    
    inst:AddComponent("inspectable")
	
    inst:AddComponent("container")
    inst.components.container:WidgetSetup("casinocrate")     
    inst.components.container.onopenfn = onopen
    inst.components.container.onclosefn = onclose
    inst.components.container.skipopensnd = true
    inst.components.container.skipclosesnd = true

    inst:AddComponent("lootdropper")

	inst:ListenForEvent("onbuilt", onbuilt)	
	
	AddHauntableDropItemOrWork(inst)	

    return inst
end

return Prefab("common/casinocrate", fn, assets),
	 MakePlacer("common/crate_wooden_3d_placer", "crate_wooden_3d", "crate_wooden_3d", "closed")
