local assets =
{
    Asset("ANIM", "anim/gear_chest.zip"),
    Asset("ANIM", "anim/ui_chest_3x2.zip"),
}

local chests = {
	gear_chest = {
		bank="dragonfly_chest",
		build="gear_chest",
	},
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
	inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")	
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

local function chest(style)
	local fn = function(Sim)
		local inst = CreateEntity()
		
		inst.entity:AddTransform()
		inst.entity:AddAnimState()
		inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()		
		local minimap = inst.entity:AddMiniMapEntity()
		
		minimap:SetIcon( style..".png" )

		inst:AddTag("structure")
		inst.AnimState:SetBank(chests[style].bank)
		inst.AnimState:SetBuild(chests[style].build)
		inst.AnimState:PlayAnimation("closed")
		
        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end		
		
		inst:AddComponent("inspectable")
		
		inst:AddComponent("container")
        inst.components.container:WidgetSetup("treasurechest")		
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
		
		inst:ListenForEvent( "onbuilt", onbuilt)
				
		MakeSnowCovered(inst, .01)	
		return inst
	end
	return fn
end

-- Return our prefab
return Prefab("common/schest", chest("gear_chest"), assets)