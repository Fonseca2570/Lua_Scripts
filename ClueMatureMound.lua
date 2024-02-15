--[[
# Script Name:   <manure mound>
# Description:  <easy early farming xp>
# Autor:        <Clue>
# Version:      <1.0>
# Datum:        <2024.01.14>


#Instructions:
> Start next to the manure mound in ardougne POF

#Comments:
> Use this only on early levels the xp is really bad at 3.7k xp/hr

#Idea taken from FURY video on getting level 30 farming
#Any bugs just contact
--]]

local API = require("api")
local UTILS = require("utils")

local startTime, afk = os.time(), os.time()
local MAX_IDLE_TIME_MINUTES = 5
local skillName = "FARMING"
local startXp = API.GetSkillXP(skillName);
local stateXp = startXp
local IGP = API.CreateIG_answer()
IGP.box_start = FFPOINT.new(5, 5, 0)
IGP.box_name = "PROGRESSBAR"
IGP.colour = ImColor.new(0, 153, 0);

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
    local gameState = API.GetGameState()
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

-- Format script elapsed time to [hh:mm:ss]
local function formatElapsedTime(startTime)
    local currentTime = os.time()
    local elapsedTime = currentTime - startTime
    local hours = math.floor(elapsedTime / 3600)
    local minutes = math.floor((elapsedTime % 3600) / 60)
    local seconds = elapsedTime % 60
    return string.format("[%02d:%02d:%02d]", hours, minutes, seconds)
end

-- Rounds a number to the nearest integer or to a specified number of decimal places.
local function round(val, decimal)
    if decimal then
        return math.floor((val * 10 ^ decimal) + 0.5) / (10 ^ decimal)
    else
        return math.floor(val + 0.5)
    end
end

local function formatNumber(num)
    if num >= 1e6 then
        return string.format("%.1fM", num / 1e6)
    elseif num >= 1e3 then
        return string.format("%.1fK", num / 1e3)
    else
        return tostring(num)
    end
end

local function calcProgressPercentage(skill, currentExp)
    local currentLevel = API.XPLevelTable(API.GetSkillXP(skill))
    if currentLevel == 120 then return 100 end
    local nextLevelExp = XPForLevel(currentLevel + 1)
    local currentLevelExp = XPForLevel(currentLevel)
    local progressPercentage = (currentExp - currentLevelExp) / (nextLevelExp - currentLevelExp) * 100
    return math.floor(progressPercentage)
end

local function printProgressReport()
    local currentXp = API.GetSkillXP(skillName)
    local elapsedMinutes = (os.time() - startTime) / 60
    local diffXp = math.abs(currentXp - startXp);
    local xpPH = round((diffXp * 60) / elapsedMinutes);
    local time = formatElapsedTime(startTime)
    local currentLevel = API.XPLevelTable(API.GetSkillXP(skillName))
    if diffXp > 0 then
        stateXp = stateXp + diffXp;
    end
    IGP.radius = calcProgressPercentage(skillName, API.GetSkillXP(skillName)) / 100
    IGP.string_value = time ..
        " | " ..
        string.lower(skillName):gsub("^%l", string.upper) ..
        ": " .. currentLevel .. " | XP/H: " .. formatNumber(xpPH) .. " | XP: " .. formatNumber(diffXp)
end


local function drawGUI()
    API.DrawProgressBar(IGP, false)
    printProgressReport()
end


local function getPlayerAnimation()
    return API.GetPlayerAnimation_(API.GetLocalPlayerName())
end

API.Write_LoopyLoop(true)
while API.Read_LoopyLoop() do
    drawGUI()
    gameStateChecks()
    idleCheck()
    while getPlayerAnimation() == 32263 do
        API.RandomSleep2(1000,1200,1500)
    end

    API.DoAction_Object1(0x29,0, { 112276 },50)
    API.RandomSleep2(2000,2100,3000)

end