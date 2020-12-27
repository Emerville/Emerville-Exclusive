local assets =
{
    Asset("ANIM", "anim/player_basic.zip"),
    Asset("ANIM", "anim/player_actions.zip"),
    Asset("ANIM", "anim/player_idles.zip"),	
	Asset("ANIM", "anim/player_one_man_band.zip"),
    Asset("ANIM", "anim/player_emotesxl.zip"),
    Asset("ANIM", "anim/player_emotes_dance0.zip"),
    Asset("ANIM", "anim/player_emotes.zip"),	
	
    Asset("SOUND", "sound/wendy.fsb"),		
}

local prefabs =
{
    "goldnugget",
	"halloweencandy_8",
}

local function Greetings(inst)
--   inst.components.talker:Say("Welcome to Halloweenville!")
--	inst.SoundEmitter:PlaySound("dontstarve/characters/wendy/emote")	
    inst.AnimState:PlayAnimation("emoteXL_waving1")
    inst.AnimState:PushAnimation("idle_loop")	
end

--[[local function ontradeforgold(inst, item)   
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
	inst.SoundEmitter:PlaySound("dontstarve/characters/wendy/emote")
    inst.AnimState:PlayAnimation("emoteXL_happycheer")
    if item.components.tradable.goldvalue > 0 then
        inst:DoTaskInTime(20/30, ontradeforgold, item)
		inst.components.talker:Say("Your offering pleases the spirits!")
		end
    inst.AnimState:PushAnimation("idle_loop")		
end	   

local function OnRefuseItem(inst, giver, item)
	inst.SoundEmitter:PlaySound("dontstarve/characters/wendy/emote")
	inst.components.talker:Say("The spirits are offended by your offering, begone!")	
    inst.AnimState:PlayAnimation("emoteXL_annoyed")
    inst.AnimState:PushAnimation("idle_loop")	
end

local function AcceptTest(inst, item)
    return item.components.tradable.goldvalue > 0
end]]

--[[local function stomp(inst)
	inst.AnimState:PlayAnimation("idle_onemanband1_pst")
	inst.AnimState:PushAnimation("idle_onemanband2_pre")
	inst.AnimState:PushAnimation("idle_onemanband2_loop")
	inst.AnimState:PushAnimation("idle_onemanband2_pst",false) --end of the chain, do NOT loop
	--inst:DoTaskInTime(.3,function(inst) if inst then --that if is just for being sure :P
		--inst.SoundEmitter:PlaySound("dontstarve/characters/wilton/hurt") --need better sound
	--end end)
end

local function onanimover(inst)
	if math.random() < 0.15 then
		stomp(inst)
	else
		inst.AnimState:PlayAnimation("idle_onemanband1_loop")
	end
end]]

--[[local function OnIsNight(inst, isnight)
    if isnight then
	inst.components.talker:Say("I'm scared of the dark! I need a hug!")
	inst.SoundEmitter:PlaySound("dontstarve_DLC001/characters/webber/emote")	
    inst.AnimState:PlayAnimation("emoteXL_sad")
    inst.AnimState:PushAnimation("idle_loop")	
	end
end]]

--[[    EventHandler("ontalk", function(inst, data)
        if inst.sg:HasStateTag("idle") and not inst.sg:HasStateTag("notalking") then
            if not inst:HasTag("mime") then
                inst.sg:GoToState("talk", data.noanim)
            elseif not inst.components.inventory:IsHeavyLifting() then
                --Don't do it even if mounted!
                inst.sg:GoToState("mime")
            end
        end
    end),]]
	
--[[
	
local function OnWorshipped(inst, doer, item)
	doer.components.talker:Say("Trick or Treat!")
    inst.AnimState:PlayAnimation("emoteXL_happycheer")
	inst.SoundEmitter:PlaySound("dontstarve/characters/wendy/emote")
	inst.components.talker:Say("Enjoy your candy!")
        local nug = SpawnPrefab("halloweencandy_8")
        local pt = Vector3(inst.Transform:GetWorldPosition()) + Vector3(0, 4.5, 0)
        
        nug.Transform:SetPosition(pt:Get())
        local down = TheCamera:GetDownVec()
        local angle = math.atan2(down.z, down.x) + (math.random() * 60 - 30) * DEGREES
        --local angle = (math.random() * 60 - 30 - TUNING.CAM_ROT - 90) / 180 * PI
        local sp = math.random() * 4 + 2
        nug.Physics:SetVel(sp * math.cos(angle), math.random() * 2 + 8, sp * math.sin(angle))	
--    doer.components.health:DoDelta(25,false,"shrine_elyon")
	inst:DoTaskInTime(50,
    inst.AnimState:PlayAnimation("idle_loop", true)    )
    inst:DoTaskInTime(10, 
    function() 
    inst.components.activatable.inactive = true
		   end
   )
end]]


local function onidle(inst) 
    inst.AnimState:PlayAnimation("idle_loop", true)
end


for i = 1, NUM_HALLOWEENCANDY do
    table.insert(prefabs, "halloweencandy_"..i)
end

local function launchitem(item, angle)
    local speed = math.random() * 4 + 2
    angle = (angle + math.random() * 60 - 30) * DEGREES
    item.Physics:SetVel(speed * math.cos(angle), math.random() * 2 + 8, speed * math.sin(angle))
end

local function OnWorshipped(inst, doer, item)
	doer.components.talker:Say("Trick or Treat!")
	inst.components.talker:Say("Happy Halloween!")
    inst.AnimState:PlayAnimation("emoteXL_waving1")	
	inst.SoundEmitter:PlaySound("dontstarve/characters/wendy/emote")	
    doer.AnimState:PlayAnimation("emoteXL_happycheer")	

    inst:DoTaskInTime(2, onidle)

--	inst:DoTaskInTime(50,
--    inst.AnimState:PlayAnimation("idle_loop", true)    )	
--    inst.AnimState:PlayAnimation("idle_loop", true) 	

    local x, y, z = inst.Transform:GetWorldPosition()
    y = 4.5

    local angle
    if doer ~= nil and doer:IsValid() then
        angle = 180 - doer:GetAngleToPoint(x, 0, z)
    else
        local down = TheCamera:GetDownVec()
        angle = math.atan2(down.z, down.x) / DEGREES
        doer = nil
    end

    for k = 1, 0 do
        local nug = SpawnPrefab("goldnugget")
        nug.Transform:SetPosition(x, y, z)
        launchitem(nug, angle)
    end

 --[[   if item.components.tradable.tradefor ~= nil then
        for _, v in pairs(item.components.tradable.tradefor) do
            local item = SpawnPrefab(v)
            if item ~= nil then
                item.Transform:SetPosition(x, y, z)
                launchitem(item, angle)
            end
        end]]
 --   end

 

    if IsSpecialEventActive(SPECIAL_EVENTS.HALLOWED_NIGHTS) then
        -- pick out up to 3 types of candies to throw out
        local candytypes = { math.random(NUM_HALLOWEENCANDY), math.random(NUM_HALLOWEENCANDY), math.random(NUM_HALLOWEENCANDY) }
        local numcandies = (0) + math.random(2) + 1

        -- only people in costumes get a good amount of candy!      
        if doer ~= nil and doer.components.skinner ~= nil then
            for _, item in pairs(doer.components.skinner:GetClothing()) do
				if DoesItemHaveTag(item, "COSTUME") then
					numcandies = numcandies + math.random(4) + 2
					break
				end
            end
        end

        for k = 1, numcandies do
            local candy = SpawnPrefab("halloweencandy_"..GetRandomItem(candytypes))
            candy.Transform:SetPosition(x, y, z)
            launchitem(candy, angle)
        end

    inst:DoTaskInTime(10, 
    function() 
    inst.components.activatable.inactive = true
		   end
   )		
		
    end    
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
	
    local hats = {"hat_flower"}
    local hat = hats[math.random(#hats)]
    inst.AnimState:OverrideSymbol("swap_hat", hat, "swap_hat")
    local armors = {"torso_hawaiian"}
    local armor = armors[math.random(#armors)]
    inst.AnimState:OverrideSymbol("swap_body", armor, "swap_body")	
--[[	local objects = {"nightsword"}
	local object = objects[math.random(#objects)]
    inst.AnimState:OverrideSymbol("swap_object", object, "swap_object")]]
 
    inst.AnimState:SetBank("wilson")
    inst.AnimState:SetBuild("wendy")
    inst.AnimState:PlayAnimation("idle_loop", true)--inst.AnimState:PlayAnimation("idle_onemanband1_loop") --idle_loop --funnyidle --idle_inaction
		
    inst.AnimState:Show("HAT")
    inst.AnimState:Show("HAIR_HAT")
    inst.AnimState:Hide("HAIR_NOHAT")
    inst.AnimState:Hide("HAIR")
    inst.AnimState:Hide("ARM_carry")
    inst.AnimState:Show("ARM_normal")	
	
    inst.DynamicShadow:SetSize(1.3, .6)	
	
    local light = inst.entity:AddLight()
    light:SetFalloff(1)
    light:SetIntensity(.8)
    light:SetRadius(2)
    light:SetColour(180/255, 195/255, 50/255)
    light:Enable(true)		
	
--	inst.SoundEmitter:PlaySound("dontstarve_DLC001/characters/webber/talk_LP", "talk")

    inst:AddTag("trader")

	inst:AddComponent("talker")
    inst.components.talker.fontsize = 35
    inst.components.talker.font = TALKINGFONT
    --inst.components.talker.colour = Vector3(133/255, 140/255, 167/255)
    inst.components.talker.offset = Vector3(0, -400, 0)	

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end	
		
--    inst:AddComponent("inspectable")
	
    inst:AddComponent("activatable")    
    inst.components.activatable.OnActivate = OnWorshipped	

   inst:AddComponent("trader")
--    inst.components.trader:SetAcceptTest(AcceptTest)
--    inst.components.trader.onaccept = OnGetItemFromPlayer
 --   inst.components.trader.onrefuse = OnRefuseItem		
	
--	inst:ListenForEvent("animqueueover",onanimover) --the listener persists
	
--    inst:WatchWorldState("isnight", OnIsNight)
--    OnIsNight(inst, TheWorld.state.isnight)	
   inst:DoPeriodicTask(30, Greetings)	
	
    return inst
end

return Prefab("halloweenwendy", fn, assets)