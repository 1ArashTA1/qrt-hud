local CodeID = {
    author = "Elixir FW",
    codeName = 'HUD V2 System 4.0',
    version = '2.2.0'
}

Citizen.CreateThread(function()
    print(CodeID.author .. ' - [' .. CodeID.codeName .. '] v' .. CodeID.version .. ' sucessfully started!')
end)

if Config.Framework ~= "qbcore" then
    return
end

local QBCore = exports['qb-core']:GetCoreObject()
local ResetStress = false

QBCore.Commands.Add('cash', 'Check Cash Balance', {}, false, function(source, _)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    TriggerClientEvent('hud:client:ShowAccounts', source, 'cash', Player.PlayerData.money.cash)
end)

QBCore.Commands.Add('bank', 'Check Bank Balance', {}, false, function(source, _)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    TriggerClientEvent('hud:client:ShowAccounts', source, 'bank', Player.PlayerData.money.bank)
end)

RegisterNetEvent('hud:server:GainStress', function(amount)
    if Config.DisableStress then return end
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local jobName = Player.PlayerData.job.name
    local jobType = Player.PlayerData.job.type
    if Config.WhitelistedJobs[jobType] or Config.WhitelistedJobs[jobName] then return end

    local newStress
    if not ResetStress then
        if not Player.PlayerData.metadata['stress'] then
            Player.PlayerData.metadata['stress'] = 0
        end
        newStress = Player.PlayerData.metadata['stress'] + amount
        if newStress <= 0 then newStress = 0 end
    else
        newStress = 0
    end
    if newStress > 100 then newStress = 100 end

    Player.Functions.SetMetaData('stress', newStress)
    TriggerClientEvent('hud:client:UpdateStress', src, newStress)
end)

RegisterNetEvent('hud:server:RelieveStress', function(amount)
    if Config.DisableStress then return end
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local newStress
    if not ResetStress then
        if not Player.PlayerData.metadata['stress'] then
            Player.PlayerData.metadata['stress'] = 0
        end
        newStress = Player.PlayerData.metadata['stress'] - amount
        if newStress <= 0 then newStress = 0 end
    else
        newStress = 0
    end
    if newStress > 100 then newStress = 100 end

    Player.Functions.SetMetaData('stress', newStress)
    TriggerClientEvent('hud:client:UpdateStress', src, newStress)
end)


-- =========================================================
-- HUNGER & THIRST METADATA SYNC
-- =========================================================
RegisterNetEvent('hud:server:UpdateHunger', function(amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local newHunger = math.max(0, math.min(100, tonumber(amount) or 0))
    Player.Functions.SetMetaData('hunger', newHunger)
end)

RegisterNetEvent('hud:server:UpdateThirst', function(amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local newThirst = math.max(0, math.min(100, tonumber(amount) or 0))
    Player.Functions.SetMetaData('thirst', newThirst)
end)
