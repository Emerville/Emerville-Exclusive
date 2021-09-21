local assets =
{
    Asset("ANIM", "anim/beargerkit.zip"),	
	
    Asset("ATLAS", "images/inventoryimages/beargerkit.xml"),
    Asset("IMAGE", "images/inventoryimages/beargerkit.tex"),	
}

-- The time between each STRINGS.DST_MOD_REINCARNATION.ON_USE_SAY
-- line in seconds
local TIME_BETWEEN_LINES = 3


-- Let a player say a line
local function say(player, line)
    if player ~= nil and player.components.talker ~= nil then
        player.components.talker:Say(line)
    end
end

-- Despawn and return a player to the character select screen
-- (should be scheduled)
local function dodespawn(player)
--~     -- Kill the player
--~     player:PushEvent("death", { cause = "beargerkit" })
--~     -- Add a morgue record if the player's death handler won't add one
--~     if player.ghostenabled then
--~         player.player_classified:AddMorgueRecord()
--~     end

    player.deathcause = "beargerkit"
    player.deathclientobj = TheNet:GetClientTableForUser(player.userid)
    player.player_classified:AddMorgueRecord()

    -- Leave a skeleton, as we will despawn the player immediately
    local x, y, z = player.Transform:GetWorldPosition()

    -- Spawn a skeleton
    local skel = SpawnPrefab("skeleton_player")
    if skel ~= nil then
        skel.Transform:SetPosition(x, y, z)
        -- Set the description
        skel:SetSkeletonDescription(player.prefab, player:GetDisplayName(),
                                    player.deathcause, nil)
        skel:SetSkeletonAvatarData(player.deathclientobj)
    end

    -- Delete must happen when the player is actually removed
    -- This is currently handled in playerspawner listening to
    -- ms_playerdespawnanddelete	
    player:PushEvent("ms_playerreroll")	
	
    -- Drop everything from inventory if we're not storing it;
    -- always drop irreplaceable items.
    -- TODO: Always drop non-persistent items as they will be lost otherwise? 
    if player.components.inventory ~= nil then
        player.components.inventory:DropEverythingWithTag("irreplaceable")
        player.components.inventory:DropEverything()
    end

	if player.components.leader ~= nil then
		local followers = player.components.leader.followers
		for k, v in pairs(followers) do
			if k.components.inventory ~= nil then
				k.components.inventory:DropEverything()
			elseif k.components.container ~= nil then
				k.components.container:DropEverything()
			end
		end
	end	
	
    TheWorld:PushEvent("ms_playerdespawnanddelete", player)
end

-- Kill a player (should be scheduled)
local function dokill(player)
    -- Announce the reincarnation
    TheNet:Announce(string.format(
                        STRINGS.DST_MOD_REINCARNATION.ON_DESPAWN_ANNOUNCE,
                        player:GetDisplayName()),
                    nil, nil, "death")

    --Personal Chester Mod Compatibility: If there is a personal chester, kill it to drop its inventory
    if player.chester ~= nil and player.chester.components.health ~= nil then
        player.chester.components.health:Kill()
    end

    -- Play a fancy animation
    player.sg:GoToState("teleportato_teleport")
end

-- Initiate despawning a player
local function despawn(player)
    if player ~= nil and player:IsValid() then
        local time_to_kill = 0
		
            -- Prevent premature death
            if player.components.health ~= nil then
                player.components.health:SetInvincible(true)
            end
            -- Go crazy
            if player.components.sanity ~= nil then
                player.components.sanity:SetPercent(0)
            end
            -- Slow down
            if player.components.locomotor ~= nil then
                player.components.locomotor:SetExternalSpeedMultiplier(
                    player, "reincarnationshot", 0.25)
            end
            -- Schedule our last words
            for i, line in ipairs(STRINGS.DST_MOD_REINCARNATION.ON_USE_SAY) do
                player:DoTaskInTime((i - 1) * TIME_BETWEEN_LINES,
                                    function()
                                        say(player, line)
                                    end)
            end
            -- Set the time to kill
            time_to_kill = (#STRINGS.DST_MOD_REINCARNATION.ON_USE_SAY - 1) *
                           TIME_BETWEEN_LINES
        -- Schedule killing
        player:DoTaskInTime(time_to_kill, dokill)
        -- Schedule despawning after the animation has played
        player:DoTaskInTime(time_to_kill + 3, dodespawn)
    end
end

-- Initiate respawning the player if the conditions are met
local function oneaten(inst, eater)
    if not eater:HasTag("player") and eater.components.health then
        SpawnPrefab("explode_small_slurtle").Transform:SetPosition(eater:GetPosition():Get()) 
        eater.components.health:Kill()
    end
	
    local player = inst.components.inventoryitem:GetGrandOwner()

    if player ~= nil and player:HasTag("player") then
        -- Refuse reincarnating with memory in slave shards
        if TheWorld:HasTag("cave") then
            say(player, STRINGS.DST_MOD_REINCARNATION.ON_REFUSE_SAY_SLAVE)
		    player.AnimState:PlayAnimation("emoteXL_annoyed")
			local nug = SpawnPrefab("beargerkit")
			local pt = Vector3(inst.Transform:GetWorldPosition()) + Vector3(0, 2, 0)
	
			nug.Transform:SetPosition(pt:Get())
			local down = TheCamera:GetDownVec()
			local angle = math.atan2(down.z, down.x) + (math.random() * 60 - 30) * DEGREES
			--local angle = (math.random() * 60 - 30 - TUNING.CAM_ROT - 90) / 180 * PI
			local sp = math.random() * 4 + 2
			nug.Physics:SetVel(sp * math.cos(angle), math.random() * 2 + 8, sp * math.sin(angle))						
        else
            despawn(player)
        end
    end
end

local function fn()
    local inst = CreateEntity()
 
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
 
    MakeInventoryPhysics(inst)
	
    inst.AnimState:SetBank("beargerkit")
    inst.AnimState:SetBuild("beargerkit")
    inst.AnimState:PlayAnimation("idle")

	inst:AddTag("molebait")
	inst:AddTag("catfood")
	inst:AddTag("preparedfood")		
	
	inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
	
    inst:AddComponent("inspectable")
    inst:AddComponent("bait")	
	
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "beargerkit"	
    inst.components.inventoryitem.atlasname = "images/inventoryimages/beargerkit.xml"		
	
    inst:AddComponent("edible")
    inst.components.edible.foodtype = FOODTYPE.VEGGIE
	inst.components.edible.healthvalue = 0
	inst.components.edible.sanityvalue = 0
    inst.components.edible.hungervalue = 0
    inst.components.edible:SetOnEatenFn(oneaten)
	
	inst:AddComponent("stackable") 
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
	
    MakeHauntableLaunch(inst)
	
    return inst
end

return Prefab("common/beargerkit", fn, assets)
