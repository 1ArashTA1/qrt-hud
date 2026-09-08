hunger = 100  -- dont change this
thirst = 100 -- dont change this

Config = {}

Config.Framework = "qbcore"  -- qbcore or esx or custom

Config.useElectricVehicles = true -- True if you are uising electric vehicles, false if not

Config.SpeedUnit = "KMH" -- MPH or KMH (in index.html change the line "1555" to show speed in KMH instead of MPH)


Config.Guidemenu = {     -- You can add more just copy and paste the ones that already exists.
    {
        Title = "Finding your Windows Communication Device", 
        Description = "ElixirFW"
    },
    {
        Title = "FPS Capping for UI lag:", 
        Description = "ElixirFW"
    },
}

-- ============ ON-FOOT COMPASS ITEMS ============
Config.CompassItems = {
    circle = 'compass_circle',
    bar    = 'compass_bar',
}

-- ============ SEATBELT EJECTION ============
Config.ejectVelocity = 40.0
Config.unknownEjectVelocity = 60.0
Config.unknownModifier = 17.0
Config.minDamage = 300.0
Config.noBeltEjectVelocity = 13.0
Config.noBeltUnknownEjectVelocity = 20.0
Config.noBeltModifier = 17.0
Config.noBeltMinDamage = 100.0


-- RegisterCommand('fuelxd', function(source, args, rawCommand)
--     local newFuelLevel = 8.0 -- Defina o novo nível de combustível aqui (em porcentagem)
--     local vehicle = GetVehiclePedIsIn(GetPlayerPed(-1), false)

--     if DoesEntityExist(vehicle) then
--         exports['cdn-fuel']:SetFuel(vehicle, newFuelLevel)
--     else
--         print("You are not inside a vehicle.")
--     end
-- end, false)

-- RegisterCommand('enginexd', function(source, args, rawCommand)
--     local vehicle = GetVehiclePedIsIn(GetPlayerPed(-1), false)

--     if DoesEntityExist(vehicle) then
--         SetVehicleEngineHealth(vehicle, 0.0)
--         print("The vehicle's engine was damaged.")
--     else
--         print("You are not inside a vehicle.")
--     end
-- end, false)


function getFuel(veh)
    return exports['qrt_fuel']:GetFuel(veh, false)  -- Here you put your Fuel System export
end

function getElectro(veh)
    return exports['qrt_fuel']:GetFuel(veh, false)  -- Here you put your Electro System export
end

function SeatBeltActived()
    -- exports['your_notification']:SendAlert('inform', "Seatbelt enabled")
end

function SeatBeltDesactivated()
    -- exports['your_notification']:SendAlert('inform', "Seatbelt enabled")
end

function SeatBeltError()
    -- exports['your_notification']:SendAlert('error', "You cant enable seatbelt on this car")
end


function getNitrousLevel()
    local nitrous = true 
    if nitrous then 
        return 0
    else 
        return false 
    end 
end 


function getHarnessLevel()
    local harness = true 
    if harness then 
        return 0
    else 
        return false 
    end 
end 

Config.electricVehicles = {
    [GetHashKey('voltic')] = true,
    [GetHashKey('surge')] = true,
    [GetHashKey('dilettante')] = true,
    [GetHashKey('raiden')] = true,
    [GetHashKey('cyclone')] = true,
    [GetHashKey('neon')] = true,
    [GetHashKey('tezeract')] = true,
    -- Add more model hashes as needed
}

PoliceCars = {
    "police",
}

-- Stress (ported from qb-hud)
Config.StressChance = 0.02
Config.MinimumStress = 50
Config.MinimumSpeedUnbuckled = 100
Config.MinimumSpeed = 150
Config.DisableStress = false

Config.WhitelistedWeaponStress = {
    [`weapon_petrolcan`] = true,
    [`weapon_hazardcan`] = true,
    [`weapon_fireextinguisher`] = true,
}

Config.VehClassStress = {
    ['0'] = true, ['1'] = true, ['2'] = true, ['3'] = true, ['4'] = true,
    ['5'] = true, ['6'] = true, ['7'] = true, ['8'] = true, ['9'] = true,
    ['10'] = true, ['11'] = true, ['12'] = true,
    ['13'] = false, ['14'] = false, ['15'] = false, ['16'] = false,
    ['18'] = false, ['19'] = false, ['20'] = false, ['21'] = false,
}

Config.WhitelistedVehicles = {}

Config.WhitelistedJobs = {
    ['police'] = true,
    ['ambulance'] = true,
}

Config.Intensity = {
    ['blur'] = {
        [1] = { min = 30, max = 40, intensity = 1500 },
        [2] = { min = 40, max = 50, intensity = 2000 },
        [3] = { min = 50, max = 60, intensity = 2700 },
        [4] = { min = 70, max = 80, intensity = 3000 },
        [5] = { min = 80, max = 90, intensity = 3500 },
        [6] = { min = 90, max = 100, intensity = 5000 },
    },
}

Config.EffectInterval = {
    [1] = { min = 30, max = 40, timeout = math.random(50000, 60000) },
    [2] = { min = 40, max = 50, timeout = math.random(40000, 50000) },
    [3] = { min = 50, max = 60, timeout = math.random(30000, 40000) },
    [4] = { min = 60, max = 70, timeout = math.random(20000, 30000) },
    [5] = { min = 80, max = 90, timeout = math.random(15000, 20000) },
    [6] = { min = 90, max = 100, timeout = math.random(5000, 10000) },
}

-- Money HUD currency (NUI Intl formatter)
Config.MoneyLocale = 'en-US'
Config.MoneyCurrency = 'USD'