local assets =
{
	Asset("ANIM", "anim/statuecharlie.zip"),
--	Asset("ATLAS", "images/inventoryimages/foodgen_map.xml"),
--  Asset("IMAGE", "images/inventoryimages/foodgen_map.tex"),
	Asset("SOUND", "sound/common.fsb"),
}

local prefabs =
{
    "musicbox",
}

local function ItemTradeTest(inst, item)
    if item == nil then
        return false
    elseif item.prefab ~= "rosekey" then
        return false, "NOTATRIUMKEY"
    end
    return true
end

local function StatueShatter(inst)
	inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/iceboulder_smash")
    inst.SoundEmitter:PlaySound("musicbox/sound/playmelodycharlie")
end

--TO DO: Make a rose key spawn randomly in the world after recieving a rose key from a player.
local function OnKeyGiven(inst, giver)  
    inst:DoTaskInTime(2, function() StatueShatter(inst) end)
	inst.AnimState:PlayAnimation("dance")
	inst.components.talker:Say("Well, aren't you the sweetest thing.")
	inst.SoundEmitter:PlaySound("dontstarve/characters/winona/emote")
	local dubloon = SpawnPrefab("battlesong_durability_fx")
	dubloon.Transform:SetPosition(inst.Transform:GetWorldPosition())
	local nug = SpawnPrefab("musicbox")
	local pt = Vector3(inst.Transform:GetWorldPosition()) + Vector3(0, 4.5, 0)
	
	nug.Transform:SetPosition(pt:Get())
	local down = TheCamera:GetDownVec()
	local angle = math.atan2(down.z, down.x) + (math.random() * 60 - 30) * DEGREES
	--local angle = (math.random() * 60 - 30 - TUNING.CAM_ROT - 90) / 180 * PI
	local sp = math.random() * 4 + 2
	nug.Physics:SetVel(sp * math.cos(angle), math.random() * 2 + 8, sp * math.sin(angle))

	if giver ~= nil then
        inst.SoundEmitter:PlaySound("dontstarve/common/together/atrium_gate/key_in")
		inst.AnimState:PushAnimation("idle_evil")
    end
	
	local key = SpawnPrefab("rosekey")
	key.Transform:SetPosition(giver:GetPosition():Get())
	key:RandomTeleport()
end

local function fn(Sim)
	local inst = CreateEntity()
	
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()	
		
	--	local minimap = inst.entity:AddMiniMapEntity()
	--	minimap:SetIcon( "foodgen_map.tex" )
    MakeObstaclePhysics(inst, 1)
	    
    inst.AnimState:SetBank("statuecharlie") --replace with Charlie Statue when Whisper is done with Animation File.
    inst.AnimState:SetBuild("statuecharlie")
    inst.AnimState:PlayAnimation("idle_evil")
    inst.AnimState:SetScale(3, 3)
	
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end	

	inst:AddComponent("inspectable")
	
	inst:AddComponent("talker")
    inst.components.talker.fontsize = 35
    inst.components.talker.font = TALKINGFONT
    --inst.components.talker.colour = Vector3(133/255, 140/255, 167/255)
    inst.components.talker.offset = Vector3(0, -800, 0)	

    inst:AddComponent("trader")
    inst.components.trader:SetAbleToAcceptTest(ItemTradeTest)
    inst.components.trader.deleteitemonaccept = true
    inst.components.trader.onaccept = OnKeyGiven
	    
	return inst
end   

return Prefab("common/statuecharlie", fn, assets, prefabs)