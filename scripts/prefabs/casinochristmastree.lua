local assets =
{
    Asset("ANIM", "anim/c_evergreen_new.zip"), --build
    Asset("ANIM", "anim/dust_fx.zip"),
    Asset("SOUND", "sound/forest.fsb"),
	
	Asset("ANIM", "anim/xmastree.zip"),	
    Asset("ATLAS", "images/inventoryimages/xmastree.xml"),
    Asset("IMAGE", "images/inventoryimages/xmastree.tex"),
}

local function updatetreelights(inst)
    if inst.stump then 
    return 
end
    inst.Light:Enable(true)
    inst.Light:SetRadius(3)
    inst.Light:SetFalloff(.8)
    inst.Light:SetIntensity(.8)
    inst.Light:SetColour(0,0/0,255/255)

    inst:DoTaskInTime(1, function(inst)
    inst.Light:Enable(true)
    inst.Light:SetRadius(3)
    inst.Light:SetFalloff(.8)
    inst.Light:SetIntensity(.8)
    inst.Light:SetColour(255/255,0,0) 
end)
    inst:DoTaskInTime(2, function(inst)
    inst.Light:Enable(true)
    inst.Light:SetRadius(3)
    inst.Light:SetFalloff(.8)
    inst.Light:SetIntensity(.8)
    inst.Light:SetColour(0,255/255,0)
end)
    inst:DoTaskInTime(3, function(inst)
    inst.Light:Enable(true)
    inst.Light:SetRadius(3)
    inst.Light:SetFalloff(.8)
    inst.Light:SetIntensity(.8)
    inst.Light:SetColour(255/255,255/255,255/255)
    end)
end

local MAXPETALS = 5

local function spawn_gift(inst)
	local minrad=1.5
	local maxrad=2.5
	
	--inst exists
	if not inst then return end
	local pt = inst:GetPosition()
	
	--not too many children
	local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, maxrad)
	local count=0
	for k,v in pairs(ents) do
		if v.prefab == "gift_red" then
			count = count + 1
		end
	end
	if count>=MAXPETALS then return end	
	
	--Find spot for new child and spawn
	local angle=math.random()*2*PI
	local radius=math.random()*(maxrad-minrad)+minrad
	local offset, check_angle, deflected=FindWalkableOffset(pt, angle, radius, 8, true, false)
	if(not check_angle) then return end
	angle=check_angle
	pt.x=pt.x+radius*math.cos(angle)
	pt.z=pt.z-radius*math.sin(angle)
	
	SpawnPrefab("gift_red").Transform:SetPosition(pt:Get())
end



--[[local function spawn_gift(inst)
	local pt = inst:GetPosition()

    local gift = SpawnPrefab("gift_red")
    local x,y,z = inst.Transform:GetWorldPosition()
    y = y - 1
    z = z + 2
    gift.Transform:SetPosition(x,y,z)
end]]

local function fn()
    local inst = CreateEntity()
	
    inst.entity:AddTransform()
	inst.entity:AddAnimState()	
    inst.entity:AddSoundEmitter()
	inst.entity:AddLight()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, .10)   

    local minimap = inst.entity:AddMiniMapEntity()
    minimap:SetIcon("evergreen.png")

    inst.AnimState:SetBuild("c_evergreen_new")
    inst.AnimState:SetBank("evergreen_short")
    inst.AnimState:PlayAnimation("sway1_loop_tall", true)	
    inst.Transform:SetScale(1.25, 1, 1.25) 

	inst:AddTag("tree")	

    inst.Light:Enable(false)
	
	inst.entity:SetPristine()
	
    if not TheWorld.ismastersim then
        return inst
    end	

    inst:AddComponent("inspectable")
	
	inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = TUNING.SANITYAURA_LARGE

    inst.AnimState:SetTime(math.random()*2)
        
    MakeSnowCovered(inst, .01)

    inst:DoPeriodicTask(240, function()
    spawn_gift(inst)
end)

    inst:DoPeriodicTask(4, function() 
    inst.Light:Enable(false)
    updatetreelights(inst)
end)

    return inst
end

return Prefab("common/objects/casinochristmastree", fn, assets, prefabs),
       MakePlacer("common/xmastree_placer", "xmastree", "xmastree", "idle") 