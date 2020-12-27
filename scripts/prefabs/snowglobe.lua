local assets =
{
	-- Animation files used for the item.
	Asset("ANIM", "anim/snowglobe.zip"),
	Asset("ANIM", "anim/swap_snowglobe.zip"),

	-- Inventory image and atlas file used for the item.
    Asset("ATLAS", "images/inventoryimages/snowglobe.xml"),
    Asset("IMAGE", "images/inventoryimages/snowglobe.tex"),
}

local function onequip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_object", -- Symbol to override.
								   "swap_snowglobe", -- Animation bank we will use to overwrite the symbol.
								   "swap_snowglobe") -- Symbol to overwrite it with.
    owner.AnimState:Show("ARM_carry") 
    owner.AnimState:Hide("ARM_normal") 
end

local function onunequip(inst, owner) 
    owner.AnimState:Hide("ARM_carry") 
    owner.AnimState:Show("ARM_normal") 
end


local function resetmovespeed(inst)
	SpawnPrefab("small_puff").Transform:SetPosition(inst.Transform:GetWorldPosition())
	inst:DoTaskInTime(0.1, inst:Show())
	inst.components.locomotor.walkspeed = (4.5)
    inst.components.locomotor.runspeed = (6.5)
    inst.components.health:SetInvincible(false)
end

local function snowboom(staff)
    staff.components.fueled:DoDelta(-100)
	local caster = staff.components.inventoryitem.owner
	local pt = Vector3(caster.Transform:GetWorldPosition())
    local numcarrots = 3
	caster.components.locomotor.walkspeed = (0)
    caster.components.locomotor.runspeed = (0)	
	caster.components.health:SetInvincible(true)
    caster:Hide()
	SpawnPrefab("santasnowman").Transform:SetPosition(pt:Get())	
	SpawnPrefab("deer_ice_burst").Transform:SetPosition(pt:Get())
    SpawnPrefab("splash_snow_fx").Transform:SetPosition(pt:Get())
--Turn Off After Xmas	

            caster:StartThread(function()
                for k = 1, numcarrots do
                
                    local theta = math.random() * 2 * PI
                    local radius = math.random(1, 3)

                    -- we have to special case this one because birds can't land on creep
                    local result_offset = FindValidPositionByFan(theta, radius, 12, function(offset)
                        local pos = pt + offset
                        local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, 1)
                        return next(ents) == nil
                    end)

                    if result_offset ~= nil then
                        local pos = pt + result_offset
                        local carrot = SpawnPrefab("snowyball")

                        carrot.Transform:SetPosition(pos:Get())

                        ShakeAllCameras(CAMERASHAKE.FULL, .2, .02, .25, caster, 40)

                        --need a better effect
                        SpawnPrefab("ground_chunks_breaking").Transform:SetPosition(pos:Get())
                        --PlayFX((pt + result_offset), "splash", "splash_ocean", "idle")
                    end
			        Sleep(.33)
                end
             end)--Turn off After Xmas
	caster:DoTaskInTime(1.5, resetmovespeed)	
    return true
end	


local function SnowGlobeCanAcceptFuelItem(self, item)
if item ~= nil and item.components.fuel ~= nil and (item.components.fuel.fueltype == FUELTYPE.BLUEGEM or item.prefab == "bluegem") then
		return true
	else
		return false
	end
end 
 
local function SnowGlobeTakeFuel(self, item) 
if self:CanAcceptFuelItem(item) then
	if item.prefab =="bluegem" then
		self:DoDelta(1000)
		self.inst.SoundEmitter:PlaySound("dontstarve/common/ancienttable_craft", "sound")
	end
        item:Remove()
        return true
    end
end

local function init()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()	

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("snowglobe")
    inst.AnimState:SetBuild("snowglobe")
    inst.AnimState:PlayAnimation("snowglobe")

    inst:AddTag("staff")
	inst:AddTag("nopunch")

	inst.entity:SetPristine()
	
    if not TheWorld.ismastersim then
		return inst
	end

    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "snowglobe"	
    inst.components.inventoryitem.atlasname = "images/inventoryimages/snowglobe.xml"
    
    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

	inst:AddComponent("spellcaster")
    inst.components.spellcaster:SetSpellFn(snowboom)
    inst.components.spellcaster.canuseontargets = false
	inst.components.spellcaster.canusefrominventory = true
	inst.components.spellcaster.canuseonpoint = true
	
	inst:AddComponent("fueled")
	inst.components.fueled.accepting = true --false 
	inst.components.fueled.fueltype = FUELTYPE.BLUEGEM	
	inst.components.fueled:InitializeFuelLevel(1000)
	inst.components.fueled.CanAcceptFuelItem = SnowGlobeCanAcceptFuelItem
	inst.components.fueled.TakeFuelItem = SnowGlobeTakeFuel
	
	inst:DoPeriodicTask(1/10, function() 
	-- Don't take fuel if magazine is full!
	if inst.components.fueled.maxfuel == inst.components.fueled.currentfuel and inst.components.fueled.accepting == true then
	inst.components.fueled.accepting = false
	end
	-- Take fuel if magazine size is bigger than bullet count!
	if inst.components.fueled.maxfuel > inst.components.fueled.currentfuel and inst.components.fueled.accepting == false then
	inst.components.fueled.accepting = true
	end
	
	-- If snowglobe was emptied and refueled, restore its abilities!
	if not inst.components.fueled:IsEmpty() and inst:HasTag("emptysnowglobe") then
	inst.components.spellcaster.canuseonpoint = true
	inst.components.spellcaster.canusefrominventory = true
	
	inst:RemoveTag("emptysnowglobe")
	end
	
	-- Empty? No shooting
	if inst.components.fueled:IsEmpty() then
	
	if not inst:HasTag("emptysnowglobe") then
	inst:AddTag("emptysnowglobe")
	end

	inst.components.spellcaster.canuseonpoint = false
	inst.components.spellcaster.canusefrominventory = false	
	
	end
	end)	
		
    MakeHauntableLaunch(inst)	
    
    return inst
end

return Prefab("common/inventory/snowglobe", init, assets)