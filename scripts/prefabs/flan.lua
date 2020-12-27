local assets =
{
	Asset("ANIM", "anim/flan.zip"),
    Asset("ATLAS", "images/inventoryimages/flan.xml")
}

local prefabs = 
{
	"spoiled_food",
}

local function OnEaten(inst, eater)
    local pt = Vector3(eater.Transform:GetWorldPosition())
    local numtentacles = 40
	
	--[[if eater.components.werebeast ~= nil and not eater.components.werebeast:IsInWereState() then
    eater.components.werebeast:TriggerDelta(4)
	end]]
	
	if eater.components.talker then
	eater.components.talker:Say("That was super delicious!", 5)
	end
    
	eater:StartThread(function()
        for k = 1, numtentacles do
        
            local theta = math.random() * 2 * PI
            local radius = math.random(3, 16)

            -- we have to special case this one because birds can't land on creep
            local result_offset = FindValidPositionByFan(theta, radius, 12, function(offset)
                local pos = pt + offset
                local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, 1)
                return next(ents) == nil
            end)
			
			--[[Frog ondeathfn]]--			
			local function DoExplosion(inst)
				inst:Remove()
				if inst.components.combat then
					inst.components.combat:GetAttacked(inst, 50)--kill the star
				end
--				inst.SoundEmitter:KillSound("hiss")
--				inst.SoundEmitter:PlaySound("dontstarve/common/blackpowder_explo")
				SpawnPrefab("explode_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
				local x,y,z = inst.Transform:GetWorldPosition()
				
-- We have limited it to entities with the "player" tag, that are also not ghosts or otherwise in limbo.
-- Radius has been set to 10
--local players = TheSim:FindEntities(x, y, z, 10, {"player"}, {"playerghost", "INLIMBO"}, nil)			
--TheSim:FindEntities(x, y, z, radius, musttags, canttags, mustoneoftags)
				
				local ents = TheSim:FindEntities(x, y, z, 3, nil, { "INLIMBO", "player", "playerghost", "abigail",   }) 
				for i,v in pairs(ents) do
					if v.components.combat then
						v.components.combat:GetAttacked(inst, 25)
					end
				end
			end

            if result_offset ~= nil then
                local pos = pt + result_offset
                local frog = SpawnPrefab("falsecoin")				
				--frog.Transform:SetPosition(pos.x, pos.y, pos.z) 
				frog.Transform:SetRotation(math.random(360))
				--frog.sg:GoToState("fall")
				--frog.Transform:SetScale(.4,.4,.4)
				frog.Physics:Teleport(pos.x, 20, pos.z)
				frog:AddComponent("timer")
				frog.components.timer:StartTimer("extinguish", 1.0)
				frog:ListenForEvent("timerdone", DoExplosion)
				--frog:ListenForEvent("death", DoExplosion)
            end

            Sleep(.01)
        end
    end)
    return true
end

-- Still does nothing. Dunno what it should do...
local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
	
    MakeInventoryPhysics(inst)
		
	inst.AnimState:SetBank("flan")
    inst.AnimState:SetBuild("flan")
    inst.AnimState:PlayAnimation("idle", false)
   
	inst:AddTag("flan")
	inst:AddTag("preparedfood")
	
	inst.entity:SetPristine() 	
	
    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
	
    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/inventoryimages/flan.xml"
	
	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
	
	inst:AddComponent("edible")
	inst.components.edible.foodtype = "MEAT"
	inst.components.edible.healthvalue = 50
	inst.components.edible.hungervalue = 50
	inst.components.edible.sanityvalue = 50
    inst.components.edible:SetOnEatenFn(OnEaten)
	
	inst:AddComponent("perishable")
	inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)
	inst.components.perishable:StartPerishing()
	inst.components.perishable.onperishreplacement = "spoiled_food"
	
    MakeHauntableLaunch(inst)	
	
    return inst
end

return Prefab("common/inventory/flan", fn, assets) 

