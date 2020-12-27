local assets =
{
	-- Sound files used by the item.
	Asset("SOUNDPACKAGE", "sound/fryingpan.fev"),
	Asset("SOUND", "sound/fryingpan.fsb"),

	-- Animation files used for the item.
	Asset("ANIM", "anim/pan.zip"),
	Asset("ANIM", "anim/swap_pan.zip"),

	-- Inventory image and atlas file used for the item.
    Asset("ATLAS", "images/inventoryimages/fryingpan.xml"),
    Asset("IMAGE", "images/inventoryimages/fryingpan.tex"),
}

local chance = 0.15 --% Chance to spawn food. Maybe revert to 7% if needed.

local function OnAttack(inst, owner, target)
	inst.SoundEmitter:PlaySound("fryingpan/fryingpan/fryingpan") --Play Frying Pan Sound
	if math.random() < chance then --Chance to spawn a food.
		if owner.components.health and not target:HasTag("wall") or target:HasTag("chester") then
			local foodchance = math.random(1,3)
			if foodchance == 1 then
			inst.SoundEmitter:PlaySound("dontstarve/common/cookingpot_finish")
			SpawnPrefab("kabobs").Transform:SetPosition(target:GetPosition():Get()) 
			elseif foodchance == 2 then
			inst.SoundEmitter:PlaySound("dontstarve/common/cookingpot_finish")
			SpawnPrefab("meatballs").Transform:SetPosition(target:GetPosition():Get()) 
			elseif foodchance == 3 then
			inst.SoundEmitter:PlaySound("dontstarve/common/cookingpot_finish")
			SpawnPrefab("baconeggs").Transform:SetPosition(target:GetPosition():Get())
			end
		end
	end
end

local function onequip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_object", -- Symbol to override.
    	"swap_pan", -- Animation bank we will use to overwrite the symbol.
    	"swap_pan") -- Symbol to overwrite it with.
    owner.AnimState:Show("ARM_carry") 
    owner.AnimState:Hide("ARM_normal") 
end

local function onunequip(inst, owner) 
    owner.AnimState:Hide("ARM_carry") 
    owner.AnimState:Show("ARM_normal") 
end

local function oncook(inst, product, chef)
    inst.components.finiteuses:Use(2)
end

local function init()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()	

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("pan")
    inst.AnimState:SetBuild("pan")
    inst.AnimState:PlayAnimation("pan")

	inst:AddTag("cooker")
	
	inst.entity:SetPristine()
	
    if not TheWorld.ismastersim then
        return inst
    end
	
    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(51)
	inst.components.weapon.onattack = OnAttack
	
	inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(100)
    inst.components.finiteuses:SetUses(100)	
	inst.components.finiteuses:SetOnFinished(inst.Remove)	

    inst:AddComponent("inspectable")
    
	inst:AddComponent("cooker")
    inst.components.cooker.oncookfn = oncook
	
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "fryingpan"	
    inst.components.inventoryitem.atlasname = "images/inventoryimages/fryingpan.xml"
    
    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
	
    MakeHauntableLaunch(inst)	
    
    return inst
end

return Prefab("common/inventory/fryingpan", init, assets)