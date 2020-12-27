local assets =
{
    Asset("ANIM", "anim/bar.zip"),						-- Animation Zip
	
    Asset("ATLAS", "images/inventoryimages/bar.xml"),	-- Atlas for inventory TEX
    Asset("IMAGE", "images/inventoryimages/bar.tex"),	-- TEX for inventory
}

local prefabs = 
{
	"spoiled_food",
}

local function oneaten(inst, eater)
    local pt = Vector3(eater.Transform:GetWorldPosition())
    local numtentacles = 180
	
	--[[if eater.components.werebeast ~= nil and not eater.components.werebeast:IsInWereState() then
    eater.components.werebeast:TriggerDelta(4)
	end]]
	
	if eater.components.talker then
	eater.components.talker:Say("Look upon the stars, they are falling!", 4)
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
				inst.AnimState:PlayAnimation("disappear")
				if inst.components.combat then
					inst.components.combat:GetAttacked(inst, 50)--kill the star
				end
				inst.SoundEmitter:KillSound("hiss")
				inst.SoundEmitter:PlaySound("dontstarve/common/blackpowder_explo")
				SpawnPrefab("explode_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
				local x,y,z = inst.Transform:GetWorldPosition()
				local ents = TheSim:FindEntities(x, y, z, 3, nil, { "INLIMBO", "playerghost", "player", "companion", "abigail" }) 
				for i,v in pairs(ents) do
					if v.components.combat then
						v.components.combat:GetAttacked(inst, 25)
					end
				end
			end

            if result_offset ~= nil then
                local pos = pt + result_offset
                local frog = SpawnPrefab("stafflight")
				--frog.Transform:SetPosition(pos.x, pos.y, pos.z) 
				frog.Transform:SetRotation(math.random(360))
				--frog.sg:GoToState("fall")
				frog.Transform:SetScale(.4,.4,.4)
--				frog.Physics:Teleport(pos.x, 20, pos.z)
				frog:RemoveComponent("heater")
				frog:RemoveComponent("timer")
				frog:RemoveComponent("cooker")
				frog:RemoveComponent("propagator")
				frog:RemoveComponent("sanityaura")
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

local function fn()

	-- Create a new entity
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddNetwork()	
	
	MakeInventoryPhysics(inst)
	
	-- Set animation info
	inst.AnimState:SetBuild("bar")
	inst.AnimState:SetBank("bar")
	inst.AnimState:PlayAnimation("idle")

    inst.entity:SetPristine()		
		
	if not TheWorld.ismastersim then
        return inst
    end	
	
	-- Make it edible
	inst:AddComponent("edible")
    inst.components.edible.foodtype = FOODTYPE.MEAT	
	inst.components.edible.hungervalue =  TUNING.CALORIES_HUGE	-- Amount to fill belly
	inst.components.edible.sanityvalue =  TUNING.SANITY_MEDLARGE  -- Amount to help Sanity	
	inst.components.edible.healthvalue =  TUNING.HEALING_HUGE  -- Amount to heal
    inst.components.edible:SetOnEatenFn(oneaten)
	
	-- Make it perishable
	inst:AddComponent("perishable")
	inst.components.perishable:SetPerishTime(TUNING.PERISH_SLOW)
	inst.components.perishable:StartPerishing()
	inst.components.perishable.onperishreplacement = "spoiled_food"
	
	-- Make it stackable
	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
	
	-- Make it inspectable
	inst:AddComponent("inspectable")
	
	-- Make it an inventory item
	inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "bar"	-- Use our TEX sprite
    inst.components.inventoryitem.atlasname = "images/inventoryimages/bar.xml"	-- here's the atlas for our tex
	
	MakeHauntableLaunch(inst)	
		
	return inst
end

return Prefab("common/inventory/bar", fn, assets)