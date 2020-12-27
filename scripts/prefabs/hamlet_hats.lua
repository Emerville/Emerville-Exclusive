local function MakeHat(name, tag)
	local fname = "hat_"..name
	local symname = name.."hat"
	local prefabname = symname	
	local texture = symname..".tex"
	local assets = 
	{ 
	Asset("ANIM", "anim/"..fname..".zip"), 
	Asset("ANIM", "anim/hat_antmask.zip"),
	Asset("ANIM", "anim/hat_bandit.zip"),
	Asset("ANIM", "anim/hat_candle.zip"),
	Asset("ANIM", "anim/hat_candle_empty.zip"),
	Asset("ANIM", "anim/hat_disguise.zip"),
	Asset("ANIM", "anim/hat_gasmask.zip"),
	Asset("ANIM", "anim/hat_metalplate.zip"),
	Asset("ANIM", "anim/hat_peagawkfeather.zip"),
	Asset("ANIM", "anim/hat_pigcrown.zip"),
	Asset("ANIM", "anim/hat_pith.zip"),
	Asset("ANIM", "anim/hat_thunder.zip"),
	Asset("ANIM", "anim/hat_bat.zip"),	
	
	Asset("IMAGE", "images/inventoryimages/hamlet_hats.tex"), 
	Asset("ATLAS", "images/inventoryimages/hamlet_hats.xml"),
	}
	
	local function generic_perish(inst)
		inst:Remove()
	end
	
	local function onequip(inst, owner, symbol_override)
        local skin_build = inst:GetSkinBuild()
        if skin_build ~= nil then
            owner:PushEvent("equipskinneditem", inst:GetSkinName())
            owner.AnimState:OverrideItemSkinSymbol("swap_hat", skin_build, symbol_override or "swap_hat", inst.GUID, fname)
        else
            owner.AnimState:OverrideSymbol("swap_hat", fname, symbol_override or "swap_hat")
        end
        owner.AnimState:Show("HAT")
        owner.AnimState:Show("HAIR_HAT")
        owner.AnimState:Hide("HAIR_NOHAT")
        owner.AnimState:Hide("HAIR")

        if owner:HasTag("player") then
            owner.AnimState:Hide("HEAD")
            owner.AnimState:Show("HEAD_HAT")
        end

        if inst.components.fueled ~= nil then
            inst.components.fueled:StartConsuming()
        end
    end

    local function onunequip(inst, owner)
        local skin_build = inst:GetSkinBuild()
        if skin_build ~= nil then
            owner:PushEvent("unequipskinneditem", inst:GetSkinName())
        end

        owner.AnimState:ClearOverrideSymbol("swap_hat")
        owner.AnimState:Hide("HAT")
        owner.AnimState:Hide("HAIR_HAT")
        owner.AnimState:Show("HAIR_NOHAT")
        owner.AnimState:Show("HAIR")

        if owner:HasTag("player") then
            owner.AnimState:Show("HEAD")
            owner.AnimState:Hide("HEAD_HAT")
        end

        if inst.components.fueled ~= nil then
            inst.components.fueled:StopConsuming()
        end
    end

	local function opentop_onequip(inst, owner)
        local skin_build = inst:GetSkinBuild()
        if skin_build ~= nil then
            owner:PushEvent("equipskinneditem", inst:GetSkinName())
            owner.AnimState:OverrideItemSkinSymbol("swap_hat", skin_build, "swap_hat", inst.GUID, fname)
        else
            owner.AnimState:OverrideSymbol("swap_hat", fname, "swap_hat")
        end

        owner.AnimState:Show("HAT")
        owner.AnimState:Hide("HAIR_HAT")
        owner.AnimState:Show("HAIR_NOHAT")
        owner.AnimState:Show("HAIR")

        owner.AnimState:Show("HEAD")
        owner.AnimState:Hide("HEAD_HAT")

        if inst.components.fueled ~= nil then
            inst.components.fueled:StartConsuming()
        end
    end
	
	local function band_disable(inst)
    if inst.updatetask then
        inst.updatetask:Cancel()
        inst.updatetask = nil
    end
    --local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
    --owner.components.leader:RemoveFollowersByTag("pig")
end

local function generic_perish(inst)
	inst:Remove()
end

local banddt = 1
local function band_update( inst )
    local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
    if owner and owner.components.leader then
        local x,y,z = owner.Transform:GetWorldPosition()
        local ents = TheSim:FindEntities(x,y,z, TUNING.ONEMANBAND_RANGE, {"pig"}, {'werepig'})
        for k,v in pairs(ents) do
            if v.components.follower and not v.components.follower.leader  and not owner.components.leader:IsFollower(v) and not owner:HasTag("monster") and owner.components.leader.numfollowers < 10 then
                owner.components.leader:AddFollower(v)
                --owner.components.sanity:DoDelta(-TUNING.SANITY_MED)
            end
        end

        for k,v in pairs(owner.components.leader.followers) do
            if k:HasTag("pig") and k.components.follower then
                k.components.follower:AddLoyaltyTime(3)
            end
        end
    end
end

local function band_enable(inst)
    inst.updatetask = inst:DoPeriodicTask(banddt, band_update, 1)
end

local function band_perish(inst)
    band_disable(inst)
    inst:Remove()
end
	
  local function hamlet_simple(custom_init)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank(symname)
    inst.AnimState:SetBuild(fname)
    inst.AnimState:PlayAnimation("anim")

    inst:AddTag("hat")

    if custom_init ~= nil then
      custom_init(inst)
    end
	
	return inst
  end

  local function hamlet_master(inst)
		inst:AddComponent("inspectable")

   		inst:AddComponent("inventoryitem")
    	inst.components.inventoryitem.atlasname = "images/inventoryimages/hamlet_hats.xml"
    	inst.components.inventoryitem:ChangeImageName(symname)

    	inst:AddComponent("tradable")

    	inst:AddComponent("equippable")
    	inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
    	inst.components.equippable:SetOnEquip(onequip)
    	inst.components.equippable:SetOnUnequip(onunequip)

    MakeHauntableLaunch(inst)
	return inst
end
  
  local function metalplate()
		local inst = hamlet_simple()
		
		inst.AnimState:SetBank("metalplatehat")
		inst.AnimState:SetBuild("hat_metalplate")
		inst.AnimState:PlayAnimation("anim")
		
		inst.entity:SetPristine()
		
		if not TheWorld.ismastersim then
            return inst
        end
		
		hamlet_master(inst)
		
		inst:AddComponent("armor")
		inst:AddComponent("waterproofer")
		
		inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
		inst.components.equippable.walkspeedmult = 0.7
		inst.components.equippable:SetOnEquip(onequip)
		inst.components.equippable:SetOnUnequip(onunequip)
		
		inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)

		inst.components.armor:InitCondition(TUNING.ARMORMARBLE, TUNING.ARMORMARBLE_ABSORPTION)
		MakeHauntableLaunch(inst)
		return inst
	end
	
   local function candle_turnon(inst)
        local owner = inst.components.inventoryitem ~= nil and inst.components.inventoryitem.owner or nil
        if not inst.components.fueled:IsEmpty() then
            inst.components.fueled:StartConsuming()		
            if inst._light == nil or not inst._light:IsValid() then
                inst._light = SpawnPrefab("minerhatlight")
            end
            if owner ~= nil then
                onequip(inst, owner)
                inst._light.entity:SetParent(owner.entity)
            end
            local soundemitter = owner ~= nil and owner.SoundEmitter or inst.SoundEmitter
            soundemitter:PlaySound("dontstarve/common/minerhatAddFuel")			
		    inst.SoundEmitter:PlaySound("dontstarve/wilson/torch_LP", "torch")
	        inst.SoundEmitter:SetParameter( "torch", "intensity", 1 )
			
	        if inst.fire == nil then
	            inst.fire = SpawnPrefab("torchfire")
				-- inst.fire.Transform:SetScale(15, 15, 15)
	            inst.fire.entity:AddFollower()
	            inst.fire.Follower:FollowSymbol(owner.GUID, "swap_hat", -20, -250, 0 )
	        end 			
			
        elseif owner ~= nil then
            onequip(inst, owner)
        end
    end
	
	local function candle_turnoff(inst, ranout)
        local owner = inst.components.inventoryitem ~= nil and inst.components.inventoryitem.owner or nil
        if owner ~= nil and inst.components.equippable ~= nil and inst.components.equippable:IsEquipped() then
            onequip(inst, owner)
        end
        inst.components.fueled:StopConsuming()
		
        if inst._light ~= nil then
            if inst._light:IsValid() then
                inst._light:Remove()
            end
            inst._light = nil
            local soundemitter = owner ~= nil and owner.SoundEmitter or inst.SoundEmitter
			inst.SoundEmitter:KillSound("torch")
			inst.SoundEmitter:PlaySound("dontstarve/common/fireOut")			
			
			if inst.fire ~= nil then
				inst.fire:Remove()
				inst.fire = nil
			end 	
		end
	end
	
	local function candle_equip(inst, owner)
		candle_turnon(inst)
	end	
	
	local function candle_unequip(inst, owner)
		onunequip(inst, owner)
		candle_turnoff(inst)
	end
	
	local function candle_perish(inst)
		local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
		if owner then
			owner:PushEvent("torchranout", {torch = inst})
		end
		candle_turnoff(inst)
    end
		
	local function candle_takefuel(inst)
        if inst.components.equippable ~= nil and inst.components.equippable:IsEquipped() then			
			candle_turnon(inst)
		end
	end
	
    local function candle_onremove(inst)
        if inst._light ~= nil and inst._light:IsValid() then
            inst._light:Remove()
        end
    end	

	local function candle()
		local inst = hamlet_simple()
		inst.entity:AddSoundEmitter()        
		
		inst.AnimState:SetBank("candlehat")
		inst.AnimState:SetBuild("hat_candle")
		inst.AnimState:PlayAnimation("anim")
		
		inst.entity:SetPristine()
		
		if not TheWorld.ismastersim then
            return inst
        end
		
		hamlet_master(inst)
		
		inst.components.inventoryitem:SetOnDroppedFn(candle_turnoff)
		
		inst.components.equippable.equipslot = EQUIPSLOTS.HEAD		
		inst.components.equippable:SetOnEquip(candle_equip)
		inst.components.equippable:SetOnUnequip(candle_unequip)

		inst:AddComponent("fueled")
		inst.components.fueled.fueltype = "CAVE"
		inst.components.fueled:InitializeFuelLevel(TUNING.MINERHAT_LIGHTTIME)
		inst.components.fueled:SetDepletedFn(candle_perish)
		inst.components.fueled.ontakefuelfn = candle_takefuel
        inst.components.fueled:SetFirstPeriod(TUNING.TURNON_FUELED_CONSUMPTION, TUNING.TURNON_FULL_FUELED_CONSUMPTION)	
		inst.components.fueled.accepting = true
		
		inst:AddComponent("waterproofer")
		inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)

        inst._light = nil
        inst.OnRemoveEntity = candle_onremove		
		
		MakeHauntableLaunch(inst)
		return inst
	end
	
	local function bandit()
		local inst = hamlet_simple()
		
		inst.AnimState:SetBank("bandithat")
		inst.AnimState:SetBuild("hat_bandit")
		inst.AnimState:PlayAnimation("anim")
		
		inst.entity:SetPristine()
		
		if not TheWorld.ismastersim then
            return inst
        end
		
		hamlet_master(inst)
		
		inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
		inst.components.equippable.dapperness = TUNING.DAPPERNESS_SMALL
		inst.components.equippable:SetOnEquip(onequip)
		inst.components.equippable:SetOnUnequip(onunequip)

		inst:AddComponent("fueled")
		inst.components.fueled.fueltype = "USAGE"
		inst.components.fueled:InitializeFuelLevel(TUNING.WALRUSHAT_PERISHTIME)
		inst.components.fueled:SetDepletedFn(generic_perish)
		
		inst.components.equippable.walkspeedmult = TUNING.CANE_SPEED_MULT
		-- inst:AddTag("notarget")
		
		MakeHauntableLaunch(inst)
		return inst
	end
	
	local function pith()
		local inst = hamlet_simple()
		
		inst.AnimState:SetBank("pithhat")
		inst.AnimState:SetBuild("hat_pith")
		inst.AnimState:PlayAnimation("anim")
		
		inst.entity:SetPristine()
		
		if not TheWorld.ismastersim then
            return inst
        end
		
		hamlet_master(inst)
		
		inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
		inst.components.equippable.dapperness = TUNING.DAPPERNESS_SMALL
		inst.components.equippable:SetOnEquip(onequip)
		inst.components.equippable:SetOnUnequip(onunequip)
		
		inst:AddComponent("fueled")
		inst.components.fueled.fueltype = "USAGE"
        inst.components.fueled:InitializeFuelLevel(TUNING.RAINHAT_PERISHTIME)
		inst.components.fueled:SetDepletedFn(generic_perish)

		inst:AddComponent("waterproofer")
		inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_LARGE)

        inst.components.equippable.insulated = true	
			
		MakeHauntableLaunch(inst)
		return inst
	end
	
	local function gasmask()
		local inst = hamlet_simple()
		
		inst.AnimState:SetBank("gasmaskhat")
		inst.AnimState:SetBuild("hat_gasmask")
		inst.AnimState:PlayAnimation("anim")
		
		inst.entity:SetPristine()
		
		if not TheWorld.ismastersim then
            return inst
        end
		
		hamlet_master(inst)
		
		inst:AddTag("gasmask")
		inst:AddTag("goggles")
		
		inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
        inst.components.equippable.dapperness = TUNING.DAPPERNESS_MED
		inst.components.equippable:SetOnEquip(onequip)
		inst.components.equippable:SetOnUnequip(onunequip)

		inst:AddComponent("fueled")
		inst.components.fueled.fueltype = "USAGE"
        inst.components.fueled:InitializeFuelLevel(TUNING.GOGGLES_PERISHTIME)
		inst.components.fueled:SetDepletedFn(generic_perish)		

        inst:AddComponent("waterproofer")
        inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)	
		
		MakeHauntableLaunch(inst)
		return inst
	end

	local function pigcrown()
		local inst = hamlet_simple()

		inst.AnimState:SetBank("pigcrownhat")
		inst.AnimState:SetBuild("hat_pigcrown")
		inst.AnimState:PlayAnimation("anim")
		
		inst.entity:SetPristine()
		
		if not TheWorld.ismastersim then
            return inst
        end
		
		hamlet_master(inst)
		
		inst:AddTag("pigcrown")
		inst:AddTag("regal")
		--inst:AddTag("band")
		
		inst:AddComponent("fueled")
		inst.components.fueled.fueltype = "USAGE"
		inst.components.fueled:InitializeFuelLevel(TUNING.WALRUSHAT_PERISHTIME)
		inst.components.fueled:SetDepletedFn(inst.Remove)			
		
		inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
		inst.components.equippable.dapperness = TUNING.DAPPERNESS_LARGE			
		inst.components.equippable:SetOnEquip(opentop_onequip)
		inst.components.equippable:SetOnUnequip(onunequip)
	
	    inst:AddComponent("insulator")
		inst.components.insulator:SetInsulation(TUNING.INSULATION_MED)

		MakeHauntableLaunch(inst)
		return inst
	end
	
	local function antmask()
		local inst = hamlet_simple()
		
		inst.AnimState:SetBank("antmaskhat")
		inst.AnimState:SetBuild("hat_antmask")
		inst.AnimState:PlayAnimation("anim")
		
		inst.entity:SetPristine()
		
		if not TheWorld.ismastersim then
            return inst
        end
		
		hamlet_master(inst)
		
		inst:AddComponent("armor")
		inst.components.armor:InitCondition(TUNING.ARMOR_FOOTBALLHAT, TUNING.ARMOR_FOOTBALLHAT_ABSORPTION)
	
		inst:AddTag("antmask")
		
		inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
		inst.components.equippable:SetOnEquip(onequip)
		inst.components.equippable:SetOnUnequip(onunequip)
		
		MakeHauntableLaunch(inst)
		return inst
	end
	
	local function peagawkfeather_equip(inst, owner)
        onequip(inst, owner)
        local attractor = owner.components.birdattractor
        if attractor then
            attractor.spawnmodifier:SetModifier(inst, TUNING.BIRD_SPAWN_MAXDELTA_FEATHERHAT, "maxbirds")
            attractor.spawnmodifier:SetModifier(inst, TUNING.BIRD_SPAWN_DELAYDELTA_FEATHERHAT.MIN, "mindelay")
            attractor.spawnmodifier:SetModifier(inst, TUNING.BIRD_SPAWN_DELAYDELTA_FEATHERHAT.MAX, "maxdelay")
            
            local birdspawner = TheWorld.components.birdspawner
            if birdspawner ~= nil then
                birdspawner:ToggleUpdate(true)
            end
        end
    end

    local function peagawkfeather_unequip(inst, owner)
        onunequip(inst, owner)

        local attractor = owner.components.birdattractor
        if attractor then
            attractor.spawnmodifier:RemoveModifier(inst)

            local birdspawner = TheWorld.components.birdspawner
            if birdspawner ~= nil then
                birdspawner:ToggleUpdate(true)
            end
        end
    end
	
	local function peagawkfeather()
		local inst = hamlet_simple()
		
		inst.AnimState:SetBank("peagawkfeatherhat")
		inst.AnimState:SetBuild("hat_peagawkfeather")
		inst.AnimState:PlayAnimation("anim")
		
		inst.entity:SetPristine()
		
		if not TheWorld.ismastersim then
            return inst
        end
		
		hamlet_master(inst)
		
		inst:AddComponent("fueled")
		inst.components.fueled.fueltype = "USAGE"
		inst.components.fueled:InitializeFuelLevel(TUNING.WALRUSHAT_PERISHTIME)
		inst.components.fueled:SetDepletedFn(generic_perish)
		
		inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
		inst.components.equippable.dapperness = TUNING.DAPPERNESS_LARGE
		inst.components.equippable:SetOnEquip(peagawkfeather_equip)
		inst.components.equippable:SetOnUnequip(peagawkfeather_unequip)
		
		MakeHauntableLaunch(inst)
		return inst
	end
	
	local function thunder_equip(inst, owner)
		onequip(inst, owner)
		inst:AddTag("lightningrod")
		inst.lightningpriority = 5
	end

	local function thunder_unequip(inst, owner)
		onunequip(inst, owner)
		inst:RemoveTag("lightningrod")
		inst.lightningpriority = nil
	end

	local function thunder()
		local inst = hamlet_simple()
		
		inst.AnimState:SetBank("thunderhat")
		inst.AnimState:SetBuild("hat_thunder")
		inst.AnimState:PlayAnimation("anim")
		
		inst.entity:SetPristine()
		
		if not TheWorld.ismastersim then
            return inst
        end
		
		hamlet_master(inst)
		
		inst:AddComponent("fueled")
		inst.components.fueled.fueltype = "USAGE"
		inst.components.fueled:InitializeFuelLevel(TUNING.WALRUSHAT_PERISHTIME)
		inst.components.fueled:SetDepletedFn(generic_perish)
		
		inst.components.equippable:SetOnEquip(thunder_equip)
		inst.components.equippable:SetOnUnequip(thunder_unequip)
		
		inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
		inst.components.equippable.dapperness = TUNING.DAPPERNESS_SMALL

		inst:ListenForEvent("lightningstrike", function(inst, data) inst.components.fueled:DoDelta(-inst.components.fueled.maxfuel * 0.1) end)
		
		MakeHauntableLaunch(inst)
		return inst
	end
	
	local function disguise_equip(inst, owner)
		opentop_onequip(inst, owner)
		if owner:HasTag("spiderwhisperer") then
		owner:RemoveTag("monster")
		owner:AddTag("premonster")
		end
	end
	
	local function disguise_onunequip(inst, owner)
		onunequip(inst, owner)
		if owner:HasTag("spiderwhisperer") then
		owner:AddTag("monster")
		owner:RemoveTag("premonster")
		end
	end
	
	local function disguise()
		local inst = hamlet_simple()
		
		inst.AnimState:SetBank("disguise")
		inst.AnimState:SetBuild("hat_disguise")
		inst.AnimState:PlayAnimation("anim")
		
		inst.entity:SetPristine()
		
		if not TheWorld.ismastersim then
            return inst
        end
		
		hamlet_master(inst)
		
		inst:AddTag("pigman")
		
		inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
		inst.components.equippable:SetOnEquip(disguise_equip)
		inst.components.equippable:SetOnUnequip(disguise_onunequip)
		
		MakeHauntableLaunch(inst)
		return inst
	end
	
	local function bat_turnon(owner)
        owner.SoundEmitter:PlaySound("dontstarve_DLC001/common/moggles_on")
    end

    local function bat_turnoff(owner)
        owner.SoundEmitter:PlaySound("dontstarve_DLC001/common/moggles_off")
    end

    local function bat_onequip(inst, owner)
        onequip(inst, owner)
        bat_turnon(owner)
		--owner:AddTag("prebat")
	end

    local function bat_onunequip(inst, owner)
        onunequip(inst, owner)
		bat_turnoff(owner)
		--owner:RemoveTag("prebat")
	end

    local function bat_perish(inst)
        if inst.components.equippable ~= nil and inst.components.equippable:IsEquipped() then
            local owner = inst.components.inventoryitem ~= nil and inst.components.inventoryitem.owner or nil
            if owner ~= nil then
                bat_turnoff(owner)
            end
        end
        inst:Remove()
    end
	
	local function bat_custom_init(inst)
        inst:AddTag("nightvision")
    end
	
	local function bat()
        local inst = hamlet_simple(bat_custom_init)
		
		inst.entity:SetPristine()
		
		if not TheWorld.ismastersim then
            return inst
        end
		
		hamlet_master(inst)
	
		inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
        inst.components.equippable:SetOnEquip(bat_onequip)
        inst.components.equippable:SetOnUnequip(bat_onunequip)

        inst:AddComponent("fueled")
        inst.components.fueled.fueltype = FUELTYPE.WORMLIGHT
        inst.components.fueled:InitializeFuelLevel(TUNING.MOLEHAT_PERISHTIME)
        inst.components.fueled:SetDepletedFn(bat_perish)
        inst.components.fueled:SetFirstPeriod(TUNING.TURNON_FUELED_CONSUMPTION, TUNING.TURNON_FULL_FUELED_CONSUMPTION)
        inst.components.fueled.accepting = true

        return inst
    end
	
	local function default()
    local inst = hamlet_simple()
	
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
      return inst
    end
	
	hamlet_master(inst)
	
	return inst
  end
  
  local fn = nil
  local prefabs = nil
  
  if name == "candle" then
    fn = candle
  elseif name == "bandit" then
    fn = bandit
  elseif name == "pith" then
    fn = pith
  elseif name == "gasmask" then
    fn = gasmask
  elseif name == "pigcrown" then
    fn = pigcrown
  elseif name == "antmask" then
    fn = antmask
  elseif name == "peagawkfeather" then
    fn = peagawkfeather
  elseif name == "thunder" then
    fn = thunder
  elseif name == "disguise" then
    fn = disguise
  elseif name == "metalplate" then
    fn = metalplate
  elseif name == "bat" then
    fn = bat
  end
  
  return Prefab(prefabname, fn or default, assets, prefabs)
end

return 
MakeHat("metalplate"),
MakeHat("candle"), 
MakeHat("bandit"), 
MakeHat("pith"), 
MakeHat("gasmask"), 
MakeHat("pigcrown"), 
MakeHat("antmask"), 
MakeHat("peagawkfeather"),
MakeHat("thunder"), 
MakeHat("disguise"), 
MakeHat("bat") 
