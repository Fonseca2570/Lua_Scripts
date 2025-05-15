--[[
# Script Name:  ClueHermod
# Description:  <Hermod Farming>
# Instructions: start at war retreat with last preset loaded
# Autor:        <Clue (discord)>
# Version:      <1.0>
# Datum:        <2024.03.30>
--]]

-- imports
local API = require("api")
local ClueUtils = require("ClueUtils")
local PrayerFlicker = require("Private.prayer_flicker")
local MAX_IDLE_TIME_MINUTES = 5
local startTime, afk = os.time(), os.time()
local fail = 0
local CurrentState = 0

local States = {
    Bank = 0,
    BossLobby = 1,
    BossFight = 2
}

local Locations = {
    WarRetreat = {x1 = 3279, x2 = 3309, y1 = 10113, y2 = 10143},
    BossLobby = {x1= 850, x2 = 870, y1 = 1730, y2 = 1750}
}

local IDS = {
    Bank = 114750,
    Altar = 114748,
    Hermod = 30163,
    Minions = 30164,
    RightPortal = 127138,
    BossBarrier = 127142,
}

local BuffBar = {
    soulsplit = 26033,
}

local Names = {
    Shark = "Shark"
}

local PRAYER_CONFIG = {
    defaultPrayer = PrayerFlicker.PRAYERS.PROTECT_FROM_MAGIC
}

local prayerFlicker = PrayerFlicker.new(PRAYER_CONFIG)

local LootTable = {
    989, --crystal key 
    54018, -- elemental anima stone 
    12176, -- spirit weed seed      
    48768, -- carambola seed
    44811, -- necrite stone spirit 
    44813, -- banite stone spirit
    42954, -- onyx dust 
    55191, -- hermodic plate  
    55216, -- animated drumsticks  
    55673, -- hermod pet 
    52946, -- small bladed Orichalcite
    7937, -- pure essence
    55628, -- memento
    1632, -- dragonstone
    53504, --tiny blade necronium
    47283, -- rune blade
    55630 --memento
}

-- helper functions

local function AtLocation(loc) 
    return API.PInArea21(loc.x1, loc.x2, loc.y1, loc.y2)
end

local function updateState() 
    if not API.ReadPlayerMovin() then 
        if AtLocation(Locations.WarRetreat) then 
            CurrentState = States.Bank
            return
        end

        if AtLocation(Locations.BossLobby) then 
            CurrentState = States.BossLobby
            return
        end
    end
end


local function idleCheck()
    local timeDiff = os.difftime(os.time(), afk)
    local randomTime = math.random((MAX_IDLE_TIME_MINUTES * 60) * 0.6, (MAX_IDLE_TIME_MINUTES * 60) * 0.9)

    if timeDiff > randomTime then
        API.PIdle2()
        updateState()
        afk = os.time()
        return true
    end
end

local function gameStateChecks()
    local gameState = API.GetGameState2()
    if (gameState ~= 3) then
        API.logDebug('Not ingame with state:', gameState)
        API.Write_LoopyLoop(false)
        return
    end
end

local function TeleportWarRetreat() 
    ClueUtils.DoAbility2(ClueUtils.AbilitiesID.Teleports.WarRetreatTeleport)
    API.RandomSleep2(2000,1000,2000)
    API.WaitUntilMovingandAnimEnds()
end

local function praySoulSplit() 
    ClueUtils.ActivatePrayer(ClueUtils.AbilitiesID.Curses.SoulSplit, ClueUtils.BuffBar.soulsplit)
end

local function IsHermodAlive() 
    local hermod = API.GetAllObjArray1({IDS.Hermod}, 50, {1})[1]
    if hermod ~= nil then 
        return true
    end

    return false
end

local function isportalInterfaceOpen() 
    return API.VB_FindPSett(2874, 1, 0).state == 18
end

local function openLootWindow() 
    if not API.LootWindowOpen_2() then 
        print("loot window not open")
        result = API.GetAllObjArray1(LootTable ,50,{3})
        for _, obj in ipairs(result) do 
            if obj ~= nil then
                print("found anima")
                API.KeyboardPress("\\", 100, 200)
                API.RandomSleep2(1000,500,1000)
                return
            end
        end
    end
end

local function deactivateSoulSplit() 
    ClueUtils.DeactivatePrayer(ClueUtils.AbilitiesID.Curses.SoulSplit, ClueUtils.BuffBar.soulsplit)
end

local function needBank() 
    return API.InvItemcount_String(Names.Shark) < 5 or API.GetPrayPrecent() < 90
end

local function healthCheck()
    local hp = API.GetHPrecent()
    if hp < 60 then
        if ClueUtils.IsAbilityAvailableID(ClueUtils.AbilitiesID.HP.EatFood) then
            print("Eating")
            ClueUtils.DoAbility2(ClueUtils.AbilitiesID.HP.EatFood)
            API.RandomSleep2(600, 600, 600)
        end
        elseif hp < 20 or API.InvItemcount_String(Names.Shark) < 1 then
            print("Teleporting out")
            ClueUtils.DoAbility2(ClueUtils.AbilitiesID.Teleports.WarRetreatTeleport)
            CurrentState = States.Bank
            API.RandomSleep2(3000, 3000, 3000)
    end
end

local function loadLastPreset() 
    API.DoAction_Object_string1(0x33,API.OFF_ACT_GeneralObject_route3,{ "Bank chest" },50, true)
end

-- script function

local function loot() 
    openLootWindow()

    if API.LootWindowOpen_2() and (API.LootWindow_GetData()[1].itemid1 > 0) then
        print("First Loot All Attempt")
        API.DoAction_LootAll_Button()
        API.RandomSleep2(1000, 250, 250)
        deactivateSoulSplit()
        API.RandomSleep2(600,100,300)
        API.DoAction_Ability("War's Retreat Teleport", 1, API.OFF_ACT_GeneralInterface_route)
        API.RandomSleep2(3000, 1000, 2000)
        CurrentState = States.Bank
    end
end

local function isFightingMinion() 
    local id = API.Local_PlayerInterActingWith_Id()
    if id == IDS.Minions then 
        return true
    end

    return false
end

local function WarRetreatMagic()
    if needBank() then
        fail = fail + 1
        if fail > 3 then 
            API.Write_LoopyLoop(false)
        end

        API.RandomSleep2(600,0,0)
        if API.GetPrayPrecent() < 90 then 
            -- Altar
            API.DoAction_Object1(0x3d,API.OFF_ACT_GeneralObject_route0,{IDS.Altar} ,50)
            API.RandomSleep2(600,0,0)
            API.WaitUntilMovingandAnimEnds()
            API.RandomSleep2(1200,0,0)
        end

        loadLastPreset()
        API.RandomSleep2(600,0,0)
        API.WaitUntilMovingEnds()

    else
        fail = 0
        API.DoAction_Object1(0x39, API.OFF_ACT_GeneralObject_route0, {IDS.RightPortal}, 50)
        API.RandomSleep2(600, 500, 600)
        CurrentState = States.BossLobby
        API.WaitUntilMovingEnds()
    end
end

local function BossLobby()
    if isportalInterfaceOpen() and not API.ReadPlayerMovin2() then
        API.DoAction_Interface(0x24,0xffffffff,1,1591,60,-1,API.OFF_ACT_GeneralInterface_route)
        API.RandomSleep2(600, 600, 400)
        CurrentState = States.BossFight
    else
        API.DoAction_Object1(0x39, API.OFF_ACT_GeneralObject_route0, {IDS.BossBarrier}, 50)
        API.RandomSleep2(600, 600, 400)
        API.WaitUntilMovingEnds()
    end

end

local function BossFight()
    praySoulSplit()
    local minion = API.GetAllObjArray1({IDS.Minions}, 50, {1})[1]
    if minion ~= nil and not isFightingMinion() then 
        API.DoAction_NPC(0x2a,API.OFF_ACT_AttackNPC_route, {IDS.Minions}, 50)
        return
    end

    if minion == nil then 
        local id = API.Local_PlayerInterActingWith_Id()
        if id ~= IDS.Hermod then 
            API.DoAction_NPC(0x2a,API.OFF_ACT_AttackNPC_route, {IDS.Hermod}, 50)
            return
        end
    end
end

API.SetDrawLogs(true)
API.SetDrawTrackedSkills(true)

while API.Read_LoopyLoop() do 
    API.DoRandomEvents()
    idleCheck()
    gameStateChecks()
    if CurrentState == States.Bank and not API.ReadPlayerMovin() then 
        if not AtLocation(Locations.WarRetreat) then 
            TeleportWarRetreat()
        end
        WarRetreatMagic()
    end

    if CurrentState == States.BossLobby and not API.ReadPlayerMovin() then 
        if not AtLocation(Locations.BossLobby) then 
            TeleportWarRetreat()
            CurrentState = States.Bank
            return
        end

        BossLobby()
    end

    if CurrentState == States.BossFight then 
        if IsHermodAlive() then 
            healthCheck()
            BossFight()
        else
            loot()
        end
    end
    API.RandomSleep2(600,0,100)
end