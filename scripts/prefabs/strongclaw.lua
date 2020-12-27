local assets=
{
	Asset("ANIM", "anim/strongclaw.zip"),
	
	Asset("ATLAS", "images/inventoryimages/strongclaw.xml"),
	Asset("IMAGE", "images/inventoryimages/strongclaw.tex"),
}


local prefabs = 
{
	"crosshair",
	"clawmeteor"
}


local function onfinished(inst)
    inst:Remove()
end


local function stopregen(inst)
    inst.components.health:StopRegen()
	inst:RemoveTag("graceful")
end

local function createlight(staff, target, pos)
 local caster = staff.components.inventoryitem.owner
	
	if target:HasTag("graceful") then
	caster.components.talker:Say("They've already been graced by me.") 
		else	
	if target:HasTag("player") then
	target:AddTag("graceful")
    target.components.health:StartRegen(1, 1)
	target:DoTaskInTime(40, stopregen)
	caster.components.sanity:DoDelta(-5)
    caster.components.hunger:DoDelta(-5) 
		else
  	caster.components.talker:Say("I can only heal other players, silly.")
	end		       
  end
end

local function resetmovespeed(inst)
	SpawnPrefab("small_puff").Transform:SetPosition(inst.Transform:GetWorldPosition())
	inst:DoTaskInTime(0.1, inst:Show())
  
	inst.components.locomotor.walkspeed = (4.5)
    inst.components.locomotor.runspeed = (6.5)
	inst.components.health:SetInvincible(false)
end

local function onattack(inst, attacker, target)
	attacker.components.combat.min_attack_period = 2
	attacker.components.locomotor.walkspeed = (0)
    attacker.components.locomotor.runspeed = (0)	
	attacker.components.health:SetInvincible(true)

	SpawnPrefab("small_puff").Transform:SetPosition(attacker.Transform:GetWorldPosition())
	attacker:Hide()
	local explode = SpawnPrefab("clawmeteor")
	explode.OFFSPELLCASTER = attacker
    local pos = target:GetPosition()
    explode.Transform:SetPosition(pos.x, pos.y, pos.z)

	
	local explode = SpawnPrefab("joznado")
    local pos = target:GetPosition()

    explode.Transform:SetPosition(pos.x, pos.y, pos.z)
	
	local explode = SpawnPrefab("jozaggro")
    local pos = target:GetPosition()
	explode.OFFSPELLCASTER = attacker
    explode.Transform:SetPosition(pos.x, pos.y, pos.z)
	
	if attacker and attacker.components.sanity then
        attacker.components.sanity:DoDelta(-3)
		attacker.components.hunger:DoDelta(-3)
    end
	
	attacker.AnimState:PushAnimation("emote_strikepose", false)
	attacker:DoTaskInTime(1.1, resetmovespeed)
end


local function onequip(inst, owner)  
	owner.components.combat.min_attack_period = 2
	
    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(9000)
	inst.components.weapon:SetRange(10)
	inst.components.weapon:SetOnAttack(onattack)

    inst:AddComponent("spellcaster")
    inst.components.spellcaster:SetSpellFn(createlight)
	inst.components.spellcaster.canuseontargets = true
	inst.components.spellcaster.canonlyuseonlocomotors = true
end

local function onunequip(inst, owner) 
	owner.components.combat.min_attack_period = TUNING.WILSON_ATTACK_PERIOD
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
    
	anim:SetBank("strongclaw")
    anim:SetBuild("strongclaw")
    anim:PlayAnimation("idle")
    
	inst:AddTag("punch")
	
	inst.entity:SetPristine()

      if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
	
    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(300)
    inst.components.finiteuses:SetUses(300)
	
	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "strongclaw"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/strongclaw.xml"
	
    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    
    return inst
end

return Prefab("common/inventory/strongclaw", fn, assets, prefabs) 
