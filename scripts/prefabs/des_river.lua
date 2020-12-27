local assets =
{
	Asset("ANIM", "anim/des_river.zip"),
}
local water_side_assets =
{
	Asset("ANIM", "anim/des_water_side_idle.zip"),
}
local pond_flow_assets =
{
	Asset("ANIM", "anim/des_water_pond_flow.zip"),
}


local function destroyblood(inst, times)
	local time_to_erode = times or 1
	local tick_time = TheSim:GetTickTime()


	inst:StartThread( function()
		local ticks = 0
		while ticks * tick_time < time_to_erode do
			local erode_amount = ticks * tick_time / time_to_erode
			inst.AnimState:SetErosionParams( erode_amount, 0.1, 1.0 )
			ticks = ticks + 1
			Yield()
		end
		inst:Remove()
	end)
end

local function flow(inst)
    inst.AnimState:PushAnimation("flow", true)
end

			-- local heading_angle = -(inst.Transform:GetRotation())
			-- local dir = Vector3(math.cos(heading_angle*DEGREES),0, math.sin(heading_angle*DEGREES))
local function SpawnPlants(inst)
    inst.task = nil

    if inst.plant_ents ~= nil then
        return
    end
	
	local pi = 3.1415926535897932384626433
	local real_heading_angle = (inst.heading_angle)
	
	inst.plant_ents = {}
    if inst.plants == nil then
        inst.plants = {}
        for i = 1, math.random(1, 2) do
           -- local theta = math.random() * 2 * PI
			local heading_angle = real_heading_angle + 90-45 + 90*math.random()
			if math.random()<0.5 then
				heading_angle = real_heading_angle - 90+45 - 90*math.random()
			end
			local plant = SpawnPrefab(inst.planttype)
			--plant.entity:SetParent(inst.entity)
			plant.persists = false
			local s_plant = 0.4 + 0.2*math.random()
			plant.Transform:SetScale(s_plant,s_plant,s_plant,s_plant)

				-- * DEGREES + 45 * 2 * pi
			local dir = Vector3(math.cos(heading_angle*DEGREES),0, math.sin(heading_angle*DEGREES))
			local x,y,z = inst.Transform:GetWorldPosition()
			local dist = 1.05 + 0.1*math.random()
			plant.Transform:SetPosition(x - dist*dir.x , 0, z - dist*dir.z)

		   
		   
			table.insert(inst.plant_ents, plant)
		end
	end

			
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

local function DespawnPlants(inst)
    if inst.plant_ents ~= nil then
        for i, v in ipairs(inst.plant_ents) do
            if v:IsValid() then
                v:Remove()
            end
        end

        inst.plant_ents = nil
    end

    inst.plants = nil
end


local function owner_onload(inst, data)
    if data ~= nil and data.has_river then
		inst.has_river = data.has_river
	else
		inst.has_river = nil
    end
end

local function owner_onsave(inst, data)
	if inst.has_river then
		data.has_river = inst.has_river
	end
end

local function ownerfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    --[[Non-networked entity]]

    inst:AddTag("herd")
    --V2C: Don't use CLASSIFIED because herds use FindEntities on "herd" tag
    inst:AddTag("NOBLOCK")
    --inst:AddTag("NOCLICK")



   -- inst:DoTaskInTime(0, OnInit)

    -- inst:AddComponent("periodicspawner")
    -- inst.components.periodicspawner:SetRandomTimes(TUNING.BEEFALO_MATING_SEASON_BABYDELAY, TUNING.BEEFALO_MATING_SEASON_BABYDELAY_VARIANCE)
    -- inst.components.periodicspawner:SetPrefab("babybeefalo")
    -- inst.components.periodicspawner:SetOnSpawnFn(OnSpawned)
    -- inst.components.periodicspawner:SetSpawnTestFn(CanSpawn)
    -- inst.components.periodicspawner:SetDensityInRange(20, 6)
    -- inst.components.periodicspawner:SetOnlySpawnOffscreen(true)

	inst.OnLoad = owner_onload
	inst.OnSave = owner_onsave
	
	
	local rotate = math.random()*360
	--inst.heading_angle = rotate
	inst.Transform:SetRotation(rotate)
	--local heading_angle = -(inst.Transform:GetRotation())
	
	inst:AddComponent("des_criver")
	inst.components.des_criver.last_river_part = inst
	
	inst:DoTaskInTime(5+math.random()*10, function()
		if not inst.has_river then
			print("===---- SPAWNING RIVER ---===")
			print("===---- Expect laggs for a short time ---===")
			SpawnPrefab("des_river_circle").Transform:SetPosition(inst.Transform:GetWorldPosition())
			inst.components.des_criver:SpawnTask(rotate)
		end
	end)		
	
    return inst

end


local function onload(inst, data)
    if data ~= nil and data.turn ~= nil then
		inst.Transform:SetRotation(data.turn)
		inst:DoTaskInTime(0.1, function()
			inst.Transform:SetRotation(data.turn)
		end)	
    end
end

local function onsave(inst, data)
    data.turn = (inst.Transform:GetRotation())
end


local function defaultfn(type)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

	
	
	if type == "water_side" then
		anim:SetBank("des_water_side_idle")
		anim:SetBuild("des_water_side_idle")
	elseif type == "pond_flow" or type == "pond_bubble" then
		anim:SetBank("des_water_pond_flow")
		anim:SetBuild("des_water_pond_flow")
	elseif type ~= "water_side" then
		anim:SetBank("des_river")
		anim:SetBuild("des_river")
	end
	
	
	if type == "idle" then
		inst:AddTag("des_river_water_sourse")

		anim:PlayAnimation("river_part_water")
	elseif type == "marsh" then
		anim:PlayAnimation("river_part")
		
	elseif type == "water_side" then
		anim:PlayAnimation("des_water_side_idle")
		
	elseif type == "pond_flow" then
		anim:PlayAnimation("idle") 
	elseif type == "pond_bubble" then
		anim:PlayAnimation("bubble") 

	elseif type ~= "marsh" then
		anim:PlayAnimation(type)--tostring(math.ceil(math.random()*2)))
	end
	
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    --inst.AnimState:SetSortOrder(2)
	


	if type ~= "idle" then
		--inst:AddTag("NOCLICK")
		inst:AddTag("fx")
    end
    
	
	
	local r = 57/255
	local g = 75/255
	local b = 100/255
	
	local c = math.random(0.3,0.6)
	local a = math.random(0.2,0.5)
	local s1 = 1.5
	local s = s1*0.9 + s1*0.05*math.random()
	
	--local r = math.random(0.3,0.5)+math.random(0.3,0.5)
	--local g = math.random(0.3,0.5)+math.random(0.3,0.5)
	--local b = math.random(0.3,0.5)+math.random(0.3,0.5)
	
	inst.Transform:SetScale(s,s,s,s)

	if type == "marsh" then
		inst.AnimState:SetSortOrder(2)
		inst.Transform:SetScale(s,s,s,s)
	elseif type == "idle" then
		inst.AnimState:SetSortOrder(3)
		local s5 = 1.1
		local s4 = 0.9*s5 + s5*0.2*math.random()
		inst.Transform:SetScale(s4,s4,s4,s4)
		--inst.AnimState:SetMultColour(r,g,b,1)
	elseif type == "flow" then
		inst.AnimState:SetSortOrder(3)
		anim:PlayAnimation("flow",true)
		
	elseif type == "pond_bubble" then
		inst.AnimState:SetSortOrder(3)
		anim:PlayAnimation("bubble",true)
		
	elseif type == "pond_flow" then
		inst.AnimState:SetSortOrder(3)
		anim:PlayAnimation("idle",true)
	end
	
	
	
	
	
	
	------------------------------------------------
	if type == "water_side" then
		anim:SetBank("des_water_side_idle")
		anim:SetBuild("des_water_side_idle")
		anim:PlayAnimation("des_water_side_idle",true)
		inst.AnimState:SetSortOrder(2)
	end
	------------------------------------------------
	
	inst.entity:SetPristine()
	
	if not TheWorld.ismastersim then
       return inst
    end
	
	
	
	
	if type == "marsh" then
	elseif type == "idle" then
	    inst:AddComponent("inspectable")
		inst.components.inspectable.nameoverride = "pond"
		
		
		inst:AddComponent("des_unevenwater")
		inst.components.des_unevenwater.radius = 1
		
	elseif type == "flow" then
		local a_flow = 1 --- 0.5
		inst.AnimState:SetMultColour(1,1,1,1)
		flow(inst)
		inst.AnimState:SetTime(math.random()*2)
	elseif type == "pond_flow" then
		local a_flow = 1 --- 0.5
		inst.AnimState:SetMultColour(1,1,1,1)
		anim:PlayAnimation("idle",true)
		inst.AnimState:SetTime(math.random()*2)
		
	elseif type == "pond_bubble" then
		inst.AnimState:SetSortOrder(3)
		anim:PlayAnimation("bubble",true)
		inst.AnimState:SetMultColour(1,1,1,1)
		inst.AnimState:SetTime(math.random()*2)
	end

	
	
	------------------------------------------------
	if type == "water_side" then
		-- anim:SetBank("des_water_side_idle")
		-- anim:SetBuild("des_water_side_idle")
		inst.AnimState:SetMultColour(r,g,b,1)
		anim:PlayAnimation("des_water_side_idle",true)
		inst.AnimState:SetSortOrder(2)
	end
	------------------------------------------------
	
	
	inst.planttype = "marsh_plant"
	
	inst:DoTaskInTime(0.2, function()
		if type == "idle" then
			local marsh = SpawnPrefab("des_marsh")
			local s_marsh = s*0.9
			marsh.Transform:SetPosition(inst.Transform:GetWorldPosition())
			marsh.Transform:SetScale(s_marsh,s_marsh,s_marsh,s_marsh)
			
			
			-- local marsh2 = SpawnPrefab("des_marsh")
			-- local s_marsh2 = s*0.9
			-- marsh2.Transform:SetPosition(inst.Transform:GetWorldPosition())
			-- marsh2.Transform:SetScale(s_marsh2,s_marsh2,s_marsh2,s_marsh2)
			
			
			local s_flow = s*0.85
			local flow = SpawnPrefab("des_flow")
			flow.Transform:SetPosition(inst.Transform:GetWorldPosition())
			flow.Transform:SetScale(s_flow,s_flow,s_flow,s_flow)
			
			local pi = 3.1415926535897932384626433
			
			inst.heading_angle = -(inst.Transform:GetRotation())


			local heading_angle = -(inst.Transform:GetRotation())
			local dir = Vector3(math.cos(heading_angle*DEGREES),0, math.sin(heading_angle*DEGREES))
			
			marsh.Transform:SetRotation(heading_angle)
			flow.Transform:SetRotation(heading_angle)
			--inst.Transform:SetRotation(heading_angle)
			inst.task = inst:DoTaskInTime(0, SpawnPlants)
			
			marsh.persists=false
			flow.persists=false
		end
	end)	 
	
	if type == "idle" then
		inst.OnLoad = onload
		inst.OnSave = onsave
	end
	

	--inst:DoTaskInTime(math.random(TUNING.BLOOD_FX ,TUNING.BLOOD_FX*3+0.1), function() destroyblood(inst, 2) end)

    return inst
end



return Prefab("common/fx/des_river", function() return defaultfn("idle") end, assets),
Prefab("common/fx/des_marsh", function() return defaultfn("marsh") end, assets),
Prefab("common/fx/des_flow", function() return defaultfn("flow") end, assets),
Prefab("common/fx/des_river_owner", function() return ownerfn() end, assets),
Prefab("common/fx/des_water_pond_flow", function() return defaultfn("pond_flow") end, pond_flow_assets),
Prefab("common/fx/des_water_side_idle", function() return defaultfn("water_side") end, water_side_assets),
Prefab("common/fx/des_water_side_bubble", function() return defaultfn("pond_bubble") end, pond_flow_assets)

 --Prefab("common/fx/blood_collectable", cancollect, assets)