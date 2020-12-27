local assets =
{
	Asset("ANIM", "anim/armor_tungsten.zip"),
	
	Asset("ATLAS", "images/inventoryimages/armor_tungsten.xml"),
    Asset("IMAGE", "images/inventoryimages/armor_tungsten.tex"),	
}

local prefabs = 
{
	"groundpoundring_fx",
}

local function freezeproc(owner)
 	local x, y, z = owner.Transform:GetWorldPosition()
	local fx = SpawnPrefab("groundpoundring_fx")
	fx.Transform:SetPosition(x, y, z)

	
	local x,y,z = owner.Transform:GetWorldPosition()
            local ents = TheSim:FindEntities(x,y,z, 5, {"freezable"}, {"FX", "NOCLICK", "DECOR","INLIMBO"}) 
            for i,v in pairs(ents) do
             if v and v.components.freezable then
			 if v:HasTag("player") then
			 
               else
                v.components.freezable:Freeze(0.1)
                v.components.freezable:SpawnShatterFX()
				v.components.freezable.coldness = 1.5
				v.components.freezable.wearofftime = 5
				v.components.health:DoDelta(-20)
				v:PushEvent("onthaw")
            end
        end
    end
end

local summonchance = 0.33
local function OnBlocked(owner, data) 
    owner.SoundEmitter:PlaySound("dontstarve/wilson/hit_armour")
	if math.random() < summonchance then
	freezeproc(owner)
   end
end

local function onequip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_body", "armor_tungsten", "swap_body")
    inst:ListenForEvent("blocked", OnBlocked, owner)
    inst:ListenForEvent("attacked", OnBlocked, owner)	

end

local function onunequip(inst, owner) 
    owner.AnimState:ClearOverrideSymbol("swap_body")
    inst:RemoveEventCallback("blocked", OnBlocked, owner)
	inst:RemoveEventCallback("attacked", OnBlocked, owner)
end

local function fn()
	local inst = CreateEntity()
    
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()	
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("armor_ruins")
    inst.AnimState:SetBuild("armor_tungsten")
    inst.AnimState:PlayAnimation("anim")

    inst:AddTag("ruins")	
    inst:AddTag("metal")

    inst.foleysound = "dontstarve/movement/foley/metalarmour"
	
    inst.entity:SetPristine()	
    
    if not TheWorld.ismastersim then
        return inst
    end
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "armor_tungsten"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/armor_tungsten.xml"
    
    inst:AddComponent("armor")
    inst.components.armor:InitCondition(1200, 0.9)
    
    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BODY
	inst.components.equippable.walkspeedmult = 0.9
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
	
    inst:AddComponent("insulator")
    inst.components.insulator:SetInsulation(TUNING.INSULATION_MED)
    inst.components.insulator:SetSummer()	
	
    MakeHauntableLaunch(inst)
    
    return inst
end

return Prefab("common/inventory/armor_tungsten", fn, assets)