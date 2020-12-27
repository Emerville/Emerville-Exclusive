local assets =
{
	Asset("ANIM", "anim/eternal_torch.zip"),
	Asset("ANIM", "anim/swap_eternal_torch.zip"),
	Asset("SOUND", "sound/common.fsb"),
	
	Asset("ATLAS", "images/inventoryimages/eternal_torch.xml"),	
    Asset("IMAGE", "images/inventoryimages/eternal_torch.tex"),	
}
 
local prefabs =
{
	"eternaltorchfire",
}    

local function onequip(inst, owner) 
    --owner.components.combat.damage = TUNING.PICK_DAMAGE 
    inst.components.burnable:Ignite()
    owner.AnimState:OverrideSymbol("swap_object", "swap_eternal_torch", "swap_torch")
    owner.AnimState:Show("ARM_carry") 
    owner.AnimState:Hide("ARM_normal") 
    
    inst.SoundEmitter:PlaySound("dontstarve/wilson/torch_LP", "torch")
    inst.SoundEmitter:PlaySound("dontstarve/wilson/torch_swing")
    inst.SoundEmitter:SetParameter( "torch", "intensity", 1 )

    inst.fire = SpawnPrefab( "eternaltorchfire" )
    local follower = inst.fire.entity:AddFollower()
    follower:FollowSymbol( owner.GUID, "swap_object", 0, -110, 1 )   
end

local function onunequip(inst,owner) 
	inst.fire:Remove()
    inst.fire = nil
    
    inst.components.burnable:Extinguish()
    owner.AnimState:Hide("ARM_carry") 
    owner.AnimState:Show("ARM_normal")
    inst.SoundEmitter:KillSound("torch")
    inst.SoundEmitter:PlaySound("dontstarve/common/fireOut")        
end

local function onpocket(inst, owner)
    inst.components.burnable:Extinguish()
end

local function onattack(weapon, attacker, target)
    if target ~= nil and target.components.burnable ~= nil and math.random() < TUNING.TORCH_ATTACK_IGNITE_PERCENT * target.components.burnable.flammability then
        target.components.burnable:Ignite(nil, attacker)
    end
end

local function fn()
	local inst = CreateEntity()
	
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()
	
    MakeInventoryPhysics(inst)	
 
    inst.AnimState:SetBank("torch")
    inst.AnimState:SetBuild("eternal_torch")
    inst.AnimState:PlayAnimation("planted")	
	
    inst.entity:SetPristine()	
	
    if not TheWorld.ismastersim then
        return inst
    end		

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.TORCH_DAMAGE)
    inst.components.weapon:SetOnAttack(onattack)

    -----------------------------------
    inst:AddComponent("lighter")	
    -----------------------------------
    
    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "eternal_torch"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/eternal_torch.xml"
    -----------------------------------
    
    inst:AddComponent("equippable")
    inst.components.equippable:SetOnPocket(onpocket)    
    inst.components.equippable:SetOnEquip(onequip)    
    inst.components.equippable:SetOnUnequip(onunequip)
    
    -----------------------------------
    
    inst:AddComponent("inspectable")
 
    -----------------------------------
    
    inst:AddComponent("burnable")
    inst.components.burnable.canlight = false
    inst.components.burnable.fxprefab = nil

    ----------------------------------- 

    MakeHauntableLaunch(inst)	
	
    return inst   
end  
 
return Prefab("common/inventory/eternal_torch", fn, assets, prefabs) 