local assets =
{
    Asset("ANIM", "anim/player_basic.zip"),
    Asset("ANIM", "anim/player_actions.zip"),
    Asset("ANIM", "anim/player_idles.zip"),	
	Asset("ANIM", "anim/player_one_man_band.zip"),
    Asset("ANIM", "anim/player_emotesxl.zip"),
    Asset("ANIM", "anim/player_emotes_dance0.zip"),
    Asset("ANIM", "anim/player_emotes.zip"),	
	
    Asset("SOUND", "sound/wickerbottom.fsb"),		
}

local prefabs =
{
    "goldnugget",
	"goldcoin",
}

local function onopen(inst)
	inst.SoundEmitter:PlaySound("dontstarve/common/together/gate/open")
end

local function onclose(inst)
	inst.SoundEmitter:PlaySound("dontstarve/common/together/gate/close")
end 

local chance = 0.50 
local function RuleOrAd(inst)
		if math.random() < chance then
		inst.components.talker:Say("Please do not build on the Casino. Lets keep it clean!")
		inst.AnimState:PlayAnimation("emoteXL_annoyed")
		inst.AnimState:PushAnimation("idle_loop")
		else
		inst.components.talker:Say("I'm buying Gems for Gold Coins! Who wants to trade?")
		inst.AnimState:PlayAnimation("emoteXL_waving1")
		inst.AnimState:PushAnimation("idle_loop")
		end
end

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
	
    local hats = {"hat_peagawkfeather"}
    local hat = hats[math.random(#hats)]
    inst.AnimState:OverrideSymbol("swap_hat", hat, "swap_hat")
    local armors = {"armor_windbreaker"}
    local armor = armors[math.random(#armors)]
    inst.AnimState:OverrideSymbol("swap_body", armor, "swap_body")	
	local objects = {"swap_pinkcane"}
	local object = objects[math.random(#objects)]
	inst.AnimState:OverrideSymbol("swap_object", object, "swap_pinkcane")
	
    inst.AnimState:SetBank("wilson")
    inst.AnimState:SetBuild("wickerbottom")
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
	
--	inst.SoundEmitter:PlaySound("dontstarve_DLC001/characters/webber/talk_LP", "talk")

	inst:AddComponent("talker")
    inst.components.talker.fontsize = 35
    inst.components.talker.font = TALKINGFONT
    --inst.components.talker.colour = Vector3(133/255, 140/255, 167/255)
    inst.components.talker.offset = Vector3(0, -400, 0)	

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end	
		
    inst:AddComponent("inspectable")

	inst:AddComponent("container")
    inst.components.container:WidgetSetup("casinowickerbottom")
    inst.components.container.onopenfn = onopen
    inst.components.container.onclosefn = onclose		
	
--	inst:ListenForEvent("animqueueover",onanimover) --the listener persists
		
	inst:DoPeriodicTask(30, RuleOrAd)
	
    return inst
end

return Prefab("casinowickerbottom", fn, assets)