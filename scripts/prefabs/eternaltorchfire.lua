local assets = 
{
   Asset("ANIM", "anim/eternaltorchfire.zip")
}

--Needs to save/load time alive.

local function onload(inst, data)
    inst.AnimState:PlayAnimation("disappear")
    inst:DoTaskInTime(0.6, function() inst.SoundEmitter:KillAllSounds() inst:Remove() end) 
end

local function fn(Sim)
    local inst = CreateEntity()
	
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
    inst.entity:AddLight()		
	inst.entity:AddNetwork()

    inst.AnimState:SetBank("star")
    inst.AnimState:SetBuild("eternaltorchfire")
    inst.AnimState:PlayAnimation("appear")
    inst.AnimState:PushAnimation("idle_loop", true)

    inst.Light:Enable(true)	
	inst.Light:SetIntensity(.99)
    inst.Light:SetColour(50/255,197/255,178/255)
    inst.Light:SetFalloff(0.8)
    inst.Light:SetRadius(4)			

    inst.entity:SetPristine()	
	
    if not TheWorld.ismastersim then
        return inst
    end			
  
    inst.OnLoad = onload

    return inst
end

return Prefab("common/eternaltorchfire", fn, assets) 
