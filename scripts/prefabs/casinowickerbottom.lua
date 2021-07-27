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
	inst.Transform:SetRotation(-90)
	
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
    inst.components.container.skipopensnd = true
    inst.components.container.skipclosesnd = true
	
--	inst:ListenForEvent("animqueueover",onanimover) --the listener persists
		
	inst:DoPeriodicTask(30, RuleOrAd)
	
    return inst
end

return Prefab("casinowickerbottom", fn, assets)