local assets =
{
	Asset("ANIM", "anim/foodgen.zip"),
--	Asset("ATLAS", "images/inventoryimages/foodgen_map.xml"),
--  Asset("IMAGE", "images/inventoryimages/foodgen_map.tex"),
	Asset("SOUND", "sound/common.fsb"),
}

local prefabs =
{
    "bar",
	"trinket_6",
	"clockqueen",
} 

local function ItemTradeTest(inst, item)
    if item == nil then
        return false
    elseif item.prefab ~= "box_gear" then
        return false, "NOTATRIUMKEY"
    end
    return true
end

local function OnKeyGiven(inst, giver)
    --Disable trading, enable picking.
	inst.AnimState:PlayAnimation("idle", true)
    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_big")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("metal")
    inst:Remove()
--    spawnqueen(inst)
--    inst.components.trader:Disable()
--    inst.components.pickable:SetUp("box_gear", 1000000)
--    inst.components.pickable:Pause()
--    inst.components.pickable.caninteractwith = true

--    TheWorld:PushEvent("ms_locknightmarephase", "wild")
--    TheWorld:PushEvent("pausequakes", { source = inst })
--    TheWorld:PushEvent("pausehounded", { source = inst })

    if giver ~= nil then
        inst.SoundEmitter:PlaySound("dontstarve/common/together/atrium_gate/key_in")

--      if giver.components.talker ~= nil then
--          giver.components.talker:Say(GetString(giver, "ANNOUNCE_GATE_ON"))
--      end
    end
end


local function dospawnchest(inst)
 --   inst.SoundEmitter:PlaySound("dontstarve/common/ghost_spawn")

    local chest = SpawnPrefab("clockqueen")
    local x, y, z = inst.Transform:GetWorldPosition()
    chest.Transform:SetPosition(x, 0, z)

    local fx = SpawnPrefab("sparks")
    if fx ~= nil then
        fx.Transform:SetPosition(x, y, z)
        fx.Transform:SetScale(1, 2, 1)
    end
end

local function spawnchest(inst)
    inst:DoTaskInTime(3, dospawnchest)
end

SetSharedLootTable( 'foogentloot',
{
    {'clockqueen',  1.0},
    {'lightning',  1.0},	
 
})


--[[local function onhammered(inst, worker)
	inst.components.lootdropper:DropLoot()
	SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
	inst.SoundEmitter:PlaySound("dontstarve/common/destroy_metal")
	inst:Remove()
end

local function onhit(inst, worker)
	inst.AnimState:PlayAnimation("idle")
	inst.AnimState:PushAnimation("idle")
end 

local function getstatus(inst)
	
	if inst.components.pickable and not inst.components.pickable:CanBePicked() then
		STRINGS.CHARACTERS.GENERIC.DESCRIBE.FOODGEN = {	
		"It's empty",

		}
		STRINGS.CHARACTERS.WX78.DESCRIBE.FOODGEN = {	
		"ERROR: UNIT OFFLINE",

		}
	else
	STRINGS.CHARACTERS.GENERIC.DESCRIBE.FOODGEN = {	
		"That thing produces food!",
		}
	STRINGS.CHARACTERS.WX78.DESCRIBE.FOODGEN = {	
		"PROTEIN UNIT",

		}
	end
end  

local function onregenfn(inst)
	inst.AnimState:PlayAnimation("idle") 
	inst.AnimState:PushAnimation("idle", true)
end]]

local function makefullfn(inst)
	inst.AnimState:PlayAnimation("idle", true)
	
end



local function onpickedfn(inst)
	inst.SoundEmitter:PlaySound("dontstarve/wilson/pickup_reeds") 
	inst.AnimState:PushAnimation("empty", true)
	
end

local function makeemptyfn(inst)
	inst.AnimState:PlayAnimation("empty", true)
	
end


local function fn(Sim)
	local inst = CreateEntity()
	
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()	
		
	--	local minimap = inst.entity:AddMiniMapEntity()
	--	minimap:SetIcon( "foodgen_map.tex" )
	    
	inst.AnimState:SetBank("foodgen")
	inst.AnimState:SetBuild("foodgen")
	inst.AnimState:PlayAnimation("empty",true)
	inst.AnimState:SetTime(math.random()*2)
	
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end	

    inst:AddComponent("trader")
    inst.components.trader:SetAbleToAcceptTest(ItemTradeTest)
    inst.components.trader.deleteitemonaccept = true
    inst.components.trader.onaccept = OnKeyGiven

    inst:AddComponent("pickable")
  --  inst.components.pickable.picksound = "dontstarve/wilson/pickup_reeds"
	inst.components.pickable.caninteractwith = false
 --   inst.components.pickable.onpickedfn = OnKeyTaken
	
		
	--inst.components.pickable:SetUp("box_gear", TUNING.GRASS_REGROW_TIME)
	--inst.components.pickable.onregenfn = onregenfn
	inst.components.pickable.onpickedfn = onpickedfn
	inst.components.pickable.makeemptyfn = makeemptyfn
	inst.components.pickable.makefullfn = makefullfn

	--if stage == 1 then
	--inst.components.pickable:MakeBarren()
	--end
		
	inst:AddComponent("lootdropper")
	inst.components.lootdropper:SetChanceLootTable('foogentloot')
		
	inst:AddComponent("inspectable")
    --[[inst.components.inspectable.getstatus = getstatus]]	
	    
	return inst
end   

return Prefab("common/foodgen", fn, assets, prefabs)