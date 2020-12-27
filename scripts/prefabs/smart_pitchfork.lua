local GroundTiles = require("worldtiledefs")
local assets=
{
	Asset("ANIM", "anim/pitchfork.zip"),
	--Asset("ANIM", "anim/goldenpitchfork.zip"),
	Asset("ANIM", "anim/swap_pitchfork.zip"),
	--Asset("ANIM", "anim/swap_goldenpitchfork.zip"),
	Asset("IMAGE", "images/inventoryimages/smartpfp.tex"),
	Asset("ATLAS", "images/inventoryimages/smartpfp.xml"),
	    Asset("ANIM", "anim/smartpfp.zip"),
   Asset("ANIM", "anim/swap_smartpfp.zip"),
}
	
local function onfinished(inst)
	inst:Remove()
end

--[[local function SpawnTurf(turf, pt)
	if turf ~= nil then
		local loot = SpawnPrefab(turf)
		
		if loot.components.inventoryitem ~= nil then
			loot.components.inventoryitem:InheritMoisture(GLOBAL.TheWorld.state.wetness, GLOBAL.TheWorld.state.iswet)
		end
		
		loot.Transform:SetPosition(pt:Get())
		
		if loot.Physics ~= nil then
			local angle = math.random() * 2 * GLOBAL.PI
			loot.Physics:SetVel(2 * math.cos(angle), 10, 2 * math.sin(angle))
		end
	end
end--]]

local function pickup(inst, owner)
    local pt = owner:GetPosition()

	local world = TheWorld
    local map = world.Map
	local original_tile_type = map:GetTileAtPoint(pt:Get())
	local spawnturf = GroundTiles.turf[original_tile_type]
    if world.Map:CanTerraformAtPoint(pt:Get()) then

    inst.components.terraformer:Terraform(pt,spawnturf)
    inst.SoundEmitter:PlaySound("dontstarve/wilson/dig")
    inst.components.finiteuses:Use(0.25)
    else
    end	
end
local function onequip(inst, owner) 
    inst.task = inst:DoPeriodicTask(0.1, function() pickup(inst, owner) end)

	owner.AnimState:OverrideSymbol("swap_object", "swap_smartpfp", "swap_smartpfp")
    owner.AnimState:Show("ARM_carry") 
    owner.AnimState:Hide("ARM_normal") 
end
local function onunequip(inst, owner) 
    owner.AnimState:Hide("ARM_carry") 
    owner.AnimState:Show("ARM_normal") 
    if inst.task then inst.task:Cancel() inst.task = nil end
end
	
	
local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()
	MakeInventoryPhysics(inst)

	inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
	anim:SetBank("smartpfp")
	anim:SetBuild("smartpfp")
	anim:PlayAnimation("idle")
	inst.AnimState:SetMultColour(0/255,0/255,0/255,1)
	
	inst:AddTag("sharp")
	
	-------
	inst:AddComponent("finiteuses")
	inst.components.finiteuses:SetMaxUses(TUNING.PITCHFORK_USES)
	inst.components.finiteuses:SetUses(TUNING.PITCHFORK_USES)
	inst.components.finiteuses:SetOnFinished( onfinished) 
	inst.components.finiteuses:SetConsumption(ACTIONS.TERRAFORM, .125)
	-------
	
	inst:AddComponent("weapon")
	inst.components.weapon:SetDamage(TUNING.PITCHFORK_DAMAGE)
	
	inst:AddInherentAction(ACTIONS.TERRAFORM)
	
	inst:AddComponent("inspectable")
	
	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/inventoryimages/smartpfp.xml"
	inst.components.inventoryitem.imagename = "smartpfp"
	
	inst:AddComponent("terraformer")

	inst:AddComponent("equippable")
	inst.components.equippable:SetOnEquip( onequip )
	inst.components.equippable:SetOnUnequip( onunequip )
	
	
	
	return inst
end



return Prefab( "common/inventory/smart_pitchfork", fn, assets) --,
	   

