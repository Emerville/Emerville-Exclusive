local function _OnUpdate(inst, self)
    self:OnUpdate()
end

local function AddMemberListeners(self, member)
    -- self.inst:ListenForEvent("onremove", self._onmemberkilled, member)
    -- self.inst:ListenForEvent("death", self._onmemberkilled, member)
end

local function RemoveMemberListeners(self, member)
   -- self.inst:RemoveEventCallback("onremove", self._onmemberkilled, member)
   -- self.inst:RemoveEventCallback("death", self._onmemberkilled, member)
end






local des_criver = Class(function(self, inst)
    self.inst = inst
    self.maxsize = 12
    self.members = {}
    self.membercount = 0
    self.membertag = nil

    self.onempty = nil
    self.onfull = nil
    self.addmember = nil

    self.updatepos = true
    self.updateposincombat = false

	self.has_river_built = nil
	self.last_turn = 0
	
	self.old_angle = 0
	self.use_new_angle = false
	
	
	self.start_pos = {x = 0, y = 0, z = 0}
	self.end_pos = {x = 0, y = 0, z = 0}
	
	--("self.start_pos {x = 0, y = 0, z = 0} = "..self.start_pos.x.."  "..self.start_pos.z)
	
    self.task = self.inst:DoPeriodicTask(math.random() * 2 + 6, _OnUpdate, nil, self)

    self._onmemberkilled = function(member) self:RemoveMember(member) end
end)

function des_criver:OnRemoveFromEntity()
    self.task:Cancel()
    for k, v in pairs(self.members) do
        RemoveMemberListeners(self, k)
    end
end

function des_criver:GetDebugString()
    local x, y, z = self.inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, self.gatherrange, { "herdmember", self.membertag })
    local str = string.format("members:%d membercount:%d max:%d membertag:%s gatherrange:%.2f nearby_tagged:%d", GetTableSize(self.members), self.membercount, self.maxsize, self.membertag, self.gatherrange, ents and #ents or 0)
    return str
end

function des_criver:SetMemberTag(tag)
    self.membertag = tag
end

function des_criver:SetOnEmptyFn(fn)
    self.onempty = fn
end

function des_criver:SetOnFullFn(fn)
    self.onfull = fn
end

function des_criver:SetAddMemberFn(fn)
    self.addmember = fn
end

function des_criver:IsFull()
    return self.membercount >= self.maxsize
end

function des_criver:AddMember(inst)
    if not self.members[inst] then
        self.membercount = self.membercount + 1
        self.members[inst] = true

        --This really should never happen but if it does it's not the end of the world...
        --assert(self.membercount <= self.maxsize, "We've got too many beefalo!")

        AddMemberListeners(self, inst)

        if self.addmember ~= nil then
            self.addmember(self.inst, inst)
        end

        if self.onfull ~= nil and self.membercount == self.maxsize then
            self.onfull(self.inst)
        end
    end
end

function des_criver:RemoveMember(inst)
    if self.members[inst] then
        RemoveMemberListeners(self, inst)


        self.membercount = self.membercount - 1
        self.members[inst] = nil

        if self.onempty ~= nil and next(self.members) == nil then
            self.onempty(self.inst)
        end
    end
end


local rock_select_a ={"farmrock", "farmrockflat","farmrocktall"}




function des_criver:make_circle(inst, aprefab, dst)
	local heading_angle = math.random(1,30)

        for i = 1, math.random(13, 15) do
			local prefab = aprefab
			
			if prefab == "farmrock" then
				prefab = rock_select_a[math.random(#rock_select_a)]
			end
			
			local plant = SpawnPrefab(prefab)
			
			
			

			heading_angle = heading_angle + 10 + 35*math.random()

			
			--plant.entity:SetParent(inst.entity)
			plant.persists = false
			local s_plant = 0.6 + 0.33*math.random()
			plant.Transform:SetScale(s_plant,s_plant,s_plant,s_plant)
			--("plant.Transform:SetScale(s_plant,s_plant,s_plant,s_plant)")

				-- * DEGREES + 45 * 2 * pi
			--("heading_angle = "..heading_angle)
			--("DEGREES =".. DEGREES)
			local dir = Vector3(math.cos(heading_angle*DEGREES),0, math.sin(heading_angle*DEGREES))
			local x,y,z = inst.Transform:GetWorldPosition()
			local dist = dst + 0.45*math.random()
			plant.Transform:SetPosition(x - dist*dir.x , 0, z - dist*dir.z)

		   
		   
			table.insert(inst.plant_ents, plant)
		end
end

function des_criver:make_water(inst)
	local water = SpawnPrefab("des_water_side_idle")
	local x,y,z = inst.Transform:GetWorldPosition()
	water.Transform:SetPosition(x - 0.5 , 0, z - 0.5)
	water.persists = false
	local water2 = SpawnPrefab("des_water_side_idle")
	local x,y,z = inst.Transform:GetWorldPosition()
	water2.Transform:SetPosition(x + 0.45 , 0, z + 0.8)
	water2.persists = false
	
	local water5 = SpawnPrefab("des_water_side_idle")
	local x,y,z = inst.Transform:GetWorldPosition()
	water5.Transform:SetPosition(x , 0, z)
	water5.persists = false
	water5.Transform:SetRotation(180)
	
	local water3 = SpawnPrefab("des_water_pond_flow")
	local x,y,z = inst.Transform:GetWorldPosition()
	water3.Transform:SetPosition(x , 0, z)
	water3.persists = false	
end

function des_criver:make_fish(inst)
	local water = SpawnPrefab("des_river_fishinghole")
	local x,y,z = inst.Transform:GetWorldPosition()
	water.Transform:SetPosition(x , 0, z)
	water.persists = false
end

-----------------------------------------------------------------
-----------------------------------------------------------------
-------------------------STREAM BUILDING-------------------------
-----------------------------------------------------------------
-----------------------------------------------------------------



local FLOCK_SIZE = 9
local MIN_SPAWN_DIST = 40
local LAND_CHECK_RADIUS = 6
local WATER_CHECK_RADIUS = 2

local LOCAL_CHEATS_ENABLED = false

local MAX_DIST_FROM_PLAYER = 12
local MAX_DIST_FROM_WATER = 6
local MIN_DIST_FROM_STRUCTURES = 20

local SEARCH_RADIUS = 50
local SEARCH_RADIUS2 = SEARCH_RADIUS*SEARCH_RADIUS

local DEFAULT_NUM_BOULDERS = 7

local DIST_RIVER_PARTS = 2
local DIST_RIVER_PARTS_RANDOM = 0.1


local function FindLandNextToWater( playerpos, waterpos )
    ----("FindWalkableOffset:")
    local ignore_walls = true 
    local radius = WATER_CHECK_RADIUS
    local ground = TheWorld

    local test = function(offset)
        local run_point = waterpos + offset

        -- TODO: Also test for suitability - trees or too many objects
        return ground.Map:IsAboveGroundAtPoint(run_point:Get()) and
            ground.Pathfinder:IsClear(
                playerpos.x, playerpos.y, playerpos.z,
                run_point.x, run_point.y, run_point.z,
                { ignorewalls = ignore_walls, ignorecreep = true })
    end

    -- FindValidPositionByFan(start_angle, radius, attempts, test_fn)
    -- returns offset, check_angle, deflected
    local loc,landAngle,deflected = FindValidPositionByFan(0, radius, 8, test)
    if loc then
        ----("Fan angle=",landAngle)
        return waterpos+loc,landAngle,deflected
    end
end


local function FindSpawnLocationForPlayer(player)
	--("======== FindSpawnLocationForPlayer(player) ========")
    local playerPos = Vector3(player.Transform:GetWorldPosition())

    local radius = LAND_CHECK_RADIUS
    local landPos
    local tmpAng
    local map = TheWorld.Map

    local test = function(offset)
        local run_point = playerPos + offset
        -- Above ground, this should be water
        if not map:IsAboveGroundAtPoint(run_point:Get()) then
            local loc, ang, def= FindLandNextToWater(playerPos, run_point)
            if loc ~= nil then
                landPos = loc
                tmpAng = ang
                ----("true angle",ang,ang/DEGREES)
                return true
            end
        end
        return false
    end

    local cang = (math.random() * 360) * DEGREES
    --("cang = (math.random() * 360) * DEGREES:")
    local loc, landAngle, deflected = FindValidPositionByFan(cang, radius, 7, test)
    if loc ~= nil then
		--(" loc, landAngle, deflected = FindValidPositionByFan(cang, radius, 7, test) loc ~= nil")
        return landPos, tmpAng, deflected
    end
end



local function EstablishColony(loc)
	--("======== EstablishColony(loc) ========")
    local radius = SEARCH_RADIUS
    local pos
    local ignore_walls = false
    local check_los = true
    local colonies = _colonies
    local ground = TheWorld

     local testfn = function(offset)
        local run_point = loc + offset
        if not ground.Map:IsAboveGroundAtPoint(run_point:Get()) then
			--("not above ground")
            return false
        end

        local NearWaterTest = function(offset)
            local test_point = run_point + offset
            return not ground.Map:IsAboveGroundAtPoint(test_point:Get())
        end

        --  FindValidPositionByFan(start_angle, radius, attempts, test_fn)
        if check_los and
            not ground.Pathfinder:IsClear(loc.x, loc.y, loc.z,
                                                         run_point.x, run_point.y, run_point.z,
                                                         {ignorewalls = ignore_walls, ignorecreep = true}) then 
			--("no path or los")
            return false
        end
        
        if FindValidPositionByFan(0, 6, 16, NearWaterTest) then
            --("colony too near water")
            return false
        end
		
        if #(TheSim:FindEntities(run_point.x, run_point.y, run_point.z, MIN_DIST_FROM_STRUCTURES, {"structure"})) > 0 then
            --("colony too close to structures")
			return false
        end
		
		return true
		
		--[[
		-- Now check that the rookeries are not too close together
        local found = true
        for i,v in ipairs(colonies) do
            local pos = v.rookery
            -- What about penninsula effects? May have a long march
            if pos and distsq(run_point,pos) < _spacing*_spacing then
				----("too close to another rookery")
                found = false
            end
        end
        return found
		--]]
    end

    -- Look for any nearby colonies with enough room
    -- return the colony if you find it
	--[[
    for i,v in ipairs(_colonies) do
        if GetTableSize(v.members) <= (_maxColonySize-(FLOCK_SIZE*.8)) then
            pos = v.rookery
            if pos and distsq(loc,pos) < SEARCH_RADIUS2+60 and
                ground.Pathfinder:IsClear(loc.x, loc.y, loc.z,                    -- check for interposing water
                                         pos.x, pos.y, pos.z,
                                         {ignorewalls = false, ignorecreep = true}) then 
                ----("************* Found existing colony")
                return i
            end
        end
    end--]]
    
    -- Make a new colony
    local newFlock = { members={} }

    -- Find good spot far enough away from the other colonies
    radius = SEARCH_RADIUS
    while not newFlock.rookery and radius>30 do
        newFlock.rookery = FindValidPositionByFan(math.random()*PI*2.0, radius, 32, testfn)
        radius = radius - 10
    end
    ----------rookery это гнездовье, то есть начало ручья
	
    if newFlock.rookery then
		--("==== I GUESS WE'VE FOUND END POS =======")
		SpawnPrefab("cutstone").Transform:SetPosition(newFlock.rookery:Get())
		local pos = newFlock.rookery:Get()
		return pos
	
       --[[ newFlock.rookery = newFlock.rookery + loc
        newFlock.ice = SpawnPrefab("penguin_ice")
        newFlock.ice.Transform:SetPosition(newFlock.rookery:Get())
        newFlock.ice.spawner = self

        local numboulders = math.random(math.floor(_numBoulders/2), _numBoulders)
        local sectorsize = 360 / numboulders
        local numattempts = 50
        while numboulders > 0 and numattempts > 0 do
            local foundvalidplacement = false
            local placement_attempts = 0
            while not foundvalidplacement do
                local minang = (sectorsize * (numboulders - 1)) >= 0 and (sectorsize * (numboulders - 1)) or 0
                local maxang = (sectorsize * numboulders) <= 360 and (sectorsize * numboulders) or 360
                local angle = math.random(minang, maxang)
                local pos = newFlock.ice:GetPosition()
                local offset = FindWalkableOffset(pos, angle*DEGREES, math.random(5,15), 120, false, false)
                if offset then 
                    local ents = TheSim:FindEntities(pos.x + offset.x, pos.y + offset.y, pos.z + offset.z, 1.2)
                    if #ents == 0 then
                        foundvalidplacement = true
                        numboulders = numboulders - 1
                        
                        -- local icerock = SpawnPrefab("rock_ice")
                        -- icerock.Transform:SetPosition(pos.x + offset.x, pos.y + offset.y, pos.z + offset.z)
                        -- icerock.remove_on_dryup = true
                    end
                end
                placement_attempts = placement_attempts + 1
                ----("placement_attempts:", placement_attempts)
                if placement_attempts > 10 then break end
            end
            numattempts = numattempts - 1
        end--]]
    else
        return false
    end


end


local function FindOceanWaterRoG(inst, dist, atm)
					local attemp = atm or 0
					local dst = dist or 4
					local radius = dst
					local theta = math.random()*2*PI
					local offset = Vector3(radius * math.cos( theta ), 0, -radius * math.sin( theta ) )
					local pt = Vector3(inst.Transform:GetWorldPosition()) + offset  
					
					
					if pt and TheWorld.Map:GetTileAtPoint(pt:Get()) == GROUND.IMPASSABLE then
						return pt
					elseif attemp<20 then
						FindOceanWaterRoG(inst, dst+0.75, attemp+1)
					else
						return
					end
					
end


local RIVER_STEP = 1.4
local RIVER_SCALE = 1
local CHANCE_TO_TURN = 0.40
local CHANCE_DOUBLE_TURN = 0.40
local MAX_TURN_ANGLE = 17

local RIVER_WATER_RANGE = 32
local RIVER_WATER_SEEK_ATTEMPS = 32

local RIVER_FALLS_RANGE = 4
local RIVER_FALLS_ATTEMPS = 32

local MAX_RIVER_PARTS = 70


local GRASS_CHANCE = 0.12
local REED_CHANCE = 0.05
local TEA_BUSH_CHANCE = 0.05
local WHEAT_CHANCE = 0.05

local GRASS_DIST = 1.5
local REED_DIST = 1.3
local TEA_BUSH_DIST = 1.7
local WHEAT_DIST = 1.9

local PLANTS_DIST = 1.2

local OFTEN_CHANCE = 0.13
local RARE_CHANCE = 0.08
local river_plants_often = {
	"grass",	
	"des_ivan_chai_tree",
	
	--mod
	---"seashell_beached",
	
	--woah some danger here
	"snake_hole",
}
local river_plants_rare = {
	"reeds",
	"des_chai_tree",
	
	--mod
	"tee_tree",
	"wheat",

}


local function create_water_over(target)
	local des_water_pond_flow = SpawnPrefab("des_water_pond_flow")
	local x,y,z = target.Transform:GetWorldPosition()
		
	des_water_pond_flow.Transform:SetPosition(x, 0, z)
end

function des_criver:CreateEnd(last_part_spawn)
	local des_river_sinkhole = SpawnPrefab("des_river_sinkhole")
	local x,y,z = last_part_spawn.Transform:GetWorldPosition()
		
	des_river_sinkhole.Transform:SetPosition(x, 0, z)
end

--des_river_sinkhole

function des_criver:SpawnTask(angle)
	
	--local pos = Vector3(self.inst.Transform:GetWorldPosition())
	--local loc, ang, def= FindLandNextToWater(pos, run_point)
	--local turn = ang/DEGREES
	--FindSpawnLocationForPlayer(player)
	--local loc,check_angle,deflected = FindSpawnLocationForPlayer(inst)
	
	--local loc,check_angle,deflected = FindSpawnLocationForPlayer(self.inst)
       --[[ if loc then 
            --("trying to spawn: Angle is",check_angle/DEGREES)
            local river_end_pos = EstablishColony(loc)
					ground.Map:IsAboveGroundAtPoint(test_point:Get())
            if not river_end_pos then
                --("can't establish colony")
                return
            end--]]

            --_lastSpawnTime = GetTime()
			--playerdata.lastSpawnLoc = loc

           -- SpawnFlock(colony,loc,check_angle)
		   
		local ground = TheWorld	
		local owner_pos = Vector3(self.inst.Transform:GetWorldPosition())
		--ground.Map:IsAboveGroundAtPoint(test_point:Get())
		
		local turn = angle --check_angle/DEGREES	
		
		
		local NearWaterTest = function(offset)
			--("=====NearWaterTest======")
            local test_point = owner_pos + offset
            return not ground.Map:IsAboveGroundAtPoint(test_point:Get())
        end
		
		--local water_point --FindValidPositionByFan(0, RIVER_WATER_RANGE, RIVER_WATER_SEEK_ATTEMPS, NearWaterTest)
		
		
		
		
		local water_point -- = FindValidPositionByFan(0, RIVER_WATER_RANGE/3, RIVER_WATER_SEEK_ATTEMPS, NearWaterTest) --(start_angle, radius, attempts, test_fn)
		local fan_angle
		
		self.inst:DoTaskInTime(1, function()
			for i=1, 4 do
				--("===== water_point i= "..i.."======")
				water_point, fan_angle  = FindValidPositionByFan(0, i*RIVER_WATER_RANGE/(4), RIVER_WATER_SEEK_ATTEMPS, NearWaterTest)
				if water_point then break end
			end	
		end)
		
		
		local last_part_spawn = nil
		
		self.inst:DoTaskInTime(2, function()
		
		if not water_point then
			fan_angle = (360*math.random())*DEGREES
			water_point = true
		end
		
		if water_point then
			--("water_point found!!!!!!!!!!!")
			for i=0, MAX_RIVER_PARTS do
				--("self:SpawnRiverPart(angle)")
				--("i = "..i)
				--("fan_angle = ")
				--(fan_angle, fan_angle/DEGREES)
				local true_angle = -(fan_angle/DEGREES)
				--("true_angle = ")
				--(true_angle)
				if self.use_new_angle == true then
					true_angle = self.old_angle
				end
				last_part_spawn = self:SpawnRiverPart(true_angle, i)
				self.inst.has_river = true
				
				
				
				--ok shit lets check if
				--this river part is in the OCEAN ALREADY
			
				local pt = Vector3(last_part_spawn.Transform:GetWorldPosition()) 
	
				if pt and TheWorld.Map:GetTileAtPoint(pt:Get()) == GROUND.IMPASSABLE then
					--("=== OCEAN ===")
					--("=== OCEAN ===")
					--("=== OCEAN ===")
					--("=== OCEAN ===")
					--("=== OCEAN ===")
					--("=== break ===")
					
					self:CreateEnd(last_part_spawn)
					
					break
				end
				
				


				
				
				--local water_falls = FindValidPositionByFan(0, RIVER_FALLS_RANGE, RIVER_FALLS_ATTEMPS, NearWaterTest) --(start_angle, radius, attempts, test_fn)
				--for i=1, 4 do
				--	--("===== water_point i= "..i.."======")
				--	water_falls  = FindValidPositionByFan(0, RIVER_FALLS_RANGE, RIVER_FALLS_ATTEMPS, NearWaterTest) --(start_angle, radius, attempts, test_fn)
				--	if water_falls then break end
				--end	

				-- if water_falls then
					-- local water_fall_end = SpawnPrefab("rock2")
					-- water_fall_end.Transform:SetPosition(self.last_river_part.Transform:GetWorldPosition())
					-- break
				-- end
			end		
				
			self:CreateEnd(last_part_spawn)
				
					
			return false
	
		end
		
		end)
end

local function SpawnPlantAtDist(inst, prefab, dst)

		local grass = SpawnPrefab(prefab)
		if not grass then return end
		
		
		local heading_angle = inst.Transform:GetRotation()

		local grass_heading_angle = heading_angle + 90-45 + 90*math.random()

		if math.random()<0.5 then
			grass_heading_angle = heading_angle - 90+45 - 90*math.random()
		end
		
		
		
		
		
		local dir_grass = Vector3(math.cos(grass_heading_angle*DEGREES),0, math.sin(grass_heading_angle*DEGREES))
		local x,y,z = inst.Transform:GetWorldPosition()	
		local dist = dst + 0.2*dst*math.random()
		
		grass.Transform:SetPosition(x - dist*dir_grass.x , 0, z - dist*dir_grass.z)
			
end



function des_criver:SpawnRiverPart(angle, i)
	local last_river_part = self.last_river_part
	
    local des_river = SpawnPrefab("des_river")
    if des_river and last_river_part then
	
		local turn_angle = 0 
		
		if math.random()<CHANCE_DOUBLE_TURN and self.last_turn ~= 0 then
			--("=== RIVER IS TURNING ===")
			turn_angle = (0.5+0.5*math.random())*(turn_angle)
			self.last_turn = turn_angle
		end
		
		if math.random()<CHANCE_TO_TURN then
			--("=== RIVER IS TURNING ===")
			turn_angle = math.random()*MAX_TURN_ANGLE
			
			if math.random() < 0.5 then turn_angle = turn_angle * (-1) end
			self.last_turn = turn_angle
		else
			self.last_turn = 0
		end
		
		angle = -(angle + turn_angle)
		--angle = 270
		--("angle =" ..angle)
		des_river.Transform:SetRotation(angle)
		
		self.old_angle = -angle
		self.use_new_angle = true
		
		local dir = Vector3(math.cos(angle*DEGREES),0, math.sin(angle*DEGREES))
		local x,y,z = last_river_part.Transform:GetWorldPosition()
		local dist = RIVER_STEP --- + 0.1*math.random()
		
		des_river.Transform:SetPosition(x - dist*dir.x , 0, z - dist*dir.z)
		
		
		if i > 2 and i < 60 then
			if math.random()<OFTEN_CHANCE then
				local plant_often = river_plants_often[math.random(#river_plants_often)]	
				SpawnPlantAtDist(des_river, plant_often, PLANTS_DIST)
			end
			if math.random()<RARE_CHANCE then
				local plant_rare = river_plants_rare[math.random(#river_plants_rare)]	
				SpawnPlantAtDist(des_river, plant_rare, PLANTS_DIST)
			end		
		
		
		
			--[[
			if math.random()<GRASS_CHANCE then
				----("Spawn Grass")
				SpawnPlantAtDist(des_river, "grass", GRASS_DIST)
			end
			if math.random()<REED_CHANCE then
				--("Spawn Grass")
				SpawnPlantAtDist(des_river, "reeds", REED_DIST)
			end
			
			if math.random()<TEA_BUSH_CHANCE then
				--("Spawn Grass")
				SpawnPlantAtDist(des_river, "tee_tree", TEA_BUSH_DIST)
			end
			if math.random()<WHEAT_CHANCE then
				--("Spawn Grass")
				SpawnPlantAtDist(des_river, "wheat", WHEAT_DIST)
			end	
			--]]
		end
		
		----("des_river heading_angle = " .. heading_angle)
		--des_river.Transform:SetRotation(angle)
		self.last_river_part = des_river
		--des_river
		--v:GetDistanceSqToPoint(x, y, z)
		des_river:DoTaskInTime(0.3, function()
			--des_river.Transform:SetRotation(angle) ---+180)
		end)
    end
	
	return des_river
end


local function SpawnFlock(colonyNum,loc,check_angle)
    local map = TheWorld.Map
    local flock = GetRandomWithVariance(_flockSize,3)
    local spawned = 0
    local i = 0
    local pang = check_angle/DEGREES
    while spawned < flock and i < flock + 7 do
        local spawnPos = loc + Vector3(GetRandomWithVariance(0,0.5),0.0,GetRandomWithVariance(0,0.5))
        i = i + 1
        if map:IsAboveGroundAtPoint(spawnPos:Get()) then
            spawned = spawned + 1
            ----(TheCamera:GetHeading()%360,"Spawn flock at:",spawnPos,(check_angle/DEGREES),"degrees"," c_off=",c_off)
            ----(TheCamera:GetHeading()," spawnPenguin at",pos,"angle:",angle)
           -- self.inst:DoTaskInTime(GetRandomWithVariance(1,1), SpawnPenguin, self, colonyNum, spawnPos,(check_angle/DEGREES))
        end
    end
end


local function TryToSpawnFlockForPlayer(inst)
    if _active then
        ----("---------:", TheWorld.state.season, TheWorld.state.remainingdaysinseason)
	    if not TheWorld.state.iswinter or TheWorld.state.remainingdaysinseason <= 3 then
            return
        end

        ----("Totalbirds=",_totalBirds,_maxPenguins)
        if #_colonies > _maxColonies then
            ----("Maxed out colonies")
            return
        end


        -- Go find a spot on land close to water
        -- returns offset, check_angle, deflected
        local loc,check_angle,deflected = FindSpawnLocationForPlayer(inst)
        if loc then 
            ----("trying to spawn: Angle is",check_angle/DEGREES)
            local colony = EstablishColony(loc)

            if not colony then
                ----("can't establish colony")
                return
            end


            SpawnFlock(colony,loc,check_angle)
        end
    end
end
-----------------------------------------------------------------
-----------------------------------------------------------------
-----------------------------------------------------------------
-----------------------------------------------------------------
-----------------------------------------------------------------



function des_criver:OnUpdate()
--[[
    self:GatherNearbyMembers()
    self:MergeNearbyHerds()
    if self.membercount > 0 then
        if self.updaterange ~= nil then
            local updatedPos = nil
            local validMembers = 0
            local toremove = {}
            for k, v in pairs(self.members) do
                if k.components.herdmember == nil
                    or (self.membertag ~= nil and not k:HasTag(self.membertag)) then
                    table.insert(toremove, k)
                elseif self.updatepos
                    and ((k.components.combat ~= nil and k.components.combat.target == nil) or self.updateposincombat)
                    and self.inst:IsNear(k, self.updaterange) then
                    updatedPos = updatedPos ~= nil and updatedPos + k:GetPosition() or k:GetPosition()
                    validMembers = validMembers + 1
                end
            end
            for i, v in ipairs(toremove) do
                self:RemoveMember(v)
            end
            if updatedPos ~= nil then
                self.inst.Transform:SetPosition(updatedPos.x / validMembers, 0, updatedPos.z / validMembers)
            end
        end
        if self.membercount > 0 then
            local herdPos = self.inst:GetPosition()
            for k, v in pairs(self.members) do
                if k.components.knownlocations ~= nil then
                    k.components.knownlocations:RememberLocation("herd", herdPos)
                end
            end
        end
    end--]]
end

function des_criver:OnSave()
    local data = {}

	
    for k, v in pairs(self.members) do
        if data.members == nil then
            data.members = { k.GUID }
        else
            table.insert(data.members, k.GUID)
        end
    end
	
	if self.has_river_built then
		data.has_river_built = true
	end
    return data, data.members
end

function des_criver:LoadPostPass(newents, savedata)
	if savedata.has_river_built then
		self.has_river_built = true
	end
    if savedata.members ~= nil then
        for k, v in pairs(savedata.members) do
            local member = newents[v]
            if member ~= nil then
                self:AddMember(member.entity)
            end
        end
    end
end

return des_criver
