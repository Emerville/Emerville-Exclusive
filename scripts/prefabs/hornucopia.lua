local assets =
{
	Asset("ANIM", "anim/hornucopia.zip"),
	Asset("ATLAS", "images/inventoryimages/hornucopia.xml"),
}

local function onfinished(inst)
    local replacement = SpawnPrefab("minotaurhorn")
    local x, y, z = inst.Transform:GetWorldPosition()
    replacement.Transform:SetPosition(x, y, z)

    local owner = inst.components.inventoryitem ~= nil and inst.components.inventoryitem.owner or nil
    local holder = owner ~= nil and (owner.components.inventory or owner.components.container) or nil
    if holder ~= nil then
        local slot = holder:GetItemSlot(inst)
        holder:GiveItem(replacement, slot)
    end
    
    inst:Remove()
end

local function HearPanFlute(inst, musician, instrument, data)
    if musician.components.health then
		musician.components.health:DoDelta(2)
		musician.components.hunger:DoDelta(2)
		musician.components.sanity:DoDelta(2)
	end
end

local function fn()
	local inst = CreateEntity()
	
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()	
	
	MakeInventoryPhysics(inst)
	
	inst.AnimState:SetBank("hornucopia")
    inst.AnimState:SetBuild("hornucopia")
    inst.AnimState:PlayAnimation("anim")
		
	inst:AddTag("horn")
	
	inst.entity:SetPristine()
	
	if not TheWorld.ismastersim then
		return inst
	end	
	
	inst:AddComponent("inspectable")
    inst:AddComponent("instrument")
    inst.components.instrument.range = TUNING.PANFLUTE_SLEEPRANGE
    inst.components.instrument:SetOnHeardFn(HearPanFlute)
	
	inst:AddComponent("tool")
    inst.components.tool:SetAction(ACTIONS.PLAY)
	
	inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.PANFLUTE_USES*.5)
    inst.components.finiteuses:SetUses(TUNING.PANFLUTE_USES*.5)
    inst.components.finiteuses:SetOnFinished(onfinished)
	inst.components.finiteuses:SetConsumption(ACTIONS.PLAY, 1)
    
    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "hornucopia"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/hornucopia.xml"
	
	MakeHauntableLaunch(inst)	
	
    return inst
end

return Prefab("common/inventory/hornucopia", fn, assets) 