local API = require('api')
local UTILS = require('utils')

API.SetDrawLogs(true)
API.SetDrawTrackedSkills(true)

local MAX_IDLE_TIME_MINUTES = 5
local startTime, afk = os.time(), os.time()
local states = {
    Bank = 0,
    Logs = 1,
    Plank = 2,
    Refined = 3,
    Frames = 4
}

local fails = 0

local types = {
    Logs = "LOG",
    Planks = "PLANK",
    Refined = "REFINED",
    Frame = "FRAME"
}

local state = states.Bank

-- setup
local finishState = states.Frames

--functions
local function idleCheck()
    local timeDiff = os.difftime(os.time(), afk)
    local randomTime = math.random((MAX_IDLE_TIME_MINUTES * 60) * 0.6, (MAX_IDLE_TIME_MINUTES * 60) * 0.9)

    if timeDiff > randomTime then
        API.PIdle2()
        afk = os.time()
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

-- checks
local function isBusy() 
    return API.isProcessing() or API.ReadPlayerMovin()
end

local function checkState()
    API.logDebug("checking state") 
    local firstItem = API.ReadInvArrays33()[1].textitem
    firstItem = string.upper(firstItem)
    if string.find(firstItem, types.Refined) ~= nil then 
        if state ~= states.Refined then 
            fails = 0
        end
        return states.Refined
    end

    if string.find(firstItem, types.Logs) ~= nil then 
        if state ~= states.Logs then 
            fails = 0
        end
        return states.Logs
    end

    if string.find(firstItem, types.Planks) ~= nil then 
        if state ~= states.Plank then 
            fails = 0
        end
        return states.Plank
    end

    if string.find(firstItem, types.Frame) ~= nil then 
        if state ~= states.Frames then 
            fails = 0
        end
        return states.Frames
    end

    return states.Bank
end

local function isInterfaceOpen()
    return API.VB_FindPSett(2874, -1, 0).state == 1310738
end

local function loadLastPreset() 
    API.DoAction_Object1(0x33, API.OFF_ACT_GeneralObject_route3, {125115}, 50)
    API.RandomSleep2(500,700,800)
end

local function openInterface()
    local offset; if state == states.Refined then offset = 0xae else offset = 0x29 end

    if state == states.Refined then 
        API.DoAction_Object_string1(offset, API.OFF_ACT_GeneralObject_route0, {"Woodworking bench"}, 20, true)
        API.RandomSleep2(600,200,400)
        return
    end 

    API.DoAction_Object_string1(offset, API.OFF_ACT_GeneralObject_route0, {"Sawmill"}, 20, true)
end

local function startCraft() 
    API.KeyboardPress2(0x20, 0, 50) -- presses spacebar
end

local function hasMaterials() 
    return API.Invfreecount_() < 5
end

while API.Read_LoopyLoop() do 
    idleCheck()
    API.DoRandomEvents()
    gameStateChecks()

    if not isBusy() then 
        if isInterfaceOpen() then 
            API.logDebug("interface is open start crafting")
            startCraft()
            API.RandomSleep2(1000,500,1000)
            goto continue
        end

        if state == states.Bank then 
            API.logDebug("state is banking go to bank load last preset")
            loadLastPreset()
            -- check material count
            API.RandomSleep2(600,200,400)
            if not hasMaterials() then 
                fails = fails + 1
                if fails > 2 then 
                    API.Write_LoopyLoop(false)
                end
            end

            if hasMaterials() then 
                fails = 0
                state = checkState()
            end
            goto continue
        end

        state = checkState()
        API.logDebug("state : ", state)
        if state == finishState then 
            API.logDebug("last state reached change state to banking")
            state = states.Bank
            goto continue
        end

        if state ~= states.Bank then 
            API.logDebug("opening interface")
            openInterface()
        end 
    end

    ::continue::
    API.RandomSleep2(1200, 200, 400)
end