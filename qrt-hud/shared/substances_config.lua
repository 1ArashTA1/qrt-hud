-- =========================================================
-- SUBSTANCES CONFIG - Drugs & Alcohol System
-- =========================================================
SubstancesConfig = {}

-- ========== DRUG SYSTEM ==========
SubstancesConfig.Drugs = {
    enabled = true,
    showThreshold = 5,        -- بعد از این مقدار نمایش داده شود
    maxAmount = 100,          -- حداکثر مقدار
    
    -- کاهش طبیعی
    naturalDecay = {
        enabled = true,
        interval = 30000,     -- هر 30 ثانیه
        amount = 1,           -- 1 واحد کم شود
    },
    
    -- دمیج خودکار
    damage = {
        enabled = true,
        threshold = 90,       -- بالای این مقدار دمیج بگیرد
        amount = 5,           -- مقدار دمیج هر بار
        interval = 5000,      -- هر 5 ثانیه
    },
    
    -- اوردوز
    overdose = {
        enabled = true,
        threshold = 95,       -- بالای این مقدار احتمال اوردوز
        chance = 0.05,        -- 5% احتمال هر بار چک
        interval = 10000,     -- هر 10 ثانیه چک شود
        damage = 50,          -- دمیج اوردوز
    },
    
    -- افکت‌های بصری
    effects = {
        [1] = { min = 20, max = 40, blur = 500 },
        [2] = { min = 40, max = 60, blur = 1000 },
        [3] = { min = 60, max = 80, blur = 1500 },
        [4] = { min = 80, max = 90, blur = 2000 },
        [5] = { min = 90, max = 100, blur = 3000 },
    },
    
    -- انواع مواد (برای آینده - فعلاً غیرفعال)
    -- types = {
    --     weed = { name = "Weed", decayRate = 1, effectIntensity = 0.8 },
    --     cocaine = { name = "Cocaine", decayRate = 2, effectIntensity = 1.2 },
    --     meth = { name = "Meth", decayRate = 3, effectIntensity = 1.5 },
    --     heroin = { name = "Heroin", decayRate = 1.5, effectIntensity = 1.3 },
    -- },
}

-- ========== ALCOHOL SYSTEM ==========
SubstancesConfig.Alcohol = {
    enabled = true,
    showThreshold = 5,
    maxAmount = 100,
    
    -- کاهش طبیعی
    naturalDecay = {
        enabled = true,
        interval = 20000,     -- الکل سریع‌تر کم می‌شود
        amount = 2,
    },
    
    -- افکت‌های مستی
    drunkEffects = {
        [1] = { min = 20, max = 40, blur = 300, cameraShake = 0.1 },
        [2] = { min = 40, max = 60, blur = 600, cameraShake = 0.2 },
        [3] = { min = 60, max = 80, blur = 1000, cameraShake = 0.3 },
        [4] = { min = 80, max = 90, blur = 1500, cameraShake = 0.4 },
        [5] = { min = 90, max = 100, blur = 2000, cameraShake = 0.5 },
    },
    
    -- الکل‌زدگی شدید
    severeDrunk = {
        enabled = true,       -- ✅ اضافه شد (بحرانی!)
        threshold = 85,
        chance = 0.1,         -- 10% احتمال stumble
        interval = 15000,
    },
}

-- ========== INTEGRATION ==========
SubstancesConfig.Integration = {
    saveToMetadata = true,
    metadataKey = "substances",
    events = {
        onConsume = "substances:client:onConsume",
        onDecay = "substances:client:onDecay",
        onOverdose = "substances:client:onOverdose",
        getLevel = "substances:server:getLevel",
        setLevel = "substances:server:setLevel",
    },
}

-- ========== PERMISSIONS ==========
SubstancesConfig.Permissions = {
    adminCommand = "admin",
    doctorJob = "ambulance",
}