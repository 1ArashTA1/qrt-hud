-- =========================================================
-- SUBSTANCES CLIENT - Drugs & Alcohol System (Fixed)
-- =========================================================

if not SubstancesConfig then
    print("[qrt-hud] SubstancesConfig not found!")
    return
end

local QBCore = exports['qb-core']:GetCoreObject()

-- =========================================================
-- متغیرهای GLOBAL (بدون local) - چون در client.lua استفاده میشن
-- =========================================================
drugLevel = 0
alcoholLevel = 0

-- متغیرهای محلی (فقط در این فایل استفاده میشن)
local lastDrugDecay = 0
local lastAlcoholDecay = 0
local lastDamageCheck = 0
local lastOverdoseCheck = 0
local lastDrunkCheck = 0
local currentBlurState = 0  -- برای state management افکت blur

-- =========================================================
-- UPDATE FUNCTIONS - دریافت آپدیت از سرور
-- =========================================================

RegisterNetEvent('substances:client:updateDrugLevel', function(newLevel)
    drugLevel = math.max(0, math.min(100, tonumber(newLevel) or 0))
    SendNUIMessage({
        action = "refreshStatus",
        drug = drugLevel,
    })
end)

RegisterNetEvent('substances:client:updateAlcoholLevel', function(newLevel)
    alcoholLevel = math.max(0, math.min(100, tonumber(newLevel) or 0))
    SendNUIMessage({
        action = "refreshStatus",
        alcohol = alcoholLevel,
    })
end)

-- =========================================================
-- نمایش نتیجه چک (برای دکتر/ادمین)
-- =========================================================

RegisterNetEvent('substances:client:showCheckResult', function(targetSrc, substances)
    if not substances then
        QBCore.Functions.Notify('No data found for this player!', 'error')
        return
    end
    QBCore.Functions.Notify(('Player %s - Drug: %d | Alcohol: %d'):format(
        targetSrc,
        substances.drug or 0,
        substances.alcohol or 0
    ), 'primary', 5000)
end)

-- =========================================================
-- NATURAL DECAY - کاهش طبیعی
-- =========================================================

CreateThread(function()
    while true do
        Wait(1000) -- هر ثانیه چک میکنیم، اما فقط وقتی interval رسیده عمل میکنیم
        local currentTime = GetGameTimer()

        -- Drug Decay
        if SubstancesConfig.Drugs.naturalDecay.enabled and drugLevel > 0 then
            if currentTime - lastDrugDecay >= SubstancesConfig.Drugs.naturalDecay.interval then
                drugLevel = math.max(0, drugLevel - SubstancesConfig.Drugs.naturalDecay.amount)
                lastDrugDecay = currentTime
                SendNUIMessage({
                    action = "refreshStatus",
                    drug = drugLevel,
                })
                TriggerEvent('substances:client:onDecay', 'drug', drugLevel)
            end
        end

        -- Alcohol Decay
        if SubstancesConfig.Alcohol.naturalDecay.enabled and alcoholLevel > 0 then
            if currentTime - lastAlcoholDecay >= SubstancesConfig.Alcohol.naturalDecay.interval then
                alcoholLevel = math.max(0, alcoholLevel - SubstancesConfig.Alcohol.naturalDecay.amount)
                lastAlcoholDecay = currentTime
                SendNUIMessage({
                    action = "refreshStatus",
                    alcohol = alcoholLevel,
                })
                TriggerEvent('substances:client:onDecay', 'alcohol', alcoholLevel)
            end
        end
    end
end)

-- =========================================================
-- DRUG DAMAGE - آسیب مواد
-- =========================================================

CreateThread(function()
    while true do
        Wait(1000)
        if SubstancesConfig.Drugs.damage.enabled and drugLevel >= SubstancesConfig.Drugs.damage.threshold then
            local currentTime = GetGameTimer()
            if currentTime - lastDamageCheck >= SubstancesConfig.Drugs.damage.interval then
                local ped = PlayerPedId()
                local health = GetEntityHealth(ped)
                local newHealth = math.max(0, health - SubstancesConfig.Drugs.damage.amount)
                SetEntityHealth(ped, newHealth)
                lastDamageCheck = currentTime

                -- افکت بصری (فقط یک بار)
                TriggerScreenblurFadeIn(500.0)
                Wait(200)
                TriggerScreenblurFadeOut(500.0)

                -- نوتیفیکیشن
                if drugLevel >= 95 then
                    QBCore.Functions.Notify('⚠️ OVERDOSE WARNING! You are dying!', 'error', 3000)
                else
                    QBCore.Functions.Notify('💊 Drugs are damaging your health!', 'error', 2000)
                end
            end
        end
    end
end)

-- =========================================================
-- OVERDOSE SYSTEM - اوردوز
-- =========================================================

CreateThread(function()
    while true do
        Wait(SubstancesConfig.Drugs.overdose.interval) -- ✅ استفاده از interval config
        if SubstancesConfig.Drugs.overdose.enabled and drugLevel >= SubstancesConfig.Drugs.overdose.threshold then
            if math.random(1, 100) <= (SubstancesConfig.Drugs.overdose.chance * 100) then
                local ped = PlayerPedId()
                SetEntityHealth(ped, 0)
                QBCore.Functions.Notify('☠️ You overdosed!', 'error', 5000)
                TriggerEvent('substances:client:onOverdose')
            end
        end
    end
end)

-- =========================================================
-- DRUNK STUMBLE SYSTEM - تلوتلو خوردن
-- =========================================================

CreateThread(function()
    while true do
        Wait(SubstancesConfig.Alcohol.severeDrunk.interval) -- ✅ استفاده از interval config
        if SubstancesConfig.Alcohol.severeDrunk.enabled
            and alcoholLevel >= SubstancesConfig.Alcohol.severeDrunk.threshold then
            if math.random(1, 100) <= (SubstancesConfig.Alcohol.severeDrunk.chance * 100) then
                local ped = PlayerPedId()
                -- انیمیشن stumble
                RequestAnimSet("move_m@drunk@verydrunk")
                while not HasAnimSetLoaded("move_m@drunk@verydrunk") do
                    Wait(10)
                end
                SetPedMovementClipset(ped, "move_m@drunk@verydrunk", 1.0)
                Wait(3000)
                ResetPedMovementClipset(ped, 1.0)
            end
        end
    end
end)

-- =========================================================
-- VISUAL EFFECTS - افکت‌های بصری (بهینه‌شده)
-- فقط یک Thread واحد برای Drug و Alcohol
-- =========================================================

CreateThread(function()
    while true do
        Wait(2000) -- هر 2 ثانیه چک کن (بهینه)

        local targetBlur = 0
        local targetShake = 0.0

        -- چک Drug Effects
        if SubstancesConfig.Drugs.enabled and drugLevel > 0 then
            for _, effect in ipairs(SubstancesConfig.Drugs.effects) do
                if drugLevel >= effect.min and drugLevel <= effect.max then
                    targetBlur = effect.blur or 0
                    break
                end
            end
        end

        -- چک Alcohol Effects (اگه drug نبود، alcohol رو چک کن)
        if targetBlur == 0 and SubstancesConfig.Alcohol.enabled and alcoholLevel > 0 then
            for _, effect in ipairs(SubstancesConfig.Alcohol.drunkEffects) do
                if alcoholLevel >= effect.min and alcoholLevel <= effect.max then
                    targetBlur = effect.blur or 0
                    targetShake = effect.shake or 0.0
                    break
                end
            end
        end

        -- فقط اگه حالت blur تغییر کرده، اعمال کن
        if targetBlur ~= currentBlurState then
            if targetBlur > 0 then
                TriggerScreenblurFadeIn(1000.0)
            else
                TriggerScreenblurFadeOut(1000.0)
            end
            currentBlurState = targetBlur
        end

        -- Camera Shake برای مستی
        if targetShake > 0.0 then
            if not IsPedInAnyVehicle(PlayerPedId(), false) then
                ShakeGameplayCam("DRUNK_SHAKE", targetShake)
            end
        else
            StopGameplayCamShaking(true)
        end
    end
end)

-- =========================================================
-- LOAD ON START - لود هنگام شروع
-- =========================================================

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    Wait(2000)
    local PlayerData = QBCore.Functions.GetPlayerData()
    if PlayerData and PlayerData.metadata and PlayerData.metadata.substances then
        drugLevel = PlayerData.metadata.substances.drug or 0
        alcoholLevel = PlayerData.metadata.substances.alcohol or 0
        SendNUIMessage({
            action = "refreshStatus",
            drug = drugLevel,
            alcohol = alcoholLevel,
        })
    end
end)

-- Backup: اگه resource بعد از لود پلیر start شد
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    Wait(5000) -- ✅ بیشتر صبر کن
    if not QBCore then return end -- ✅ چک کن QBCore لود شده

    local PlayerData = QBCore.Functions.GetPlayerData()
    if PlayerData and PlayerData.metadata and PlayerData.metadata.substances then
        drugLevel = PlayerData.metadata.substances.drug or 0
        alcoholLevel = PlayerData.metadata.substances.alcohol or 0
        SendNUIMessage({
            action = "refreshStatus",
            drug = drugLevel,
            alcohol = alcoholLevel,
        })
    end
end)

-- =========================================================
-- EXPORTS - برای استفاده در اسکریپت‌های دیگه
-- =========================================================

exports('GetDrugLevel', function()
    return drugLevel
end)

exports('GetAlcoholLevel', function()
    return alcoholLevel
end)

exports('ConsumeDrug', function(amount)
    TriggerServerEvent('substances:server:consumeDrug', amount)
end)

exports('ConsumeAlcohol', function(amount)
    TriggerServerEvent('substances:server:consumeAlcohol', amount)
end)

-- =========================================================
print('[qrt-hud] Substances client loaded!')