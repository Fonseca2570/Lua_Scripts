--[[
# Script Name:  ClueBonfire
# Description:  <Bonfires at priff>
# Autor:        <Clue (discord)>
# Version:      <1.0>
# Datum:        <2024.04.11>
--]]

-- imports
local API = require("api")
local UTILS = require("utils")


-- variables
local startXp = API.GetSkillXP("FIREMAKING")
local MAX_IDLE_TIME_MINUTES = 5
local afk = os.time()

local Names = {
    Bonfire = "Bonfire",
    Banker = "Banker"
}

-- draw gui and log box
API.SetDrawLogs(true)
API.SetDrawTrackedSkills(true)

-- helper functions
local function checkXpIncrease() 
    local newXp = API.GetSkillXP("FIREMAKING")
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

while(API.Read_LoopyLoop()) do 
    API.DoRandomEvents()
    idleCheck()
    gameStateChecks()

    if not API.CheckAnim(80) and not isMoving() then 
        if not API.InvFull_() then 
            API.DoAction_NPC_str(0x33, API.OFF_ACT_InteractNPC_route4, {Names.Banker}, 50 )
            API.RandomSleep2(600,200,400)
            API.WaitUntilMovingEnds()
            if not API.InvFull_ then 
                API.Write_LoopyLoop(false)
            end
        else
            API.logDebug("Firemaking")
            API.DoAction_Object_string1(0x41,API.OFF_ACT_GeneralObject_route0,{ Names.Bonfire }, 50, true)
            API.RandomSleep2(1200,400,800)
        end
    end

    API.RandomSleep2(1200,500,1000)
end