# Elixir FW - HUD System V2 4.0 - by Elixir FW

- Hello, first of all thank you for purchasing our script !
- Don't forget to configure the shared/config.lua file according to your server.
- Feel free to open a support Ticket to resolve your problem/question. - Elixir FW -
- For HUD Settings Panel: Command: /hud
- Please check the Index.HTML to make the translation to your language

# Discord: 

# Elixir FW Discord: https://discord.gg/ErC9mfYakh


# Radio Channel Exports: 
## (you can verify how to do in our qb-radio resource)

exports['qrt-hud']:radioenter(true, channel) // PUT IN YOUR RADIO RESOURCE

- Talking on Radio Export: 

exports["qrt-hud"]:talking(true, true) // PUT IN YOUR VOICE RESOURCE ON KEYBIND FOR RADIO TALKING

- Pursuit Mode Export:

exports["qrt-hud"]: SendPursuitValue(howmuch) // PUT IN YOUR PURSUIT RESOURCE FOR PURSUIT MODE (If you don't want to use the one that we provided on HUD)




-- مصرف مواد
TriggerServerEvent('substances:server:consumeDrug', 20)  -- 20 واحد

-- مصرف الکل
TriggerServerEvent('substances:server:consumeAlcohol', 15)  -- 15 واحد

-- چک کردن سطح (برای دکتر)
QBCore.Functions.TriggerCallback('substances:server:getLevel', function(substances)
    print('Drug level:', substances.drug)
    print('Alcohol level:', substances.alcohol)
end, targetPlayerId)

-- استفاده از exports
local drugLevel = exports['qrt-hud']:GetDrugLevel()
local alcoholLevel = exports['qrt-hud']:GetAlcoholLevel()

-- تنظیم سطح (ادمین)
exports['qrt-hud']:SetDrugLevel(playerId, 50)
exports['qrt-hud']:SetAlcoholLevel(playerId, 30)





/checksubstances [player-id]  -- چک کردن سطح مواد (دکتر/ادمین)
/setdrug [player-id] [amount]  -- تنظیم سطح مواد (ادمین)
/setalcohol [player-id] [amount]  -- تنظیم سطح الکل (ادمین)