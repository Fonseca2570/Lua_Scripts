--[[
# Script Name:  ClueMenaphosSandstoneMining
# Description:  <Mining menaphos>
# Instructions: Start inside vip area are load last preset something decent for mining
# Autor:        <Clue (discord)>
# Version:      <1.0>
# Datum:        <2024.03.31>
--]]

-- imports
local API = require("api")
local UTILS = require("utils")


-- variables
local startXp = API.GetSkillXP("MINING")
local MAX_IDLE_TIME_MINUTES = 5
local afk = os.time()

API.SetDrawLogs(true)
API.SetDrawTrackedSkills(true)

local IDS = {
    Sandstone = 112966,
    StaminaVB = 8308
}

-- helper functions
local function checkXpIncrease() 
    local newXp = API.GetSkillXP("MINING")
    if newXp == startXp then 
        API.logError("no xp increase")
        API.Write_LoopyLoop(false)
    else
        startXp = newXp
    end
end

local function idleCheck()
    local timeDiff = os.difftime(os.time(), afk)
    local randomTime = math.random((MAX_IDLE_TIME_MINUTES * 60) * 0.6, (MAX_IDLE_TIME_MINUTES * 60) * 0.9)

    if timeDiff > randomTime then
        API.PIdle2()
        afk = os.time()
        -- comment this check xp if 200M
        checkXpIncrease()
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
    if not API.PlayerLoggedIn() then
        API.logDebug('Not Logged In')
        API.Write_LoopyLoop(false)
        return;
    end
end


local function isMoving() 
    return API.ReadPlayerMovin()
end

local function mine() 
    API.DoAction_Object1(0x3a,API.OFF_ACT_GeneralObject_route0,{ IDS.Sandstone },50);
    API.RandomSleep2(600,200,400)
    API.WaitUntilMovingEnds()
end

while(API.Read_LoopyLoop()) do 
    API.DoRandomEvents()
    idleCheck()
    gameStateChecks()

    if API.VB_FindPSett(IDS.StaminaVB).state > math.random(1000,1300) then 
        mine()
    end

    if not API.CheckAnim(20) and not isMoving() then 
        if API.InvFull_() then 
            API.DoAction_Object_string1(0x5, API.OFF_ACT_GeneralObject_route3, {"Bank chest"}, 50, true)
            API.RandomSleep2(600,200,400)
            API.WaitUntilMovingEnds()
        else 
            mine()
        end
    end
end