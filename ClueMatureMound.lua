--[[
# Script Name:   <manure mound>
# Description:  <easy early farming xp>
# Autor:        <Clue>
# Version:      <1.1>
# Datum:        <2024.06.02>


#Instructions:
> Start next to the manure mound in ardougne POF

#Comments:
> Use this only on early levels the xp is really bad at 3.7k xp/hr

#Idea taken from FURY video on getting level 30 farming
#Any bugs just contact

#Changelog:
> Updated the code to work better
--]]

local API = require("api")
local UTILS = require("utils")

local startTime, afk = os.time(), os.time()
local MAX_IDLE_TIME_MINUTES = 5


local function idleCheck()
    local timeDiff = os.difftime(os.time(), afk)
    local randomTime = math.random((MAX_IDLE_TIME_MINUTES * 60) * 0.6, (MAX_IDLE_TIME_MINUTES * 60) * 0.9)

    if timeDiff > randomTime then
        API.PIdle2()
        afk = os.time()
        return true
    end
end

local function gameStateChecks()
    local gameState = API.GetGameState2()
    if (gameState ~= 3) then
        print('Not ingame with state:', gameState)
        API.Write_LoopyLoop(false)
        return
    end
    if API.InvFull_() then
        print('inventory full, stopping')
        API.Write_LoopyLoop(false)
        return
    end
end

API.SetDrawTrackedSkills(true)

while API.Read_LoopyLoop() do
    API.DoRandomEvents()
    gameStateChecks()
    idleCheck()
    if API.CheckAnim(60) then
        goto continue
    end

    API.DoAction_Object1(0x29,0, { 112276 },50)
    API.RandomSleep2(2000,2100,3000)

    ::continue::
    API.RandomSleep2(1000,1200,1500)
end