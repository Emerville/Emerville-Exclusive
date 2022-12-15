local assets =
{
    Asset("ANIM", "anim/player_basic.zip"),
    Asset("ANIM", "anim/player_actions.zip"),
    Asset("ANIM", "anim/player_idles.zip"),	
	Asset("ANIM", "anim/player_one_man_band.zip"),
    Asset("ANIM", "anim/player_emotesxl.zip"),
    Asset("ANIM", "anim/player_emotes_dance0.zip"),
    Asset("ANIM", "anim/player_emotes.zip"),

    Asset("ANIM", "anim/player_emotes_sit.zip"),
    Asset("ANIM", "anim/player_emote_extra.zip"), -- item emotes
    Asset("ANIM", "anim/player_emotes_dance2.zip"), -- item emotes	
	
    Asset("SOUND", "sound/wathgrithr.fsb"),		
}

local prefabs =
{
    "puffspizza",
	"goldcoin",
}

local function Greetings(inst)
    inst.components.talker:Say("I'm waiting for my meat lovers pizza to be delivered.")
    inst.SoundEmitter:PlaySound("dontstarve_DLC001/characters/wathgrithr/emote")	
    inst.AnimState:PlayAnimation("emoteXL_annoyed")
    inst.AnimState:PushAnimation("idle_loop")	
end

local function ontradeforgold(inst, item) 
	local coins = SpawnPrefab("goldcoin")
    local maxstack = coins.components.stackable.maxsize
    local num = 10
    coins.components.stackable:SetStackSize(num)
	
    local pt = Vector3(inst.Transform:GetWorldPosition()) + Vector3(0, 4.5, 0)
        
    coins.Transform:SetPosition(pt:Get())
    local down = TheCamera:GetDownVec()
    local angle = math.atan2(down.z, down.x) + (math.random() * 60 - 30) * DEGREES
    --local angle = (math.random() * 60 - 30 - TUNING.CAM_ROT - 90) / 180 * PI
    local sp = math.random() * 4 + 2
    coins.Physics:SetVel(sp * math.cos(angle), math.random() * 2 + 8, sp * math.sin(angle))
end


local function say(inst)
    if inst ~= nil and inst.components.talker ~= nil then
        inst.components.talker:Say("The perfect pizza!")
		inst.AnimState:PlayAnimation("emoteXL_happycheer")
	    inst.SoundEmitter:PlaySound("dontstarve_DLC001/characters/wathgrithr/emote")
		inst.AnimState:PushAnimation("idle_loop")
    end
end

local function OnGetItemFromPlayer(inst, giver, item)
	giver.components.talker:Say("Here's your pizza, enjoy.")
    if item.prefab == "puffspizza" then
        inst:DoTaskInTime(2.5, ontradeforgold, item)
		inst:DoTaskInTime(2.5, say)
	end

	local pizza = SpawnPrefab("puffspizza")
	pizza.Transform:SetPosition(giver:GetPosition():Get())
	pizza:RandomTeleport()		
end	   

local function OnRefuseItem(inst, giver, item)
	inst.SoundEmitter:PlaySound("dontstarve_DLC001/characters/wathgrithr/emote")
	inst.components.talker:Say("That's a not a meat lover's pizza.")	 	
    inst.AnimState:PlayAnimation("emoteXL_annoyed")
    inst.AnimState:PushAnimation("idle_loop")	
end

local function AcceptTest(inst, item)
    return item.prefab == "puffspizza"
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
	
    local hats = {"hat_snakeskin"}
    local hat = hats[math.random(#hats)]
    inst.AnimState:OverrideSymbol("swap_hat", hat, "swap_hat")
--[[    local armors = {"torso_hawaiian"}
    local armor = armors[math.random(#armors)]
    inst.AnimState:OverrideSymbol("swap_body", armor, "swap_body")]]	
--[[   local objects = {"swap_slingshot"}	
    local object = objects[math.random(#objects)]
	inst.AnimState:OverrideSymbol("swap_object", object, "swap_slingshot")]]
 
    inst.AnimState:SetBank("wilson")
    inst.AnimState:SetBuild("wathgrithr")
    inst.AnimState:PlayAnimation("idle_loop", true)--inst.AnimState:PlayAnimation("idle_onemanband1_loop") --idle_loop --funnyidle --idle_inaction

    inst.AnimState:Hide("HEAD")
    inst.AnimState:Show("HEAD_HAT")		
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

    inst:AddTag("trader")

	inst:AddComponent("talker")
    inst.components.talker.fontsize = 35
    inst.components.talker.font = TALKINGFONT
--    inst.components.talker.colour = Vector3(133/255, 140/255, 167/255)
    inst.components.talker.offset = Vector3(0, -400, 0)	

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end	
		
    inst:AddComponent("inspectable")

    inst:AddComponent("trader")
    inst.components.trader:SetAcceptTest(AcceptTest)
    inst.components.trader.onaccept = OnGetItemFromPlayer
    inst.components.trader.onrefuse = OnRefuseItem		
	
    inst:DoPeriodicTask(45, Greetings)	
	
    return inst
end

return Prefab("pizzawathgrithr", fn, assets)