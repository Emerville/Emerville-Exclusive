require "regrowthutil"

local assets =
{
    Asset("ANIM", "anim/dragonfly_ring_fx.zip"),
    Asset("ANIM", "anim/warning_shadow.zip"),
    Asset("ANIM", "anim/meteor_shadow.zip"),
}

local prefabs =
{
    "meteorwarning",
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



	    local x, y, z = inst.Transform:GetWorldPosition()
 local prefab = "statue_transition_2"
       local fx = SpawnPrefab(prefab)
	fx.Transform:SetPosition(x, y, z)
	fx.Transform:SetScale(1.75, 1.75, 1.75)


    local x, y, z = inst.Transform:GetWorldPosition()

    if not inst:IsOnValidGround() then

       
    else
 local ents = TheSim:FindEntities(x, y, z, inst.size * 6, nil, NON_SMASHABLE_TAGS, SMASHABLE_TAGS)
        for i, v in ipairs(ents) do
            --V2C: things "could" go invalid if something earlier in the list
            --     removes something later in the list.
            --     another problem is containers, occupiables, traps, etc.
            --     inconsistent behaviour with what happens to their contents
            --     also, make sure stuff in backpacks won't just get removed
            --     also, don't dig up spawners
            if v:IsValid() and not v:IsInLimbo() then
               
        if v.components.combat ~= nil then
				 if v:HasTag("chess") then
				 elseif v:HasTag("flying") then
				 else
                    v.components.combat:GetAttacked(inst, 20, nil)
					v.components.combat:SuggestTarget(inst.OFFSPELLCASTER)


  end
end
end
end
end
end  


		




local function dostrike(inst)
    inst.striketask = nil
    inst.AnimState:PlayAnimation("idle")
    inst:DoTaskInTime(0.1, onexplode)
    inst:ListenForEvent("animover", inst.Remove)
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
		 	inst.AnimState:SetMultColour(0,0,0,1)
		 

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

return Prefab("shadowburst", fn, assets, prefabs)
