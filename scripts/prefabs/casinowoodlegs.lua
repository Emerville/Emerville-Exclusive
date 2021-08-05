local assets =
{
	Asset("ANIM", "anim/woodlegs.zip"),
	Asset("ANIM", "anim/woodlegs_dss.zip"),
    Asset("ANIM", "anim/quagmire_ui_pot_1x3.zip"),	

	Asset("SOUNDPACKAGE", "sound/woodlegs.fev"),
	Asset("SOUND", "sound/woodlegs.fsb"),	
}

--local brain = require("brains/woodlegsbrain")

local function onopen(inst)
	inst.SoundEmitter:PlaySound("dontstarve/common/together/gate/open")
end

local function onclose(inst)
	inst.SoundEmitter:PlaySound("dontstarve/common/together/gate/close")
end 

local function Greetings(inst)
    inst.components.talker:Say("I am seeking ultra rare items for trade!")
    inst.SoundEmitter:PlaySound("woodlegs/woodlegs/emote")
    inst.AnimState:PlayAnimation("emoteXL_waving1")
    inst.AnimState:PushAnimation("idle_loop")
end  
----------------------

local function fn(Sim)
    local inst = CreateEntity()
	
    --[[inst:AddTag("character")
    inst:AddTag("scarytoprey")
    inst:AddTag("noauradamage")
    inst:AddTag("notraptrigger")
    inst:AddTag("noauradamage")
    inst:AddTag("flying")]]	

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
	inst.entity:AddLight()																			
    inst.entity:AddNetwork()

--	MakeCharacterPhysics(inst, 1, 0.5)
    inst.Transform:SetFourFaced()
	
    local hats = {"hat_pirate"}
    local hat = hats[math.random(#hats)]
    inst.AnimState:OverrideSymbol("swap_hat", hat, "swap_hat")
    local objects = {"swap_purplecane"}	
    local object = objects[math.random(#objects)]
	inst.AnimState:OverrideSymbol("swap_object", object, "swap_purplecane")

    inst.AnimState:SetBank("wilson")
    inst.AnimState:SetBuild("woodlegs")
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
    inst.components.talker.colour = Vector3(10, 0, 0)
    inst.components.talker.offset = Vector3(0, -400, 0)		
	
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end	

 --[[   inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor.walkspeed = 3
    inst.components.locomotor.runspeed = 5
	
    inst:SetStateGraph("SGwoodlegs")
    inst.sg:GoToState("idle")	
	
    inst:AddComponent("knownlocations")]]	
		
    inst:AddComponent("inspectable")

	inst:AddComponent("container")
    inst.components.container:WidgetSetup("casinowoodlegs")
    inst.components.container.onopenfn = onopen
    inst.components.container.onclosefn = onclose
    inst.components.container.skipopensnd = true
    inst.components.container.skipclosesnd = true
	
    inst:DoPeriodicTask(30, Greetings)	
	
--    inst:SetBrain(brain)
	
    return inst
end

return Prefab("casinowoodlegs", fn, assets)