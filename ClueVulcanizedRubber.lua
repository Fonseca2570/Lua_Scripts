local API = require("api")
local UTILS = require("utils")

-- variables
local startXp = API.GetSkillXP("ARCHAEOLOGY")
local MAX_IDLE_TIME_MINUTES = 5
local afk = os.time()
local VulcanizedRubberCache = 116387 
local ClayCache = 116391
local depositAttempt = 0
local AutoScreener = 50161

-- draw gui and log box
API.SetDrawLogs(true)
API.SetDrawTrackedSkills(true)

-- helper functions
local function checkXpIncrease() 
    local newXp = API.GetSkillXP("ARCHAEOLOGY")
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

local function openBank() 
    API.DoAction_Object1(0x2e, API.OFF_ACT_GeneralObject_route1 , {115427}, 50)
end

local function Bank() 
    if not API.BankOpen2() then
        openBank()
    end
    depositAttempt = depositAttempt + 1;
    if depositAttempt > 3 then 
        API.Write_LoopyLoop(false)
    end 

    print("pressing 3")
    API.KeyboardPress("3",50,100)
    if not API.InvFull_() then
        depositAttempt = 0
    end
end

local function depositCart()
    API.logDebug('Inventory is full after using soilbox, trying to deposit: ' .. depositAttempt)
    depositAttempt = depositAttempt + 1;
    if depositAttempt > 3 then 
        API.Write_LoopyLoop(false)
    end 
    local cart = API.GetAllObjArrayInteract_str({ "Material storage container" }, 60, {0})
    if #cart > 0 then
        API.DoAction_Object_string1(0x29, API.OFF_ACT_GeneralObject_route0, { "Material storage container" },
            60, true);
        UTILS.randomSleep(800)
        API.WaitUntilMovingEnds()
        if not API.InvFull_() then
            depositAttempt = 0
        end
    else
        API.logWarn('Didn\'t find: Material storage container within 60 tiles')
    end
end


local function excavate() 
    local vulc = API.GetAllObjArray1({VulcanizedRubberCache},50, {12})
    for i = 1, #vulc do
        local v = vulc[i]
        if v.Bool1 == 0 then 
            API.logDebug("vulcanized rubber found")
            API.DoAction_Object_valid1(0x2,API.OFF_ACT_GeneralObject_route0,{VulcanizedRubberCache},50,true)
            API.RandomSleep2(600,200,300)
            return
        end
    end

    API.logDebug("NO vulcanized rubber found")

    local clay = API.GetAllObjArray1({ClayCache},50, {12})
    for i = 1, #clay do
        local c = clay[i]
        if c.Bool1 == 0 then 
            API.logDebug("clay found")
            API.DoAction_Object_valid1(0x2,API.OFF_ACT_GeneralObject_route0,{ClayCache},50,true)
            API.RandomSleep2(600,200,300)
            return
        end
    end

    API.RandomSleep2(5000,1000,2000)
end

local function HasAutoScreener() 
    return API.InvItemcount_1(AutoScreener) > 0
end

while(API.Read_LoopyLoop()) do
    API.DoRandomEvents()
    idleCheck()
    gameStateChecks()

    if not isMoving() and not API.CheckAnim(40) then 
        if API.InvFull_() then 
            if HasAutoScreener() then 
                depositCart()
            else
                Bank()
            end
            API.RandomSleep2(600,200,300)
        else
            excavate()
            API.RandomSleep2(600,200,300)
        end
    end
    
end