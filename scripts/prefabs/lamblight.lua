local function lamblightfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst.Light:SetFalloff(0.4)
    inst.Light:SetIntensity(.7)
    inst.Light:SetRadius(1)
    inst.Light:SetColour(223/255, 208/255, 69/255)

    inst.entity:SetPristine()
	
	inst:DoTaskInTime(1, inst.Remove)

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end

return Prefab("lamblight", lamblightfn)