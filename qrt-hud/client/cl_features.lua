-- Stress, stamina, and money HUD (qb-hud compatible events)

stress = 0
local speedMultiplierStress = (Config.SpeedUnit == "KMH") and 3.6 or 3.6

local function GetBlurIntensity(stresslevel)
    for _, v in pairs(Config.Intensity['blur']) do
        if stresslevel >= v.min and stresslevel <= v.max then
            return v.intensity
        end
    end
    return 1500
end

local function GetEffectInterval(stresslevel)
    for _, v in pairs(Config.EffectInterval) do
        if stresslevel >= v.min and stresslevel <= v.max then
            return v.timeout
        end
    end
    return 60000
end

function getHudStamina(player)
    if IsPedSwimmingUnderWater(player) or IsEntityInWater(player) then
        return false
    end
    local remaining = GetPlayerSprintStaminaRemaining(PlayerId())
    local staminaVal = math.floor(100 - remaining)
    if staminaVal >= 100 then
        return false
    end
    if staminaVal < 1 then
        staminaVal = 1
    end
    return staminaVal
end

RegisterNetEvent('hud:client:UpdateStress', function(newStress)
    stress = newStress or 0
end)

RegisterNUICallback('dynamicStress', function(data, cb)
    SendNUIMessage({
        action = 'setDynamicStress',
        enabled = data.enabled,
    })
    if cb then cb('ok') end
end)

-- Money HUD
local Round = math.floor

RegisterNetEvent('hud:client:ShowAccounts', function(accType, amount)
    if accType == 'cash' then
        SendNUIMessage({
            action = 'show',
            type = 'cash',
            cash = Round(amount),
        })
    else
        SendNUIMessage({
            action = 'show',
            type = 'bank',
            bank = Round(amount),
        })
    end
end)

RegisterNetEvent('hud:client:OnMoneyChange', function(accType, amount, isMinus)
    if Config.Framework ~= "qbcore" then return end
    local QBCore = exports['qb-core']:GetCoreObject()
    local pd = QBCore.Functions.GetPlayerData()
    if not pd or not pd.money then return end

    SendNUIMessage({
        action = 'updatemoney',
        cash = Round(pd.money['cash']),
        bank = Round(pd.money['bank']),
        amount = Round(amount),
        minus = isMinus,
        type = accType,
    })
end)

if Config.Framework == "qbcore" then
    local QBCore = exports['qb-core']:GetCoreObject()

    RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
        local pd = QBCore.Functions.GetPlayerData()
        if pd and pd.metadata then
            stress = pd.metadata['stress'] or 0
        end
    end)

    RegisterNetEvent('QBCore:Player:SetPlayerData', function(val)
        if val and val.metadata and val.metadata['stress'] then
            stress = val.metadata['stress']
        end
    end)
end

if not Config.DisableStress then
    CreateThread(function()
        while true do
            if Config.Framework == "qbcore" and LocalPlayer.state.isLoggedIn then
                local ped = PlayerPedId()
                if IsPedInAnyVehicle(ped, false) then
                    local veh = GetVehiclePedIsIn(ped, false)
                    local vehClass = GetVehicleClass(veh)
                    local vehSpeed = GetEntitySpeed(veh) * speedMultiplierStress
                    local vehHash = GetEntityModel(veh)
                    if Config.VehClassStress[tostring(vehClass)] and not Config.WhitelistedVehicles[vehHash] then
                        local stressSpeed
                        if vehClass == 8 then
                            stressSpeed = Config.MinimumSpeed
                        else
                            stressSpeed = seatbelt and Config.MinimumSpeed or Config.MinimumSpeedUnbuckled
                        end
                        if vehSpeed >= stressSpeed then
                            TriggerServerEvent('hud:server:GainStress', math.random(1, 3))
                        end
                    end
                end
            end
            Wait(10000)
        end
    end)

    CreateThread(function()
        while true do
            if Config.Framework == "qbcore" and LocalPlayer.state.isLoggedIn then
                local ped = PlayerPedId()
                local weapon = GetSelectedPedWeapon(ped)
                if weapon ~= `WEAPON_UNARMED` then
                    if IsPedShooting(ped) and not Config.WhitelistedWeaponStress[weapon] then
                        if math.random() < Config.StressChance then
                            TriggerServerEvent('hud:server:GainStress', math.random(1, 3))
                        end
                    end
                else
                    Wait(1000)
                end
            end
            Wait(0)
        end
    end)
end

CreateThread(function()
    while true do
        if Config.DisableStress then
            Wait(5000)
        else
            local ped = PlayerPedId()
            local effectInterval = GetEffectInterval(stress)
            if stress >= 100 then
                local blurIntensity = GetBlurIntensity(stress)
                local fallRepeat = math.random(2, 4)
                local ragdollTimeout = fallRepeat * 1750
                TriggerScreenblurFadeIn(1000.0)
                Wait(blurIntensity)
                TriggerScreenblurFadeOut(1000.0)

                if not IsPedRagdoll(ped) and IsPedOnFoot(ped) and not IsPedSwimming(ped) then
                    SetPedToRagdollWithFall(ped, ragdollTimeout, ragdollTimeout, 1, GetEntityForwardVector(ped), 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
                end

                Wait(1000)
                for _ = 1, fallRepeat do
                    Wait(750)
                    DoScreenFadeOut(200)
                    Wait(1000)
                    DoScreenFadeIn(200)
                    TriggerScreenblurFadeIn(1000.0)
                    Wait(blurIntensity)
                    TriggerScreenblurFadeOut(1000.0)
                end
            elseif stress >= Config.MinimumStress then
                local blurIntensity = GetBlurIntensity(stress)
                TriggerScreenblurFadeIn(1000.0)
                Wait(blurIntensity)
                TriggerScreenblurFadeOut(1000.0)
            end
            Wait(effectInterval)
        end
    end
end)
