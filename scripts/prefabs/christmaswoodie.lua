local assets =
{
    Asset("ANIM", "anim/player_basic.zip"),
    Asset("ANIM", "anim/player_actions.zip"),
    Asset("ANIM", "anim/player_idles.zip"),	
	Asset("ANIM", "anim/player_one_man_band.zip"),
    Asset("ANIM", "anim/player_emotesxl.zip"),
    Asset("ANIM", "anim/player_emotes_dance0.zip"),
    Asset("ANIM", "anim/player_emotes.zip"),	
	
    Asset("SOUND", "sound/willow.fsb"),		
}

local prefabs =
{
	"statue_transition",
	"statue_transition_2",
    "goldnugget",
	"snowglobe",
	"santa_helper_hat",	
	"magicbag2",
}

local offering_recipe =
{
	magicbag2 = { "magicbag", "magicbag", "magicbag", "magicbag", "magicbag", "magicbag",},
 --   snowglobe = { "walrus_tusk", "purplegem", "goldnugget", "rocks", "silk", "ice",},
}

for k, _ in pairs(offering_recipe) do
	table.insert(prefabs, k)
end

local function CheckOffering(items)
	for k, recipe in pairs(offering_recipe) do
		local valid = true
		for i, item in ipairs(items) do
			if recipe[i] ~= item.prefab then
				valid = false
				break
			end
		end
		if valid then
			return k
		end
	end
		
	return nil
end


local MIN_LOCK_TIME = 2.5

local function UnlockChest(inst, param, doer)
	inst:DoTaskInTime(math.max(0, MIN_LOCK_TIME - (GetTime() - inst.lockstarttime)), function()
	    inst.SoundEmitter:KillSound("loop")

		if param == 1 then
--			inst.AnimState:PushAnimation("closed", false)
			inst.components.container.canbeopened = true
			if doer ~= nil and doer:IsValid() and doer.components.talker ~= nil then
				doer.components.talker:Say(GetString(doer, "ANNOUNCE_SACREDCHEST_NO"))
			end
		elseif param == 3 then
--			inst.AnimState:PlayAnimation("open") 
		    inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open")
			SpawnPrefab("statue_transition").Transform:SetPosition(inst.Transform:GetWorldPosition())
			SpawnPrefab("statue_transition_2").Transform:SetPosition(inst.Transform:GetWorldPosition())
			inst:DoTaskInTime(0.75, function()
--				inst.AnimState:PlayAnimation("close")
			    inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close")
				inst.components.container.canbeopened = true

				if doer ~= nil and doer:IsValid() and doer.components.talker ~= nil then
					doer.components.talker:Say(GetString(doer, "ANNOUNCE_SACREDCHEST_YES"))
				end
				TheNet:Announce(STRINGS.UI.HUD.REPORT_RESULT_ANNOUCEMENT)
			end)
		else
--			inst.AnimState:PlayAnimation("open") 
		    inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open")
			inst:DoTaskInTime(.2, function() 
				inst.components.container:DropEverything() 
				inst:DoTaskInTime(0.2, function()
--					inst.AnimState:PlayAnimation("close")
				    inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close")
					inst.components.container.canbeopened = true

					if doer ~= nil and doer:IsValid() and doer.components.talker ~= nil then
						doer.components.talker:Say(GetString(doer, "ANNOUNCE_SACREDCHEST_NO"))
					end
				end)
			end)
		end
	end)

	if param == 3 then
		inst.components.container:DestroyContents()
	end
end

local function LockChest(inst)
	inst.components.container.canbeopened = false
	inst.lockstarttime = GetTime()
--	inst.AnimState:PlayAnimation("hit", true)
--    inst.SoundEmitter:PlaySound("dontstarve/common/together/sacred_chest/shake_LP", "loop")
end 

local function onopen(inst) 
--    inst.AnimState:PlayAnimation("open")
    inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open")
end 

local function DoNetworkOffering(inst, doer)
	if (not TheNet:IsOnlineMode()) or
		(not inst.components.container:IsFull()) or
		doer == nil or 
		not doer:IsValid() then
	    inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close")
		return
	end

	LockChest(inst)

	local x, y, z = inst.Transform:GetWorldPosition()
	local players = FindPlayersInRange(x, y, z, 40)
	if #players <= 1 then
		UnlockChest(inst, 2, doer)
		return
	end

	local items = {}
	local counts = {}
	for i, k in ipairs(inst.components.container.slots) do
		if k ~= nil then
			table.insert(items, k.prefab)
			table.insert(counts, k.components.stackable ~= nil and k.components.stackable:StackSize() or 1)
		end
    end

	local userids = {}
	for i,p in ipairs(players) do
		if p ~= doer and p.userid then
			table.insert(userids, p.userid)
		end
	end

	ReportAction(doer.userid, items, counts, userids, function(param) if inst:IsValid() then UnlockChest(inst, param, doer) end end)
end

local function DoLocalOffering(inst, doer)
	if inst.components.container:IsFull() then
		local rewarditem = CheckOffering(inst.components.container.slots)
		if rewarditem then
			inst.AnimState:PlayAnimation("emoteXL_happycheer")
			inst.components.talker:Say("Here's a gift for your troubles.")
			inst.SoundEmitter:PlaySound("dontstarve/characters/woodie/emote")
			inst.AnimState:PushAnimation("idle_loop")
			LockChest(inst)
			inst.components.container:DestroyContents()
			inst.components.container:GiveItem(SpawnPrefab(rewarditem))
			inst.components.timer:StartTimer("localoffering", MIN_LOCK_TIME)
			return true
		end
	end
	
	return false
end

local function OnLocalOffering(inst)
--	inst.AnimState:PlayAnimation("open") 
    inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open")
    inst.components.timer:StartTimer("localoffering_pst", 0.2)
end

local function OnLocalOfferingPst(inst)
	inst.components.container:DropEverything() 
	inst:DoTaskInTime(0.2, function()
--		inst.AnimState:PlayAnimation("close")
	    inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close")
		inst.components.container.canbeopened = true
	end)
end

local function onclose(inst, doer)
--    inst.AnimState:PlayAnimation("close")

	if not DoLocalOffering(inst, doer) then
		DoNetworkOffering(inst, doer)
	end
end

local function OnTimerDone(inst, data)
	if data ~= nil then
		if data.name == "localoffering" then
			OnLocalOffering(inst)
		elseif data.name == "localoffering_pst" then
			OnLocalOfferingPst(inst)
		end
		
	end
end

local function getstatus(inst)
    return (inst.components.container.canbeopened == false and "LOCKED") or
			nil
end

local function OnLoadPostPass(inst)
    if inst.components.timer:TimerExists("localoffering") then
    	LockChest(inst)
    elseif inst.components.timer:TimerExists("localoffering_pst") then
    	LockChest(inst)
    	inst.components.timer:StopTimer("localoffering_pst")
    	OnLocalOffering(inst)
	end
end
----------------------

local chance = 0.50 
local function Greetings(inst)
		if math.random() < chance then
        inst.components.talker:Say("Would you mind fetching me 1 Walrus Tusk, Purple Gem, Gold Nugget, Rock, Silk, and some Ice please?", 10)
	    inst.SoundEmitter:PlaySound("dontstarve/characters/woodie/emote")
        inst.AnimState:PlayAnimation("emoteXL_waving1")
		else
		inst.components.talker:Say("Welcome to my Christmas Tree farm!")
	    inst.SoundEmitter:PlaySound("dontstarve/characters/woodie/emote")
        inst.AnimState:PlayAnimation("emoteXL_waving1")
		end
end

local function ontradeforgold(inst, item)   
    for k = 1, item.components.tradable.goldvalue do
        local nug = SpawnPrefab("goldnugget")
        local pt = Vector3(inst.Transform:GetWorldPosition()) + Vector3(0, 4.5, 0)
        
        nug.Transform:SetPosition(pt:Get())
        local down = TheCamera:GetDownVec()
        local angle = math.atan2(down.z, down.x) + (math.random() * 60 - 30) * DEGREES
        --local angle = (math.random() * 60 - 30 - TUNING.CAM_ROT - 90) / 180 * PI
        local sp = math.random() * 4 + 2
        nug.Physics:SetVel(sp * math.cos(angle), math.random() * 2 + 8, sp * math.sin(angle))
    end
end

local function OnGetItemFromPlayer(inst, giver, item)
	inst.SoundEmitter:PlaySound("dontstarve/characters/woodie/emote")
    inst.AnimState:PlayAnimation("emoteXL_happycheer")
    if item.components.tradable.goldvalue > 0 then
        inst:DoTaskInTime(20/30, ontradeforgold, item)
		inst.components.talker:Say("Here you go, friend.")
		end
    inst.AnimState:PushAnimation("idle_loop")		
end	   

local function OnRefuseItem(inst, giver, item)
	inst.SoundEmitter:PlaySound("dontstarve/characters/woodie/emote")
	inst.components.talker:Say("I don't want this!")	
    inst.AnimState:PlayAnimation("emoteXL_annoyed")
    inst.AnimState:PushAnimation("idle_loop")	
end

local function AcceptTest(inst, item)
    return item.components.tradable.goldvalue > 0
end

local function fn(Sim)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
	inst.entity:AddLight()																			
    inst.entity:AddNetwork()
	
	MakeObstaclePhysics(inst, .3)

    inst.Transform:SetFourFaced()
	
    local hats = {"hat_santa_helper"}
    local hat = hats[math.random(#hats)]
    inst.AnimState:OverrideSymbol("swap_hat", hat, "swap_hat")
    local armors = {"baronsuit"}
    local armor = armors[math.random(#armors)]
    inst.AnimState:OverrideSymbol("swap_body", armor, "swap_body")
    local objects = {"swap_greencane"}	
    local object = objects[math.random(#objects)]
	inst.AnimState:OverrideSymbol("swap_object", object, "swap_greencane")

    inst.AnimState:SetBank("wilson")
    inst.AnimState:SetBuild("woodie")
    inst.AnimState:PlayAnimation("idle_loop", true)--inst.AnimState:PlayAnimation("idle_onemanband1_loop") --idle_loop --funnyidle --idle_inaction
		
    inst.AnimState:Show("HAT")
    inst.AnimState:Show("HAIR_HAT")
    inst.AnimState:Hide("HAIR_NOHAT")
    inst.AnimState:Hide("HAIR")
    inst.AnimState:Show("ARM_carry")
    inst.AnimState:Hide("ARM_normal")	
	
    inst.DynamicShadow:SetSize(1.3, .6)	
	
    local light = inst.entity:AddLight()
    light:SetFalloff(1)
    light:SetIntensity(.8)
    light:SetRadius(2)
    light:SetColour(180/255, 195/255, 50/255)
    light:Enable(true)		
	
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end	
	
	inst:AddComponent("talker")
    inst.components.talker.fontsize = 35
    inst.components.talker.font = TALKINGFONT
    --inst.components.talker.colour = Vector3(133/255, 140/255, 167/255)
    inst.components.talker.offset = Vector3(0, -400, 0)		
		
    inst:AddComponent("inspectable")
	inst.components.inspectable.getstatus = getstatus	

	inst:AddComponent("container")
    inst.components.container:WidgetSetup("sacred_chest")
    inst.components.container.onopenfn = onopen
    inst.components.container.onclosefn = onclose
    inst.components.container.skipopensnd = true
    inst.components.container.skipclosesnd = true
	
    inst:DoPeriodicTask(20, Greetings)

    inst:AddComponent("timer")
    inst:ListenForEvent("timerdone", OnTimerDone)

	inst.OnLoadPostPass = OnLoadPostPass	
	
    return inst
end

return Prefab("christmaswoodie", fn, assets)