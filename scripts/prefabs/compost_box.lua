require "prefabutil"

local assets =
{
	Asset("ANIM", "anim/compost_box.zip"),
	
	Asset("ATLAS", "images/inventoryimages/compost_box.xml"),
	Asset("IMAGE", "images/inventoryimages/compost_box.tex"),	
}

local prefabs =
{
	"collapse_small",
}
--------------------------------

local function onopen(inst)
	if not inst:HasTag("burnt") then
		inst.AnimState:PlayAnimation("open")
		inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open")	
	end
end 

local function onclose(inst) 
	if not inst:HasTag("burnt") then
		inst.AnimState:PlayAnimation("close")
		inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close")
	end
    for k=1, inst.components.container.numslots do
        local item = inst.components.container:GetItemInSlot(k)
			if item and (item.prefab == "guano") then
				local stacksize = item.components.stackable:StackSize()
				--inst.components.container:RemoveItemBySlot(k)
				item:Remove()
				for i=1,stacksize do
					local poop = SpawnPrefab("poop")
					if poop then inst.components.container:GiveItem(poop) end
			end 
		end
    end
end

------------------------------

local function onhit(inst, worker)
	if not inst:HasTag("burnt") then
	inst.AnimState:PlayAnimation("hit")
	inst.AnimState:PushAnimation("closed", false)
	elseif inst:HasTag("burnt") then
		inst.AnimState:PushAnimation("burnt")
	end
end

local function onhammered(inst, worker)
	if inst:HasTag("fire") and inst.components.burnable then
		inst.components.burnable:Extinguish()
	end
	inst.components.lootdropper:DropLoot()
	if inst.components.container then inst.components.container:DropEverything() end
	SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
	inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")
--[[	if inst.flies then 
		inst.flies:Remove() inst.flies = nil 
	end	]]
	inst:Remove()
end

local function onbuilt(inst)
	inst.AnimState:PlayAnimation("place")
	inst.AnimState:PushAnimation("closed", false)
	inst.SoundEmitter:PlaySound("dontstarve/common/bee_box_craft")
    end

local function OnBurnt(inst)
	inst.AnimState:PlayAnimation("burnt")
	inst.components.sanityaura.aura = 0
--[[    if inst.flies then 
	    inst.flies:Remove() inst.flies = nil 
	end	]]
end
	
local function onsave(inst, data)
	if inst:HasTag("burnt") or inst:HasTag("fire") then
        data.burnt = true
		--[[if inst.flies then 
			inst.flies:Remove() inst.flies = nil 
		end]]	
    end
end	
	
local function onload(inst, data)
	if data and data.burnt then
        inst.components.burnable.onburnt(inst)
    --[[if inst.flies then 
	    inst.flies:Remove() inst.flies = nil 
	    end]]	
    end
end		
	
local function fn()
	local inst = CreateEntity()
	
    inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()		
		
	local minimap = inst.entity:AddMiniMapEntity()	
	minimap:SetIcon("compost_box.tex")

	inst:AddTag("structure")	
	inst:AddTag("compost")	
    inst.AnimState:SetBank("compost_box")
    inst.AnimState:SetBuild("compost_box")
    inst.AnimState:PlayAnimation("close")

    inst.entity:SetPristine()	

    if not TheWorld.ismastersim then
        return inst
    end	
		    
    inst:AddComponent("inspectable")
	
    inst:AddComponent("container")
    inst.components.container:WidgetSetup("compost_box")    
    inst.components.container.onopenfn = onopen
    inst.components.container.onclosefn = onclose
    inst.components.container.skipopensnd = true
    inst.components.container.skipclosesnd = true
	
	inst:AddComponent("lootdropper")	

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)

	inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = -TUNING.SANITYAURA_TINY	
			
	inst:ListenForEvent("onbuilt", onbuilt)
	inst:ListenForEvent("onburnt", OnBurnt)
	
--	inst.flies = inst:SpawnChild("flies")	
	
	MakeMediumBurnable(inst, nil, nil, true)
    MakeMediumPropagator(inst)		
	
	inst.OnSave = onsave 
    inst.OnLoad = onload
	
	AddHauntableDropItemOrWork(inst)	
	
    return inst
end

return Prefab("common/compost_box", fn, assets),
	   MakePlacer("common/compost_box_placer", "compost_box", "compost_box", "closed") 