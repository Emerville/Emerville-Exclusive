local assets =
{ 
	Asset("ANIM", "anim/hmsword.zip"),
	Asset("ANIM", "anim/swap_hmsword.zip"), 

	Asset("ATLAS", "images/inventoryimages/hmsword.xml"),
	Asset("IMAGE", "images/inventoryimages/hmsword.tex"),
}

local function OnEquip(inst, owner) 
	owner.AnimState:OverrideSymbol("swap_object", "swap_hmsword", "swordfish")
	
	owner.AnimState:Show("ARM_carry") 
	owner.AnimState:Hide("ARM_normal") 
	owner.entity:AddLight()
    owner.Light:Enable(true)
    owner.Light:SetRadius(1)
    owner.Light:SetFalloff(1)
    owner.Light:SetIntensity(.5)
    owner.Light:SetColour(154/255, 223/255, 215/255)
end

local OnUnequip = function(inst, owner)
 
	owner.AnimState:Hide("ARM_carry") 
	owner.AnimState:Show("ARM_normal") 
	owner.Light:Enable(false)
end

--[[local function getspawnlocation(inst, target)
    local tarPos = target:GetPosition()
    local pos = inst:GetPosition()
    local vec = tarPos - pos
    vec = vec:Normalize()
    local dist = pos:Dist(tarPos)
    return pos + (vec * (dist * .15))
end]]--

local function OnHit(inst, owner, target)
	if target.components.combat then
		target.components.combat:GetAttacked(owner, 9001)
		--target.components.burnable:Ignite(true)
	--[[elseif target.components.workable and not target.prefab == "fireflies"  then
			target.components.workable:Destroy(owner)]]
	end
end

local function spawntornado(staff, target, pos)
	if not target.components.combat then
		return
	end

    local tornado = SpawnPrefab("bishop_charge")
    tornado.WINDSTAFF_CASTER = staff.components.inventoryitem.owner
    --local spawnPos = staff:GetPosition() + TheCamera:GetDownVec()
    --local totalRadius = target.Physics and target.Physics:GetRadius() or 0.5 + tornado.Physics:GetRadius() + 0.5
    --local targetPos = target:GetPosition() + (TheCamera:GetDownVec() * totalRadius)
	tornado:AddComponent("weapon")
--	tornado.components.weapon:SetDamage(9001)
    --tornado.components.weapon:SetRange(18, 24)
	tornado.Transform:SetPosition(staff.Transform:GetWorldPosition())
    --tornado.Transform:SetPosition(getspawnlocation(staff, target):Get())
    --tornado.components.knownlocations:RememberLocation("target", targetPos)
	tornado.components.projectile:Throw(staff, target, tornado.WINDSTAFF_CASTER)
	tornado.components.projectile:SetOnHitFn(OnHit)
    --staff.components.finiteuses:Use(2)
	staff.components.finiteuses:Use(2)
end

local function onattack(inst)
    inst.components.finiteuses:Use(1)
end

local function fn()
	local inst = CreateEntity()
	
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddLight()	
	inst.entity:AddNetwork()
	
	MakeInventoryPhysics(inst)
	
	inst.AnimState:SetBank("swordfish")
	inst.AnimState:SetBuild("hmsword")
	inst.AnimState:PlayAnimation("idle")
	
    inst.Light:Enable(true)
    inst.Light:SetRadius(1)
    inst.Light:SetFalloff(1)
    inst.Light:SetIntensity(.5)
    inst.Light:SetColour(154/255, 223/255, 215/255)
	
	inst:AddTag("sharp")
	
	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst:AddComponent("weapon")
	inst.components.weapon:SetDamage(9001)
	inst.components.weapon:SetOnAttack(onattack)
	--inst.components.weapon:SetRange(2, 3)
	
	inst:AddComponent("finiteuses")
	inst.components.finiteuses:SetMaxUses(400)
	inst.components.finiteuses:SetUses(400)
	inst.components.finiteuses:SetOnFinished(inst.Remove)
	
	inst:AddComponent("inspectable")
	
	--------------------------------
	inst:AddComponent("spellcaster")
    inst.components.spellcaster.canuseontargets = true
    inst.components.spellcaster.canusefrominventory = false
	inst.components.spellcaster.quickcast = true
	inst.components.spellcaster.canonlyuseonlocomotors = true
    -- The original was usable on things that had combat components and also on 
    -- things that were workable. Since spellcaster doesn't have a corresponding check, 
    -- for now I'm just letting it target everything. Note that the tornados don't actually 
    -- do anything to other types of objects.
    -- Liz
    --inst.components.spellcaster:SetSpellTestFn(cantornado)
    inst.components.spellcaster:SetSpellFn(spawntornado)
    inst.components.spellcaster.castingstate = "castspell_tornado"
    inst.components.spellcaster.actiontype = "SCIENCE"
	--
	
	--------------------------------end
	
	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "hmsword"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/hmsword.xml"
	
	inst:AddComponent("equippable")
	inst.components.equippable:SetOnEquip(OnEquip)
	inst.components.equippable:SetOnUnequip(OnUnequip)

	return inst
end

return	Prefab("common/inventory/hmsword", fn, assets)