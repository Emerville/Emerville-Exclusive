local assets =
{
    Asset("ANIM", "anim/quagmire_portal.zip"),
    Asset("ANIM", "anim/quagmire_portal_base.zip"),
}

local prefabs =
{
    "quagmire_portal_activefx",
    "quagmire_portal_bubblefx",
    "quagmire_portal_player_fx",
    "quagmire_portal_playerdrip_fx",
    "quagmire_portal_player_splash_fx",
}

local fx_assets =
{
    Asset("ANIM", "anim/quagmire_portal_fx.zip"),
}

local fx_bubble_assets =
{
    Asset("ANIM", "anim/quagmire_portalbubbles_fx.zip"),
}




local function SpawnPlants(inst)
    inst.task = nil

    if inst.plant_ents ~= nil then
        return
    end
	
	local rock = "farmrock"
	local plant_type = "marsh_plant"
	
	
	local pi = 3.1415926535897932384626433
	
	inst.plant_ents = {}
    if inst.plants == nil then

	end
		
	inst.components.des_criver:make_circle(inst, rock, 2.75)
	inst.components.des_criver:make_circle(inst, plant_type, 2.4)

	inst.components.des_criver:make_water(inst)
	inst.components.des_criver:make_fish(inst)
	
	--[[	table.insert(inst.plants,
            {
                offset =
                {
                    math.sin(theta) * 0.9 + math.random() * .3,
                    0,
                    math.cos(theta) * 1.1 + math.random() * .3,
                },
            })
        end
    end

    inst.plant_ents = {}

    for i, v in pairs(inst.plants) do
        if type(v.offset) == "table" and #v.offset == 3 then
            local plant = SpawnPrefab(inst.planttype)
            if plant ~= nil then
                plant.entity:SetParent(inst.entity)
                plant.Transform:SetPosition(unpack(v.offset))
                plant.persists = false
				
				local s_plant = 0.6 + 0.2*math.random()
				plant.Transform:SetScale(s_plant,s_plant,s_plant,s_plant)
				
                table.insert(inst.plant_ents, plant)
            end
        end
    end--]]
end
local function CreateDropShadow(parent)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    --[[Non-networked entity]]

    inst.AnimState:SetBuild("quagmire_portal_base")
    inst.AnimState:SetBank("quagmire_portal_base")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(1)
    --inst.AnimState:OverrideSymbol("quagmire_portal01", "quagmire_portal", "shadow")

    inst.Transform:SetEightFaced()

    inst:AddTag("DECOR")
    inst:AddTag("NOCLICK")

    inst.presists = false
    inst.entity:SetParent(parent.entity)

    return inst
end

local function OnFocusCamera(inst)
    TheFocalPoint:PushTempFocus(inst, 30, 30, 1)
end

local function OnCameraFocusDirty(inst)
    if inst._camerafocus:value() then
        if inst._camerafocustask == nil then
            inst._camerafocustask = inst:DoPeriodicTask(0, OnFocusCamera)
        end
    elseif inst._camerafocustask ~= nil then
        inst._camerafocustask:Cancel()
        inst._camerafocustask = nil
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBuild("quagmire_portal")
    inst.AnimState:SetBank("quagmire_portal")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(1)
    inst.AnimState:SetFinalOffset(2)

    inst.Transform:SetEightFaced()

	
	inst:AddTag("antlion_sinkhole")
    inst:AddTag("antlion_sinkhole_blocker")
    inst:AddTag("NOCLICK")
	
	
	
	
    --Dedicated server does not need the shadow object
    if not TheNet:IsDedicated() then
        CreateDropShadow(inst)
    end

    inst:AddTag("groundhole")
    inst:AddTag("blocker")



    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	inst:AddComponent("unevenground")
    inst.components.unevenground.radius = TUNING.ANTLION_SINKHOLE.UNEVENGROUND_RADIUS
	
	inst:AddComponent("des_unevenwater")
	inst.components.des_unevenwater.radius = TUNING.ANTLION_SINKHOLE.UNEVENGROUND_RADIUS
	
    inst:AddComponent("des_criver")

	
	inst:DoTaskInTime(0.3, function()
		SpawnPlants(inst)
	end)	

	
    return inst
end

local function activefx_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBuild("quagmire_portal_fx")
    inst.AnimState:SetBank("quagmire_portal_fx")
    inst.AnimState:PlayAnimation("portal_pre")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:OverrideMultColour(1, 1, 1, 1)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(1)
    inst.AnimState:SetFinalOffset(1)

    inst:AddTag("scarytoprey")
    inst:AddTag("birdblocker")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.AnimState:PushAnimation("portal_loop")

    inst.persists = false

    return inst
end

local function bubblefx_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBuild("quagmire_portalbubbles_fx")
    inst.AnimState:SetBank("quagmire_portalbubbles_fx")
    --inst.AnimState:PlayAnimation("idle")
    inst:Hide()

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end

return Prefab("des_river_circle", fn, assets, prefabs),
    Prefab("des_river_circle_activefx", activefx_fn, fx_assets),
    Prefab("des_river_circle_bubblefx", bubblefx_fn, fx_bubble_assets)
