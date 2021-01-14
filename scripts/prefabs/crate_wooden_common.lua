local function MakeStatueRobobeeSkin( name )

require "prefabutil"

local assets =
{
	Asset("ANIM", "anim/crate_wooden" .. name .. ".zip"),
	Asset("ANIM", "anim/firefighter_placement.zip"),
    Asset("ANIM", "anim/ui_chest_5x12.zip"),


	Asset("ATLAS", "images/inventoryimages/crate_wooden.xml"),
	Asset("IMAGE", "images/inventoryimages/crate_wooden.tex"),	
}

local prefabs =
{
	"collapse_small",
}

local PLACER_SCALE = 1.55

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

local function onhammered(inst, worker)
	if inst:HasTag("fire") and inst.components.burnable then
		inst.components.burnable:Extinguish()
	end
    inst.components.lootdropper:DropLoot()
    if inst.components.container ~= nil then
        inst.components.container:DropEverything()
    end
	SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
	inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")
	inst:Remove()
end

local function onhit(inst, worker)
	if not inst:HasTag("burnt") then
		inst.AnimState:PlayAnimation("hit")
		inst.AnimState:PushAnimation("closed", false)
		if inst.components.container then 
			inst.components.container:Close()
		end
	end
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

local function onbuilt(inst)
	inst.AnimState:PlayAnimation("place")
	inst.AnimState:PushAnimation("closed", false)
	inst.SoundEmitter:PlaySound("dontstarve/common/dragonfly_chest_craft")
end

local function placer_postinit_fn(inst)
    --Show the placer on top of the range ground placer

    local placer3 = CreateEntity()

    --[[Non-networked entity]]
    placer3.entity:SetCanSleep(false)
    placer3.persists = false

    placer3.entity:AddTransform()
    placer3.entity:AddAnimState()

    placer3:AddTag("CLASSIFIED")
    placer3:AddTag("NOCLICK")
    placer3:AddTag("placer")

    local s = 1 / PLACER_SCALE
    placer3.Transform:SetScale(s, s, s)

    placer3.AnimState:SetBank("crate_wooden")
    placer3.AnimState:SetBuild("crate_wooden")
    placer3.AnimState:PlayAnimation("closed")
    placer3.AnimState:SetLightOverride(1)

    placer3.entity:SetParent(inst.entity)

    inst.components.placer:LinkEntity(placer3)
end

local function placer_postinit_fn_present(inst)
    --Show the placer on top of the range ground placer

    local placer3 = CreateEntity()

    --[[Non-networked entity]]
    placer3.entity:SetCanSleep(false)
    placer3.persists = false

    placer3.entity:AddTransform()
    placer3.entity:AddAnimState()

    placer3:AddTag("CLASSIFIED")
    placer3:AddTag("NOCLICK")
    placer3:AddTag("placer")

    local s = 1 / PLACER_SCALE
    placer3.Transform:SetScale(s, s, s)

    placer3.AnimState:SetBank("crate_wooden_present")
    placer3.AnimState:SetBuild("crate_wooden_present")
    placer3.AnimState:PlayAnimation("closed")
    placer3.AnimState:SetLightOverride(1)

    placer3.entity:SetParent(inst.entity)

    inst.components.placer:LinkEntity(placer3)
end

local function placer_postinit_fn_scary(inst)
    --Show the placer on top of the range ground placer

    local placer3 = CreateEntity()

    --[[Non-networked entity]]
    placer3.entity:SetCanSleep(false)
    placer3.persists = false

    placer3.entity:AddTransform()
    placer3.entity:AddAnimState()

    placer3:AddTag("CLASSIFIED")
    placer3:AddTag("NOCLICK")
    placer3:AddTag("placer")

    local s = 1 / PLACER_SCALE
    placer3.Transform:SetScale(s, s, s)

    placer3.AnimState:SetBank("crate_wooden_scary")
    placer3.AnimState:SetBuild("crate_wooden_scary")
    placer3.AnimState:PlayAnimation("closed")
    placer3.AnimState:SetLightOverride(1)

    placer3.entity:SetParent(inst.entity)

    inst.components.placer:LinkEntity(placer3)
end

local function placer_postinit_fn_gingerbread(inst)
    --Show the placer on top of the range ground placer

    local placer3 = CreateEntity()

    --[[Non-networked entity]]
    placer3.entity:SetCanSleep(false)
    placer3.persists = false

    placer3.entity:AddTransform()
    placer3.entity:AddAnimState()

    placer3:AddTag("CLASSIFIED")
    placer3:AddTag("NOCLICK")
    placer3:AddTag("placer")

    local s = 1 / PLACER_SCALE
    placer3.Transform:SetScale(s, s, s)

    placer3.AnimState:SetBank("crate_wooden_gingerbread")
    placer3.AnimState:SetBuild("crate_wooden_gingerbread")
    placer3.AnimState:PlayAnimation("closed")
    placer3.AnimState:SetLightOverride(1)

    placer3.entity:SetParent(inst.entity)

    inst.components.placer:LinkEntity(placer3)
end


local function placer_postinit_fn_3d(inst)
    --Show the placer on top of the range ground placer

    local placer3 = CreateEntity()

    --[[Non-networked entity]]
    placer3.entity:SetCanSleep(false)
    placer3.persists = false

    placer3.entity:AddTransform()
    placer3.entity:AddAnimState()

    placer3:AddTag("CLASSIFIED")
    placer3:AddTag("NOCLICK")
    placer3:AddTag("placer")

    local s = 1 / PLACER_SCALE
    placer3.Transform:SetScale(s, s, s)

    placer3.AnimState:SetBank("crate_wooden_3d")
    placer3.AnimState:SetBuild("crate_wooden_3d")
    placer3.AnimState:PlayAnimation("closed")
    placer3.AnimState:SetLightOverride(1)

    placer3.entity:SetParent(inst.entity)

    inst.components.placer:LinkEntity(placer3)
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
    inst.AnimState:SetBank("crate_wooden" .. name)
    inst.AnimState:SetBuild("crate_wooden" .. name)
    inst.AnimState:PlayAnimation("closed")
	
    inst.entity:SetPristine()	
	
    if not TheWorld.ismastersim then
        return inst
    end		
    
    inst:AddComponent("inspectable")
	
    inst:AddComponent("container")
    inst.components.container:WidgetSetup("crate_wooden")     
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
	
	MakeMediumBurnable(inst, nil, nil, true)
	MakeMediumPropagator(inst)
	
	AddHauntableDropItemOrWork(inst)	

    return inst
	
	end

	local function GetPlacerFn(var)
		if var and var == "_gingerbread" then 
			return placer_postinit_fn_gingerbread 
		elseif var and var == "_present" then
			return placer_postinit_fn_present
		elseif var and var == "_scary" then
			return placer_postinit_fn_scary
		elseif var and var == "_3d" then
			return placer_postinit_fn_3d
		else
			return placer_postinit_fn 
		end
	end	

    return Prefab("crate_wooden" .. name, fn, assets),
	 MakePlacer("crate_wooden_placer" .. name, "crate_wooden_placement", "firefighter_placement", "closed", true, nil, nil, PLACER_SCALE, nil, nil, GetPlacerFn(name))
end

return MakeStatueRobobeeSkin
--------------
--return Prefab("common/crate_wooden", fn, assets),
--	   MakePlacer("common/crate_wooden_placer", "crate_wooden", "crate_wooden", "closed") 