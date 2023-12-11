local assets =
{
    Asset("ANIM", "anim/poopfood_cl.zip"),
	
	Asset("ATLAS", "images/inventoryimages/poopfood_cl.xml"),
    Asset("IMAGE", "images/inventoryimages/poopfood_cl.tex"),
}

local function item_oneaten(inst, eater)
	local select_bomb = math.random(1 , 2)
	if select_bomb == 1 then
		inst.components.edible.healthvalue = 0
    	inst.components.edible.sanityvalue = 0
	end
	if select_bomb == 2 then 
		inst.components.edible.healthvalue = -66
    	inst.components.edible.sanityvalue = -666
	end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("poopfood_cl")
    inst.AnimState:SetBuild("poopfood_cl")
    inst.AnimState:PlayAnimation("idle",true)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
	
	inst.components.inventoryitem.imagename = "poopfood_cl"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/poopfood_cl.xml"
	
	inst:AddComponent("edible")
    inst.components.edible.ismeat = false    
    inst.components.edible.foodtype = FOODTYPE.GENERIC
	inst.components.edible.hungervalue = 666
	--inst.components.edible.healthvalue = -66
	--inst.components.edible.sanityvalue = -666
	inst.components.edible:SetOnEatenFn(item_oneaten)
	
	inst:AddTag("preparedfood")
	
	inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)
    inst.components.perishable:StartPerishing()
    inst.components.perishable.onperishreplacement = "spoiled_food"

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("poopfood_cl", fn, assets)