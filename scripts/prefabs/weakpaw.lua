local assets=
{
	Asset("ANIM", "anim/weakpaw.zip"),
	Asset("ANIM", "anim/swap_spear.zip"),
	
	Asset("ATLAS", "images/inventoryimages/weakpaw.xml"),
	Asset("IMAGE", "images/inventoryimages/weakpaw.tex"),
}


local prefabs = 
{
    "crosshair",
}

local function onfinished(inst)
    inst:Remove()
end

local function createlight(staff, target, pos)
local caster = staff.components.inventoryitem.owner
				
	if target:HasTag("player") then
         target.components.health:DoDelta(20)
		 caster.components.sanity:DoDelta(-5)
		 caster.components.hunger:DoDelta(-5) 
	else
		caster.components.talker:Say("I can only heal other players, silly.")
	end
end

local function onattack(inst, attacker, target)
    attacker.components.sanity:DoDelta(-0.2)
	local explode = SpawnPrefab("crosshair")
    local pos = target:GetPosition()
	explode.Transform:SetPosition(pos.x, pos.y, pos.z)
end

local function swingspell(inst, attacker, target)

	 local pt = attacker:GetPosition()
            local numtentacles = 2

        attacker:StartThread(function()
		Sleep(.10)
                for k = 1, numtentacles do
                
                    local theta = math.random() * 2 * PI
                    local radius = math.random(1, 2)

                    -- we have to special case this one because birds can't land on creep
                    local result_offset = FindValidPositionByFan(theta, radius, 1, function(offset)
                        local pos = pt + offset
                        local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, 1)
                        return next(ents) == nil
                    end)

                    if result_offset ~= nil then
                        local pos = pt + result_offset
                        local tentacle = SpawnPrefab("swing_charge")

                        tentacle.Transform:SetPosition(pos:Get())
						
					    tentacle.components.projectile:Throw(inst, target, attacker)
                    end                
                end
            end)
   return true
end



local function onequip(inst, owner) 
	inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(200)
	inst.components.weapon:SetRange(10)
	inst.components.weapon:SetOnAttack(onattack)
    inst.components.weapon:SetProjectile("swing_charge")
	inst.components.weapon:SetOnProjectileLaunch(swingspell)
    inst:AddComponent("spellcaster")
    inst.components.spellcaster:SetSpellFn(createlight)
	inst.components.spellcaster.canuseontargets = true
	inst.components.spellcaster.canonlyuseonlocomotors = true
end

local function onunequip(inst, owner) 
    inst:RemoveComponent("weapon")
	inst:RemoveComponent("spellcaster")
end

local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()
	
    MakeInventoryPhysics(inst)	
    
	anim:SetBank("weakpaw")
    anim:SetBuild("weakpaw")
    anim:PlayAnimation("idle")
    
	inst:AddTag("punch")
	
	inst.entity:SetPristine()

     if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
	
	inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(500)
    inst.components.finiteuses:SetUses(500)
	
	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "weakpaw"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/weakpaw.xml"
	
    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip( onequip )
    inst.components.equippable:SetOnUnequip( onunequip )
    
    return inst
end

return Prefab( "common/inventory/weakpaw", fn, assets, prefabs)
