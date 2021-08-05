require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/freezereye.zip"),
	Asset("ANIM", "anim/ui_chest_2x2.zip"),	
	
    Asset("ATLAS", "images/inventoryimages/freezereye.xml"),
    Asset("IMAGE", "images/inventoryimages/freezereye.tex"),
}

local prefabs = 
{
	"collapse_small",
}
--------------------------------

local function onopen(inst) 
	inst.AnimState:PlayAnimation("open") 
    inst.SoundEmitter:PlaySound("dontstarve/common/icebox_open")
	inst.Light:Enable(true)
end 

local function onclose(inst) 
	inst.AnimState:PlayAnimation("idle", true) 
    inst.SoundEmitter:PlaySound("dontstarve/common/icebox_close")
    inst.Light:Enable(false)	
end 

-------------------------------

local function onhammered(inst, worker)
	inst.components.lootdropper:DropLoot()	
    inst.components.container:DropEverything()	
	SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
	inst.SoundEmitter:PlaySound("dontstarve/common/destroy_metal")
	inst:Remove()
end

local function onhit(inst, worker)
	inst.AnimState:PlayAnimation("hammered")
	inst.components.container:DropEverything()
	inst.AnimState:PushAnimation("idle", true)
    inst.components.container:Close()
end

local function onbuilt(inst)
    inst.AnimState:PlayAnimation("building")
    inst.AnimState:PushAnimation("idle", true)
    inst.SoundEmitter:PlaySound("dontstarve/common/icebox_craft")	
end

-------------------------------

local function fn()
    local inst = CreateEntity()
	
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
	inst.entity:AddLight()	
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()
	
    local minimap = inst.entity:AddMiniMapEntity()
    minimap:SetIcon("freezereye.tex")	
	
    inst.AnimState:SetBank("freezereye")
    inst.AnimState:SetBuild("freezereye")
    inst.AnimState:PlayAnimation("idle", true)
	
    inst.Light:Enable(false)
    inst.Light:SetRadius(1)
    inst.Light:SetFalloff(.8)
    inst.Light:SetIntensity(.3)
    inst.Light:SetColour(255/255,255/255,255/255)	

    inst:AddTag("fridge")
	inst:AddTag("freezeye")
    inst:AddTag("structure")	
	
    inst.SoundEmitter:PlaySound("dontstarve/common/ice_box_LP", "idlesound")	
	
	inst.entity:SetPristine()	

    if not TheWorld.ismastersim then
        return inst
    end
	
    inst:AddComponent("inspectable")
	
    inst:AddComponent("preserver")
	inst.components.preserver:SetPerishRateMultiplier(0.25)	
	
	inst:AddComponent("container")
    inst.components.container:WidgetSetup("freezereye")
    inst.components.container.onopenfn = onopen
    inst.components.container.onclosefn = onclose
    inst.components.container.skipopensnd = true
    inst.components.container.skipclosesnd = true
	
    inst:AddComponent("lootdropper")	
	
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(6)
	inst.components.workable:SetOnFinishCallback(onhammered)
	inst.components.workable:SetOnWorkCallback(onhit)

	inst:ListenForEvent("onbuilt", onbuilt)
	
	AddHauntableDropItemOrWork(inst)
	
    return inst
end

return Prefab("common/objects/freezereye", fn, assets, prefabs),
       MakePlacer("common/freezereye_placer", "freezereye", "freezereye", "idle" ) 