local assets =
{
--	Asset("SOUNDPACKAGE", "sound/circus.fev"),
--	Asset("SOUND", "sound/circus.fsb"),
	Asset("SOUNDPACKAGE", "sound/fnree.fev"),
	Asset("SOUND", "sound/fnree.fsb"),
--	Asset("SOUNDPACKAGE", "sound/REE.fev"),
--	Asset("SOUND", "sound/REE.fsb"),
--	Asset("SOUNDPACKAGE", "sound/airhorn.fev"),
--	Asset("SOUND", "sound/airhorn.fsb")

    Asset("ANIM", "anim/horn.zip"),
	
    Asset("ATLAS", "images/inventoryimages/fryingpan.xml"),
    Asset("IMAGE", "images/inventoryimages/fryingpan.tex"),	
}

--[[if a then
	RemapSoundEvent("dontstarve/common/horn_beefalo", "fnree/fnree/fnree")
end

if b then
	RemapSoundEvent("dontstarve/common/horn_beefalo", "REE/REE/REE")
end

if c then
	RemapSoundEvent("dontstarve/common/horn_beefalo", "airhorn/AHMLG/airhorn")
end

if d then
	RemapSoundEvent("dontstarve/common/horn_beefalo", "circus/circus/circus")
end]]





local function fn()
    local inst = CreateEntity()
	
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()	

    MakeInventoryPhysics(inst)

    inst:AddTag("horn")

    --tool (from tool component) added to pristine state for optimization
    inst:AddTag("tool")

    inst.AnimState:SetBank("horn")
    inst.AnimState:SetBuild("horn")
    inst.AnimState:PlayAnimation("idle")

    MakeInventoryFloatable(inst, "med", 0.25)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
	
    inst:AddComponent("instrument")
    inst.components.instrument.range = 25

    inst:AddComponent("tool")
    inst.components.tool:SetAction(ACTIONS.PLAY)

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.HORN_USES)
    inst.components.finiteuses:SetUses(TUNING.HORN_USES)
    inst.components.finiteuses:SetOnFinished(inst.Remove)
    inst.components.finiteuses:SetConsumption(ACTIONS.PLAY, 1)

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "fryingpan"	
    inst.components.inventoryitem.atlasname = "images/inventoryimages/fryingpan.xml"	

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("common/inventory/megaphonehorn", fn, assets) 
