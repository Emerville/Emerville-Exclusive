local assets =
{
    Asset("ANIM", "anim/ds_rabbit_basic.zip"),
    Asset("ANIM", "anim/attyla_build.zip"),
	
	Asset("SOUNDPACKAGE", "sound/attylasounds.fev"),
	Asset("SOUND", "sound/attylasounds.fsb"),
	
	Asset("SOUND", "sound/rabbit.fsb"),
	
	Asset("ATLAS", "images/inventoryimages/attyla.xml"),
	Asset("IMAGE", "images/inventoryimages/attyla.tex"),
}

local prefabs =
{
    "smallmeat",
    "cookedsmallmeat",
	"attyla_guano",
	"attylaskull",
}

local attylasounds =
{
    scream = "attylasounds/attylasounds/run",
    hurt = "attylasounds/attylasounds/hit",
}

local WAKE_TO_FOLLOW_DISTANCE = 3
local SLEEP_NEAR_LEADER_DISTANCE = 2

local brain = require("brains/attylabrain")

local function ShouldWakeUp(inst)
    return DefaultWakeTest(inst) or not inst.components.follower:IsNearLeader(WAKE_TO_FOLLOW_DISTANCE)
end

local function ShouldSleep(inst)
    return DefaultSleepTest(inst) and not inst.sg:HasStateTag("eat") and inst.components.follower:IsNearLeader(SLEEP_NEAR_LEADER_DISTANCE) and not TheWorld:HasTag("cave") and TheWorld.state.isnight and not TheWorld.state.isfullmoon
end

local function OnEat(inst)
	local guano = SpawnPrefab("attyla_guano")
	local owner = inst.components.inventoryitem.owner
    if inst.components.inventoryitem and owner and not owner.components.inventory then -- basically checks if owner has Attila in a container
		guano.Transform:SetPosition(owner.Transform:GetWorldPosition())
		guano.Transform:SetScale(0.5, 0.5, 0.5)
	elseif inst.components.inventoryitem and owner and owner.components.inventory then -- does owner have Attila in his inventory?
		owner.components.inventory:GiveItem(guano)
	else
		inst.sg:GoToState("eat") -- Pooping is coded in Attila's stategraph
	end
end

local function OnLocomote(inst)
	local owner = inst.components.follower.leader
	if not inst.components.follower and not owner then
		inst.components.locomotor.runspeed = TUNING.ATTYLA_RUN_SPEED
	
	elseif inst.components.follower and owner then
		if owner.components.locomotor.runspeed ~= inst.components.locomotor.runspeed then
		inst.components.locomotor.runspeed = owner.components.locomotor.runspeed
		end
	end
end

local function MakeInventoryAttyla(inst)
    inst.components.health.murdersound = inst.sounds.hurt
end

local function BecomeAttyla(inst)
    if inst.components.health:IsDead() then
        return
    end
    inst.AnimState:SetBuild("attyla_build")
    inst.sounds = attylasounds
    if inst.components.hauntable ~= nil then
        inst.components.hauntable.haunted = false
    end
end

--local function OnCookedFn(inst, cooker, chef)
--    inst.SoundEmitter:PlaySound( inst.sounds.hurt)
--end


local function OnAttacked(inst, data)

	local attacker = data.attacker
	if attacker.prefab == "malami" then
		attacker.components.sanity:DoDelta(-5)
	end
	
	if inst.components.follower.leader == nil then
		inst.components.follower.leader = inst._playerlink -- Attila will always love you, even if you are beating him...
	end
	
end

local function IsValidLink(inst, player)
    return player:HasTag("malami") and player.attyla == nil and not inst.components.follower.leader
end

local function unlink(inst)
    if inst._playerlink ~= nil and inst._playerlink.attyla then
	inst._playerlink.attyla = nil
	end
	
	if inst.isonground == false and inst.attylaowner ~= nil and inst._playerlink ~= nil and inst.droplootonce == 1 and not inst.isdyingbecauseisaidso == true then -- leaving the server
	local owner = inst.attylaowner
	local attylalootspawner = SpawnPrefab("attylalootspawner")
	attylalootspawner.Transform:SetPosition(owner.Transform:GetWorldPosition())
	inst.droplootonce = 0
	end
	
	--if inst.isonground == false and inst.attylaowner == nil and inst._playerlink ~= nil and inst.droplootonce == 1 and not inst.isdyingbecauseisaidso == true then -- if migrating with attyla in inv - prevents not dropping when killed and not relinked via inventoryitem
	--local attylalootspawner = SpawnPrefab("attylalootspawner")
	--attylalootspawner.Transform:SetPosition(inst.Transform:GetWorldPosition())
	--inst.droplootonce = 0
	--end
	
	if inst._playerlink == nil then 
		local fx = SpawnPrefab("small_puff")
        fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
        fx.Transform:SetScale(0.6, 0.6, 0.6)
		
		--if inst then
		--	inst:Remove()
		--end
	end
	
	--if inst.isonground == false then	
	--	local skull = SpawnPrefab("attylaskull")
	--	local meat = SpawnPrefab("smallmeat")
	--	inst.components.inventoryitem.owner.components.inventory:GiveItem(skull)
	--	inst.components.inventoryitem.owner.components.inventory:GiveItem(meat)
	--end
	
    --local inv = inst._playerlink.components.inventory
    --refreshcontainer(inv)

    --local activeitem = inv:GetActiveItem()
    --if activeitem ~= nil and activeitem.prefab == "attylaskull" then
    --    activeitem:Refresh()
    --end

    --for k, v in pairs(inv.opencontainers) do
    --    refreshcontainer(k.components.container)
    --end
end

local function linktoplayer(inst, player)
	if player ~= nil and IsValidLink(inst, player) then
        inst._playerlink = player
        player.attylas[inst] = true

    inst.persists = false
    inst._playerlink = player
    player.attyla = inst
    player.components.leader:AddFollower(inst, true)
	end
    --for k, v in pairs(player.attylas) do
    --   k:Refresh()
    --end
	player:ListenForEvent("onremove", unlink, inst)
end

local function topocket(inst, owner)
	if owner:HasTag("malami") and owner.attyla == nil and not inst.components.follower.leader then
		inst._playerlink = owner
	end
	
    linktoplayer(inst, owner)
	inst.isonground = false
	inst.attylaowner = inst.components.inventoryitem.owner	
end

local function OnDropped(inst, owner)
    inst.sg:GoToState("stunned")
	--linktoplayer(inst, player)
	inst.isonground = true
end

local function onpreload (inst, data)
	if data ~= nil and data.isonground ~= nil then
        inst.isonground = data.isonground
	end
end

local function onsave(inst, data)
    data.isonground = inst.isonground
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()
    inst.entity:AddLightWatcher()

    MakeCharacterPhysics(inst, 1, 0.5)

    inst.DynamicShadow:SetSize(1, .75)
    inst.Transform:SetFourFaced()

    inst.AnimState:SetBank("rabbit")
    inst.AnimState:SetBuild("attyla_build")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("animal")
    inst:AddTag("prey")
    inst:AddTag("attyla")
    inst:AddTag("smallcreature")
	inst:AddTag("notraptrigger")
	--inst:AddTag("irreplaceable") -- to make sure nothing will steal him forever
	
	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon("attyla.tex")
	
    --inst:AddTag("cookable")

    MakeFeedableSmallLivestockPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor.runspeed = TUNING.ATTYLA_RUN_SPEED
    inst:SetStateGraph("SGattyla")

	inst._playerlink = nil
	inst.isonground = nil
	inst.attylaowner = nil
	inst.droplootonce = 1
	inst.isdyingbecauseisaidso = nil
	
    inst:SetBrain(brain)
	
    inst:AddComponent("eater")
    inst.components.eater:SetDiet({ FOODGROUP.OMNI }, { FOODGROUP.OMNI }) -- can eat anything!
    inst.components.eater:SetCanEatHorrible()
    inst.components.eater:SetCanEatRaw()
    inst.components.eater.strongstomach = true -- can eat monster meat!
	
    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/inventoryimages/attyla.xml"
	inst.components.inventoryitem.imagename = "attyla"
    inst.components.inventoryitem.nobounce = true
    inst.components.inventoryitem.canbepickedup = false
    --inst.components.inventoryitem.canbepickedupalive = false

	inst:AddComponent("follower")
    inst.components.follower.keepdeadleader = true
	
    --inst:AddComponent("cookable")
    --inst.components.cookable:SetOnCookedFn(OnCookedFn)
	
	inst:AddComponent("sanityaura")
	inst.components.sanityaura.aura = TUNING.SANITYAURA_TINY
	
    inst:AddComponent("knownlocations")
    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "chest"

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.ATTYLA_HEALTH)
	inst.components.health:StartRegen(1, 1)
	inst.components.health.canmurder = false

    MakeSmallBurnableCharacter(inst, "chest")
    MakeTinyFreezableCharacter(inst, "chest")

    inst:AddComponent("inspectable")
    inst:AddComponent("sleeper")
    inst.components.sleeper:SetResistance(3)
    inst.components.sleeper.testperiod = GetRandomWithVariance(6, 2)
    inst.components.sleeper:SetSleepTest(ShouldSleep)
    inst.components.sleeper:SetWakeTest(ShouldWakeUp)
	
    inst:AddComponent("tradable")
	
	inst.LinkToPlayer = linktoplayer
	
    inst.sounds = nil
    inst.task = nil
    BecomeAttyla(inst)

    MakeHauntablePanic(inst)
	
    inst:ListenForEvent("attacked", OnAttacked)
	inst:ListenForEvent("oneat", OnEat)
	inst:ListenForEvent("locomote", OnLocomote)
	
    MakeFeedableSmallLivestock(inst, TUNING.RABBIT_PERISH_TIME, topocket, OnDropped)

	inst.OnSave = onsave
	inst.OnPreLoad = onpreload
	inst.OnRemoveEntity = unlink
	
    return inst
end

return Prefab("attyla", fn, assets, prefabs)