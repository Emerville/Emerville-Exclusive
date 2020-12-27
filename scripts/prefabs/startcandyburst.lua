require "regrowthutil"

local assets =
{
    Asset("ANIM", "anim/dragonfly_ring_fx.zip"),
    Asset("ANIM", "anim/warning_shadow.zip"),
    Asset("ANIM", "anim/meteor_shadow.zip"),
}

local prefabs =
{
    "burntground",
    "splash_ocean",
    "rock_moon",
}

local SMASHABLE_WORK_ACTIONS =
{
    CHOP = false,
    DIG = false,
    HAMMER = false,
    MINE = false,
	ATTACK = true,
}
local SMASHABLE_TAGS = { "_combat", "_inventoryitem", "campfire" }
for k, v in pairs(SMASHABLE_WORK_ACTIONS) do
    table.insert(SMASHABLE_TAGS, k.."_workable")
end
local NON_SMASHABLE_TAGS = { "INLIMBO", "playerghost" }

local DENSITY = 0.1 -- the approximate density of rock prefabs in the rocky biomes
local FIVERADIUS = CalculateFiveRadius(DENSITY)
local EXCLUDE_RADIUS = 3

local function onexplode(inst)





	   local pt = inst:GetPosition()
            local numtentacles = 5
			
         inst:StartThread(function()
                for k = 1, numtentacles do
                
                    local theta = math.random() * 2 * PI
                    local radius = math.random(3, 5)

                   
                    local result_offset = FindValidPositionByFan(theta, radius, 10, function(offset)
                        local spot = pt + offset
                        local ents = TheSim:FindEntities(spot.x, spot.y, spot.z, 1)
                        return next(ents) == nil
                    end)

                    if result_offset ~= nil then
                        local spot = pt + result_offset
                        local tentacle = SpawnPrefab("candyburst")

                        tentacle.Transform:SetPosition(spot:Get())


                        --need a better effect
                    end

                    Sleep(.075)
                end
            end)

            return true
end  


		




local function dostrike(inst)
    inst.striketask = nil
    inst.AnimState:PlayAnimation("idle")
    inst:DoTaskInTime(0.1, onexplode)

    -- animover isn't triggered when the entity is asleep, so just in case
 inst:DoTaskInTime(3, inst.Remove)
end

local warntime = 0.1
local sizes = 
{ 
    small = 1,
    medium = 1,
    large = 1,
}
local work =
{
    small = 20,
    medium = 20,
    large = 20,
}

local function SetPeripheral(inst, peripheral)
    inst.peripheral = peripheral
end

local function SetSize(inst, sz, mod)
    if inst.autosizetask ~= nil then
        inst.autosizetask:Cancel()
        inst.autosizetask = nil
    end
    if inst.striketask ~= nil then
        return
    end

    if sizes[sz] == nil then
        sz = "small"
    end

    inst.size = sizes[sz]
    inst.workdone = work[sz]


    if mod == nil then
        mod = 1
    end

    if sz == "medium" then

    elseif sz == "large" then
        local rand = math.random()
        if rand <= TUNING.METEOR_CHANCE_BOULDERMOON * mod then

        elseif rand <= TUNING.METEOR_CHANCE_BOULDERFLINTLESS * mod then
            rand = math.random() -- Randomize which flintless rock we use

        else -- Don't check for chance or mod this one: we need to pick a boulder

        end
    else -- "small" or other undefined

    end


    -- Now that we've been set to the appropriate size, go for the gusto
    inst.striketask = inst:DoTaskInTime(warntime, dostrike)

    
end

local function AutoSize(inst)
    inst.autosizetask = nil
    local rand = math.random()
    inst:SetSize(rand <= .33 and "large" or (rand <= .67 and "medium" or "small"))
end

local function fn() 
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    
    inst.Transform:SetTwoFaced()

    inst.AnimState:SetBank("dragonfly_ring_fx")
    inst.AnimState:SetBuild("dragonfly_ring_fx")
	 inst.AnimState:SetFinalOffset(-1)
	     inst.Transform:SetScale(0.6, 0.6, 0.6)
		 	inst.AnimState:SetMultColour(0,0,0,0)
		 

    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)

    inst:AddTag("NOCLICK")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	    inst.OFFSPELLCASTER = nil
    inst.Transform:SetRotation(math.random(360))
    inst.SetSize = SetSize
    inst.SetPeripheral = SetPeripheral
    inst.striketask = nil

    -- For spawning these things in ways other than from meteor showers (failsafe set a size after delay)
    inst.autosizetask = inst:DoTaskInTime(0, AutoSize)
   
    inst.persists = false

    return inst
end

return Prefab("startcandyburst", fn, assets, prefabs)
