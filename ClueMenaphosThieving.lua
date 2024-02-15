--[[
# Script Name:  ClueMenaphosThieving
# Description:  <Pickpockets menaphos merchants just start near them north of the lodestone in the bank>
# Autor:        <Clue (discord)>
# Version:      <1.0>
# Datum:        <2024.02.15>
--]]


-- imports
local API = require("api")


-- variables
local startXp = API.GetSkillXP("THIEVING")
local MAX_IDLE_TIME_MINUTES = 5
local afk = os.time()
local MenaphosNPC = { 24485 }
local StunHL = { 4531 }


-- draw gui and log box
API.SetDrawLogs(true)
API.SetDrawTrackedSkills(true)


-- helper functions
local function checkXpIncrease() 
    local newXp = API.GetSkillXP("THIEVING")
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
    local gameState = API.GetGameState()
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


local function PickPocket()
    API.DoAction_NPC(0x29,API.OFF_ACT_InteractNPC_route2, MenaphosNPC ,50);
end

local function IsStunned() 
    local highlights = API.GetAllObjArray1(StunHL, 1, 4)
    if #highlights > 0 then 
        return true
    end

    return false
end 


function healBank() 
    if API.GetHPrecent() < 80 then 
        API.logDebug("going to bank for healing")
        API.DoAction_Tile(WPOINT.new(3236 + math.random(0,1),2761+ math.random(0,1),0))

        API.RandomSleep2(5000,500,1000)

        API.WaitUntilMovingEnds()

        if API.PInArea21(3235,3238,2760,2762) then 
            while API.GetHPrecent() < 95 do 
                API.RandomSleep2(500,200,400)
            end
        end
    end
end

while(API.Read_LoopyLoop()) do
    API.DoRandomEvents()
    idleCheck()
    gameStateChecks()

    if not API.CheckAnim(40) and not IsStunned() then
        healBank()
        PickPocket()
    end
    
end