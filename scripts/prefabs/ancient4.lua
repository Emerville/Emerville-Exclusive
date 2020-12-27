local assets=
{
	Asset("ANIM", "anim/ancient4.zip"),
--	Asset("ATLAS", "images/inventoryimages/ancient4_map.xml"),
--    Asset("IMAGE", "images/inventoryimages/ancient4_map.tex"),
	Asset("SOUND", "sound/common.fsb"),

}

local prefabs = 

{
	"trinket_6",
	"metal",
	"gears",
	"thulecite", 
	"greengem",
	"yellowgem",
	"orangegem",
}

SetSharedLootTable( 'ancientloot4',
{
    {'trinket_6',  0.5},
	{'metal',  0.4},
	{'gears',  0.2},
	--{'thulecite',  0.1},
	{'greengem',  0.05},
	{'yellowgem',  0.05},
	{'orangegem',  0.05},
 
})

local function turnon(inst)

	inst.AnimState:PlayAnimation("idle")
    inst.SoundEmitter:PlaySound("dontstarve/common/lightningrod")	
	inst.Light:Enable(true)	
	inst.Light:SetRadius(2.75)
    inst.Light:SetFalloff(0.5)
    inst.Light:SetIntensity(.85)
	
	inst.components.machine.ison = true
	 
end

local function turnoff(inst)
	inst.AnimState:PlayAnimation("off")
    inst.SoundEmitter:PlaySound("dontstarve/common/lightningrod")	
	inst.Light:Enable(false)
	inst.components.machine.ison = false
end

local function onhammered(inst, worker)
	inst.components.lootdropper:DropLoot()
	SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
	inst.SoundEmitter:PlaySound("dontstarve/common/destroy_metal")
	inst:Remove()
end

local function onhit(inst, worker)
	if inst.components.machine.ison == true then
	inst.AnimState:PlayAnimation("idle")
	else
	inst.AnimState:PlayAnimation("off")
	end
end


local function fn(Sim)
	local inst = CreateEntity()
	
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	
--	local minimap = inst.entity:AddMiniMapEntity()
--	minimap:SetIcon( "ancient4_map.tex" )
    
    inst:AddTag("structure")
    MakeObstaclePhysics(inst, .5)
    
    inst.AnimState:SetBank("ancient4")
    inst.AnimState:SetBuild("ancient4")
	inst.AnimState:PlayAnimation("idle")
	
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end		
		
    inst:AddComponent("inspectable")
	
	inst:AddComponent("machine")
	inst.components.machine.turnonfn = turnon
	inst.components.machine.turnofffn = turnoff
	inst.components.machine.ison = true
	inst.components.machine.cooldowntime = 0
	
	inst:AddComponent("lootdropper")
	inst.components.lootdropper:SetChanceLootTable('ancientloot4')
	
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
	inst.components.workable:SetOnFinishCallback(onhammered)
	inst.components.workable:SetOnWorkCallback(onhit) 
	
	inst.entity:AddLight()
	inst.Light:SetRadius(1.8)
    inst.Light:SetFalloff(0.5)
    inst.Light:SetIntensity(.8)
    inst.Light:SetColour(237/255, 237/255, 209/255)
	
    return inst
end

return Prefab( "common/ancient4", fn, assets, prefabs)