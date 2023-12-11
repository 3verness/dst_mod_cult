local assets =
{
    Asset("ANIM", "anim/curseshot.zip"),
}

local prefabs =
{
    "explode_small",
}

local PULSE_SYNC_PERIOD = 30

--Needs to save/load time alive.

local function DoExplode(inst)
    --[[for i, v in ipairs(AllPlayers) do
        local distSq = v:GetDistanceSqToInst(inst)
        local k = math.max(0, math.min(1, distSq / 1600))
        local intensity = k * (k - 2) + 1 --easing.outQuad(k, 1, -1, 1)
        if intensity > 0 then
            v:ShakeCamera(CAMERASHAKE.FULL, .7, .02, intensity / 2)
        end
    end]]
	
    local x, y, z = inst.Transform:GetWorldPosition()
    local range = 4

    -- Players are off limits now
    local ents = TheSim:FindEntities(x, y, z, range, nil, { "INLIMBO", "player" })
 
    for i, v in ipairs(ents) do
        if v ~= inst and v:IsValid() and not v:IsInLimbo() then
            --[[if v.components.workable ~= nil and v.components.workable:CanBeWorked() then
                v.components.workable:WorkedBy(inst, inst.buildingdamage)
            end]]
 
            --Recheck valid after work
            if v:IsValid() and not v:IsInLimbo() then
                
 
                if v.components.combat ~= nil then
					if inst.components.curseshot_master.master ~= nil then
                    	v.components.combat:GetAttacked(inst.components.curseshot_master.master, 50, nil)
					end
                end
 
            end
        end
    end
end

local function kill_sound(inst)
    inst.SoundEmitter:KillSound("staff_star_loop")
end

local function ontimer(inst, data)
    
	inst:ListenForEvent("animover", kill_sound)
	DoExplode(inst)
	--SpawnPrefab("explode_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
	inst:DoTaskInTime(0.1, inst.Remove)
	
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.Transform:SetScale(1, 1, 1)

    inst.AnimState:SetLightOverride(1)
    inst.AnimState:SetBank("curseshot")
    inst.AnimState:SetBuild("curseshot")
    inst.AnimState:PlayAnimation("curseshot")

    inst.SoundEmitter:PlaySound("dontstarve/common/staff_star_create")

    inst:AddComponent("timer")
    inst.components.timer:StartTimer("extinguish", 0.46)
    inst:ListenForEvent("timerdone", ontimer)

    return inst
end

return Prefab("curseshot", fn, assets)
