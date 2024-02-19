--[[
# Script Name:  ClueMenaphosFishing
# Description:  <Fishing menaphos>
# Instructions: if you don't have the perk for baits put line 21 to true
# Start near the port fishing spot not the vip
# Autor:        <Clue (discord)>
# Version:      <1.0>
# Datum:        <2024.02.19>
--]]

-- imports
local API = require("api")
local UTILS = require("utils")


-- variables
local startXp = API.GetSkillXP("FISHING")
local MAX_IDLE_TIME_MINUTES = 5
local afk = os.time()
local FishingSpot = 24572
local checkBait = false
local depositBank = 107496
local bait = 313

-- draw gui and log box
API.SetDrawLogs(true)
API.SetDrawTrackedSkills(true)

-- helper functions
local function checkXpIncrease() 
    local newXp = API.GetSkillXP("FISHING")
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

    if not API.CheckAnim(100) and not isMoving() then 
        if checkBait and API.InvStackSize(bait) == 0 then 
            API.logWarn("Out of bait")
            API.Write_LoopyLoop(false)
        end

        if API.InvFull_() then 
            API.logDebug("Depositing")
            API.DoAction_Object1(0x29,4128,{ depositBank },50); 
            API.RandomSleep2(1200,400,800)
        else
            API.logDebug("Fishing")
            API.DoAction_NPC(0x3c,API.OFF_ACT_InteractNPC_route,{ FishingSpot },50);
            API.RandomSleep2(1200,400,800)
        end
    end

    API.RandomSleep2(1200,500,1000)
end