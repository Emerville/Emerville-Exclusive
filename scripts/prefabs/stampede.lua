local assets =
{ 
	Asset("ANIM", "anim/stampede.zip"),
	Asset("ANIM", "anim/swap_stampede.zip"), 

	Asset("ATLAS", "images/inventoryimages/stampede.xml"),
	Asset("IMAGE", "images/inventoryimages/stampede.tex"),
}

local prefabs =
{
	"groundpound_fx",
	"groundpoundring_fx",
	"collapse_small",
}

local function onfinished(inst)
    inst:Remove()
end

--local hound

local function OnEquip(inst, owner) 
	owner.AnimState:OverrideSymbol("swap_object", "swap_stampede", "swap_stampede")
	owner.AnimState:Show("ARM_carry") 
	owner.AnimState:Hide("ARM_normal") 
	owner.entity:AddLight()
	owner.components.combat:SetAttackPeriod(.2)
	owner:AddComponent("groundpounder")
	owner.components.groundpounder.destroyer = true
	owner.components.groundpounder.damageRings = 30
	owner.components.groundpounder.destructionRings = 0
	owner.components.groundpounder.numRings = 3
	owner.components.groundpounder.groundpounddamagemult = 2.5
	owner.components.groundpounder.noTags = { "FX", "NOCLICK", "DECOR", "INLIMBO", "player", "companion", "abigail", "shadowminion" }
	--[[owner:AddTag("hound")
	hound = SpawnPrefab("hound")
	hound:RemoveComponent("sanityaura")
	hound:RemoveComponent("lootdropper")
	if not hound.components.follower then hound:AddComponent("follower") end
	hound:AddTag("companion")
	hound.components.follower:SetLeader(owner)
	hound.components.combat:SetRetargetFunction(3, nil)
	hound.components.health:SetMaxHealth(TUNING.HOUND_HEALTH*3)
	hound.Transform:SetPosition(owner.Transform:GetWorldPosition())]]
end

local OnUnequip = function(inst, owner) 
	owner.AnimState:Hide("ARM_carry") 
	owner.AnimState:Show("ARM_normal") 
	owner:RemoveComponent("groundpounder")
	owner.components.combat:SetAttackPeriod(.1)
	--[[owner:RemoveTag("hound")
	
	local cloud = SpawnPrefab("poopcloud")
    if cloud and not hound.components.health:IsDead() then
        cloud.Transform:SetPosition(hound.Transform:GetWorldPosition())
    end
	hound:Remove()]]
end

local function stomp(staff)
    local staff_user = staff.components.inventoryitem.owner
	local pos = Vector3(staff_user.Transform:GetWorldPosition())
	staff_user.components.groundpounder:GroundPound(pos)
	--[[local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, 12)
            if #ents > 0 then
                    for i, v2 in ipairs(ents) do
                        if v2 ~= staff_user and
							not v2:HasTag("player") and
                            v2:IsValid() and
                            v2.components.health ~= nil and
                            not v2.components.health:IsDead() and 
                            staff_user.components.combat:CanTarget(v2) then
                            --staff_user.components.combat:DoAttack(v2, nil, nil, nil, 2.5)
							v2.components.combat:GetAttacked(staff_user, 200)
							--v2.AnimState:SetMultColour(.2,1,.2,1)
                        end
                    end
            end]]
	staff.components.finiteuses:Use(10)
end

local function onattack(inst)
    inst.components.finiteuses:Use(1)
end

local function fn()
	local inst = CreateEntity()
	
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()
	
	MakeInventoryPhysics(inst)
	
	inst.AnimState:SetBank("stampede")
    inst.AnimState:SetBuild("stampede")
    inst.AnimState:PlayAnimation("idle")
	
	inst:AddTag("sharp")
	
	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst:AddComponent("weapon")
	inst.components.weapon:SetDamage(68)
	inst.components.weapon:SetOnAttack(onattack)
	inst.components.weapon:SetRange(1, 9001)
	
	inst:AddComponent("inspectable")
	
	inst:AddComponent("spellcaster")
    inst.components.spellcaster:SetSpellFn(stomp)
    inst.components.spellcaster.canuseontargets = false
	inst.components.spellcaster.canusefrominventory = false
	inst.components.spellcaster.quickcast = true
	inst.components.spellcaster.canuseonpoint = true
	inst.components.spellcaster.castingstate = "castspell_tornado"
	
	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "stampede"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/stampede.xml"
	
	inst:AddComponent("equippable")
	inst.components.equippable:SetOnEquip(OnEquip)
	inst.components.equippable:SetOnUnequip(OnUnequip)
	
    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(400)
    inst.components.finiteuses:SetUses(400)
    inst.components.finiteuses:SetOnFinished(onfinished)

	return inst
end

return	Prefab("common/inventory/stampede", fn, assets)
