-- =========================================================
-- SUBSTANCES SERVER - Drugs & Alcohol System (Fixed)
-- =========================================================
if not SubstancesConfig then
    print("[qrt-hud] SubstancesConfig not found!")
    return
end

local QBCore = exports['qb-core']:GetCoreObject()

-- ========== HELPER FUNCTIONS ==========
local function GetPlayerSubstances(src)
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return nil end
    
    local substances = Player.PlayerData.metadata['substances'] or {
        drug = 0,
        alcohol = 0,
        lastDrugUse = 0,
        lastAlcoholUse = 0,
        totalDrugUses = 0,
        totalAlcoholUses = 0,
    }
    return substances
end

local function SavePlayerSubstances(src, substances)
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    Player.Functions.SetMetaData('substances', substances)
end

-- ✅ Helper داخلی برای set level (بدون چک permission - برای استفاده در command و export)
local function SetSubstanceLevelInternal(targetSrc, type, amount)
    local substances = GetPlayerSubstances(targetSrc)
    if not substances then return false end
    
    amount = math.max(0, math.min(100, tonumber(amount) or 0))
    
    if type == 'drug' then
        substances.drug = amount
    elseif type == 'alcohol' then
        substances.alcohol = amount
    else
        return false
    end
    
    SavePlayerSubstances(targetSrc, substances)
    
    -- ارسال به کلاینت
    TriggerClientEvent('substances:client:updateDrugLevel', targetSrc, substances.drug)
    TriggerClientEvent('substances:client:updateAlcoholLevel', targetSrc, substances.alcohol)
    
    return true
end

-- ========== CONSUME EVENTS ==========
RegisterNetEvent('substances:server:consumeDrug', function(amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    amount = tonumber(amount) or 10
    local substances = GetPlayerSubstances(src)
    
    -- اضافه کردن مقدار
    substances.drug = math.min(substances.drug + amount, SubstancesConfig.Drugs.maxAmount)
    substances.lastDrugUse = os.time()
    substances.totalDrugUses = (substances.totalDrugUses or 0) + 1
    
    SavePlayerSubstances(src, substances)
    
    -- ارسال به کلاینت
    TriggerClientEvent('substances:client:updateDrugLevel', src, substances.drug)
    TriggerClientEvent('substances:client:onConsume', src, 'drug', amount, substances.drug)
    
    -- لاگ
    print(('[substances] Player %s consumed %d drug (total: %d)'):format(
        GetPlayerName(src), amount, substances.drug
    ))
end)

RegisterNetEvent('substances:server:consumeAlcohol', function(amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    amount = tonumber(amount) or 10
    local substances = GetPlayerSubstances(src)
    
    substances.alcohol = math.min(substances.alcohol + amount, SubstancesConfig.Alcohol.maxAmount)
    substances.lastAlcoholUse = os.time()
    substances.totalAlcoholUses = (substances.totalAlcoholUses or 0) + 1
    
    SavePlayerSubstances(src, substances)
    
    TriggerClientEvent('substances:client:updateAlcoholLevel', src, substances.alcohol)
    TriggerClientEvent('substances:client:onConsume', src, 'alcohol', amount, substances.alcohol)
    
    print(('[substances] Player %s consumed %d alcohol (total: %d)'):format(
        GetPlayerName(src), amount, substances.alcohol
    ))
end)

-- ========== GET LEVEL (Callback برای اسکریپت دکتر) ==========
-- ✅ اصلاح شده: CreateCallback به جای TriggerCallback
QBCore.Functions.CreateCallback('substances:server:getLevel', function(source, cb, targetSrc)
    local substances = GetPlayerSubstances(targetSrc or source)
    cb(substances)
end)

-- ========== CHECK LEVEL (ایونت برای چک کردن توسط دکتر/ادمین) ==========
RegisterNetEvent('substances:server:checkLevel', function(targetSrc)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    -- بررسی اجازه (فقط دکتر یا ادمین)
    local jobName = Player.PlayerData.job.name
    local isDoctor = jobName == SubstancesConfig.Permissions.doctorJob
    local isAdmin = QBCore.Functions.HasPermission(src, SubstancesConfig.Permissions.adminCommand)
    
    if not isDoctor and not isAdmin then
        TriggerClientEvent('QBCore:Notify', src, 'You cannot check this!', 'error')
        return
    end
    
    local substances = GetPlayerSubstances(targetSrc)
    if not substances then
        TriggerClientEvent('QBCore:Notify', src, 'Player not found!', 'error')
        return
    end
    
    TriggerClientEvent('substances:client:showCheckResult', src, targetSrc, substances)
end)

-- ========== SET LEVEL (ادمین) ==========
RegisterNetEvent('substances:server:setLevel', function(targetSrc, type, amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    if not QBCore.Functions.HasPermission(src, SubstancesConfig.Permissions.adminCommand) then
        TriggerClientEvent('QBCore:Notify', src, 'No permission!', 'error')
        return
    end
    
    local success = SetSubstanceLevelInternal(targetSrc, type, amount)
    if success then
        TriggerClientEvent('QBCore:Notify', src, 'Substance level updated!', 'success')
    else
        TriggerClientEvent('QBCore:Notify', src, 'Failed to update!', 'error')
    end
end)

-- ========== COMMANDS ==========

-- ✅ اصلاح شده: substances رو از GetPlayerSubstances می‌گیره
QBCore.Commands.Add('checksubstances', 'Check player substances', {{name='id', help='Player ID'}}, false, function(source, args)
    local targetSrc = tonumber(args[1])
    if not targetSrc then
        TriggerClientEvent('QBCore:Notify', source, 'Invalid player ID', 'error')
        return
    end
    
    local substances = GetPlayerSubstances(targetSrc)
    if not substances then
        TriggerClientEvent('QBCore:Notify', source, 'Player not found!', 'error')
        return
    end
    
    TriggerClientEvent('substances:client:showCheckResult', source, targetSrc, substances)
end, SubstancesConfig.Permissions.adminCommand)

-- ✅ اصلاح شده: استفاده از helper function به جای TriggerEvent
QBCore.Commands.Add('setdrug', 'Set drug level', {{name='id', help='Player ID'}, {name='amount', help='Amount (0-100)'}}, false, function(source, args)
    local targetSrc = tonumber(args[1])
    local amount = tonumber(args[2])
    
    if not targetSrc or not amount then
        TriggerClientEvent('QBCore:Notify', source, 'Invalid arguments. Usage: /setdrug [id] [0-100]', 'error')
        return
    end
    
    local success = SetSubstanceLevelInternal(targetSrc, 'drug', amount)
    if success then
        TriggerClientEvent('QBCore:Notify', source, ('Drug level set to %d for player %d'):format(amount, targetSrc), 'success')
    else
        TriggerClientEvent('QBCore:Notify', source, 'Failed to update! Player may not exist.', 'error')
    end
end, SubstancesConfig.Permissions.adminCommand)

-- ✅ اصلاح شده: استفاده از helper function به جای TriggerEvent
QBCore.Commands.Add('setalcohol', 'Set alcohol level', {{name='id', help='Player ID'}, {name='amount', help='Amount (0-100)'}}, false, function(source, args)
    local targetSrc = tonumber(args[1])
    local amount = tonumber(args[2])
    
    if not targetSrc or not amount then
        TriggerClientEvent('QBCore:Notify', source, 'Invalid arguments. Usage: /setalcohol [id] [0-100]', 'error')
        return
    end
    
    local success = SetSubstanceLevelInternal(targetSrc, 'alcohol', amount)
    if success then
        TriggerClientEvent('QBCore:Notify', source, ('Alcohol level set to %d for player %d'):format(amount, targetSrc), 'success')
    else
        TriggerClientEvent('QBCore:Notify', source, 'Failed to update! Player may not exist.', 'error')
    end
end, SubstancesConfig.Permissions.adminCommand)

-- ✅ Command برای reset کردن (مفید برای دکتر)
QBCore.Commands.Add('resetsubstances', 'Reset player substances', {{name='id', help='Player ID'}}, false, function(source, args)
    local targetSrc = tonumber(args[1])
    if not targetSrc then
        TriggerClientEvent('QBCore:Notify', source, 'Invalid player ID', 'error')
        return
    end
    
    SetSubstanceLevelInternal(targetSrc, 'drug', 0)
    SetSubstanceLevelInternal(targetSrc, 'alcohol', 0)
    
    TriggerClientEvent('QBCore:Notify', source, ('Substances reset for player %d'):format(targetSrc), 'success')
end, SubstancesConfig.Permissions.adminCommand)

-- ========== EXPORTS ==========
-- ✅ اصلاح شده: استفاده مستقیم از helper function به جای TriggerEvent

exports('GetDrugLevel', function(targetSrc)
    local substances = GetPlayerSubstances(targetSrc)
    return substances and substances.drug or 0
end)

exports('GetAlcoholLevel', function(targetSrc)
    local substances = GetPlayerSubstances(targetSrc)
    return substances and substances.alcohol or 0
end)

exports('SetDrugLevel', function(targetSrc, amount)
    return SetSubstanceLevelInternal(targetSrc, 'drug', amount)
end)

exports('SetAlcoholLevel', function(targetSrc, amount)
    return SetSubstanceLevelInternal(targetSrc, 'alcohol', amount)
end)

-- ✅ Export جدید: دریافت کل اطلاعات substances
exports('GetPlayerSubstances', function(targetSrc)
    return GetPlayerSubstances(targetSrc)
end)

-- ✅ Export جدید: reset کردن
exports('ResetSubstances', function(targetSrc)
    SetSubstanceLevelInternal(targetSrc, 'drug', 0)
    SetSubstanceLevelInternal(targetSrc, 'alcohol', 0)
    return true
end)

print('[qrt-hud] Substances system loaded!')