--[[
# Script Name:   <impure RC>
# Description:  <nice money making>
# Autor:        <Clue>
# Version:      <1.0>
# Datum:        <2024.01.21>


#Instructions:
> um book on hotkey 1
> have surge on the ability bar 
> it loads previous preset

#Comments:
    Needs improvement for familiar
    Needs improvement for bladed dive

#Any bugs just contact
--]]


local API = require("api")
local UTILS = require("utils")

-- Local variables -----------------------
local spiritAltar = 127380
local boneAltar = 127381
local fleshAltar = 127382
local miasmaAltar = 127383
local impureEssence = 55667
local surgeAB = API.GetABs_name1("Surge")

-- Active altar just change for one of the others if needed
local activeAltar = miasmaAltar


-- start of boilerplate gui

local startTime, afk = os.time(), os.time()
local MAX_IDLE_TIME_MINUTES = 5
local skillName = "RUNECRAFTING"
local startXp = API.GetSkillXP(skillName);
local stateXp = startXp
local IGP = API.CreateIG_answer()
IGP.box_start = FFPOINT.new(5, 5, 0)
IGP.box_name = "PROGRESSBAR"
IGP.colour = ImColor.new(255, 255, 0);

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

-- end of boilerplate gui

local function isMoving() 
    return API.ReadPlayerMovin()
end


local function isInventoryFull() 
    return API.InvFull_()
end


local function isAtBank() 
    return API.PInArea21(1141, 1150, 1798,1812)
end


local function isAtRCAlter() 
    return API.PInArea21(1290, 1328, 1930, 1975)
end


local function enterAlter() 
    -- just some sleep can be improved
    API.RandomSleep2(1000,1000,1500)
    API.DoAction_Object1(0x39, 0, {127376}, 50)
    API.RandomSleep2(1000,1000,1500)
end

local function isBankOpen()
	return API.BankOpen2()
end


local function openBank() 
    API.DoAction_Object_string1(0x2e, API.OFF_ACT_GeneralObject_route1, "Bank chest", 20, true)
    API.RandomSleep2(500,700,800)
end

local function loadLastPreset() 
    -- todo maybe this is better then open bank
    API.DoAction_Object1(0x33, 240, {127271}, 50)
    API.RandomSleep2(500,700,800)
end


local function craftRunes() 
    API.DoAction_Object1(0x29, 0, {activeAltar}, 50)
    API.RandomSleep2(2000,2000,2500)
end


local function teleport() 
    API.KeyboardPress2(0x31, 0, 50) -- presses 1
    API.RandomSleep2(1000,1000,1500)
end


local function getPlayerAnimation()
    return API.GetPlayerAnimation_(API.GetLocalPlayerName())
end


local function checkIfOutOfEssence() 
    if API.InvItemcount_1(impureEssence) < 1 then
        API.Write_LoopyLoop(false)
    end
end

local function isAtStairs() 
    return API.PInArea21(1137, 1144, 1826, 1828)
end

local function nextToPortalFallback() 
    if API.PInArea21(1161,1167,1822,1832) then
        enterAlter()
    end
end

local function surge() 
    if surgeAB.id ~= 0 and surgeAB.enabled then
        API.DoAction_Ability_Direct(surgeAB, 1, API.OFF_ACT_GeneralInterface_route)
        UTILS.randomSleep(600)
    end
end

local function walkToBlackPortal() 
    local point = WPOINT.new(1164 + math.random(-3, 0), 1827 + math.random(-3, 0), 1)
    API.DoAction_WalkerW(point)
end

local function hasFam()
    return API.Buffbar_GetIDstatus(26095).id > 0
end


API.Write_LoopyLoop(true)

while API.Read_LoopyLoop() do 
    drawGUI()
    gameStateChecks()
    idleCheck()
    API.RandomEvents()
    if not isMoving() then 
        if isAtBank() and not isInventoryFull() then
            loadLastPreset()
        elseif isAtBank() and isInventoryFull() then
            walkToBlackPortal()
            checkIfOutOfEssence()
        elseif isAtRCAlter() and isInventoryFull() then
            craftRunes()
        elseif isAtRCAlter() and not isInventoryFull() and getPlayerAnimation() == -1 then
            teleport()
        elseif nextToPortalFallback() and isInventoryFull() then
            enterAlter()
        end
    else 
        if isAtStairs() then
            surge()
            enterAlter()
        end
    end

    API.RandomSleep2(300,500,700)
end
