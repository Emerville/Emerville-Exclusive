require "prefabutil"

local function make_plantable(data)
    local assets =
    {
		Asset("ANIM", "anim/"..data.bank..".zip"),
    }

    if data.build ~= nil then
        table.insert(assets, Asset("ANIM", "anim/"..data.build..".zip"))
    end

    local function ondeploy(inst, pt, deployer)
	
			if data.name == "elephantcactus" then
			local tree = SpawnPrefab("elephantcactus_stump")
			if tree ~= nil then
				tree.Transform:SetPosition(pt:Get())
				inst.components.stackable:Get():Remove()
				if deployer ~= nil and deployer.SoundEmitter ~= nil then
					deployer.SoundEmitter:PlaySound("dontstarve/common/plant")
				end
			end
			return
			end
	



			if data.name == "bambootree" then
			local tree = SpawnPrefab("bambootree")
			if tree ~= nil then
				tree.Transform:SetPosition(pt:Get())
				inst.components.stackable:Get():Remove()
				if deployer ~= nil and deployer.SoundEmitter ~= nil then
					deployer.SoundEmitter:PlaySound("dontstarve/common/plant")
				end
				tree.AnimState:PlayAnimation("picked")			
				tree:RemoveTag("machetecut")
				tree.components.workable:SetWorkAction(ACTIONS.DIG)
				tree.components.workable:SetWorkLeft(1)
				tree.components.timer:StartTimer("spawndelay", 60*8*2)
			end	
			return
			end
		
		
		if data.name == "bush_vine" then
			local tree = SpawnPrefab("bush_vine")
			if tree ~= nil then
				tree.Transform:SetPosition(pt:Get())
				inst.components.stackable:Get():Remove()
				if deployer ~= nil and deployer.SoundEmitter ~= nil then
					deployer.SoundEmitter:PlaySound("dontstarve/common/plant")
				end
				tree.AnimState:PlayAnimation("hacked_idle")				
				tree:RemoveTag("machetecut")
				tree.components.workable:SetWorkAction(ACTIONS.DIG)
				tree.components.workable:SetWorkLeft(1)
				tree.components.timer:StartTimer("spawndelay", 60*8*2)
			end	
			return
			end



	
        local tree = SpawnPrefab(data.name)
       if tree ~= nil then
            tree.Transform:SetPosition(pt:Get())
            inst.components.stackable:Get():Remove()
            tree.components.pickable:OnTransplant()
            if deployer ~= nil and deployer.SoundEmitter ~= nil then
                --V2C: WHY?!! because many of the plantables don't
                --     have SoundEmitter, and we don't want to add
                --     one just for this sound!
                deployer.SoundEmitter:PlaySound("dontstarve/common/plant")
            end
        end
    end

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)
		
		inst:AddTag("deployedplant")

        inst.AnimState:SetBank(data.bank or data.name)
        inst.AnimState:SetBuild(data.build or data.name)
        inst.AnimState:PlayAnimation("dropped")
		
     	MakeInventoryFloatable(inst, "small", 0.2, 0.80)

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("stackable")
        inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM

        inst:AddComponent("inspectable")
        inst.components.inspectable.nameoverride = data.inspectoverride or "dug_"..data.name
        inst:AddComponent("inventoryitem")
		inst.components.inventoryitem.atlasname = "images/inventoryimages/volcanoinventory.xml"

        inst:AddComponent("fuel")
        inst.components.fuel.fuelvalue = TUNING.LARGE_FUEL

        inst:AddComponent("deployable")
        --inst.components.deployable:SetDeployMode(DEPLOYMODE.ANYWHERE)
        inst.components.deployable.ondeploy = ondeploy
        inst.components.deployable:SetDeployMode(DEPLOYMODE.PLANT)
        if data.mediumspacing then
            inst.components.deployable:SetDeploySpacing(DEPLOYSPACING.MEDIUM)
        end

        ---------------------
        return inst
    end

    return Prefab("dug_"..data.name, fn, assets)
end

local plantables =
{

	 {name="coffeebush", bank = "coffeebush", build = "coffeebush", mediumspacing = true},
}

local prefabs = {}
for i, v in ipairs(plantables) do
    table.insert(prefabs, make_plantable(v))
    table.insert(prefabs, MakePlacer("dug_"..v.name.."_placer", v.bank or v.name, v.build or v.name, v.anim or "idle"))
end

return unpack(prefabs)