--[[
# Script Name:   <Arch glacor>
# Description:  <kill them all>
# Autor:        <Clue>
# Version:      <1.0>
# Datum:        <2024.01.21>


#Instructions:


#Comments:
    Still in produce

#Any bugs just contact
--]]

local API , UTILS = require('api', 'utils')

local state = "at_bank"
local warRetreat = API.GetABs_name1("War's Retreat Teleport")
local eatFoodAB = API.GetABs_name1("Eat Food")
local instanceTimer = os.time()
local MAX_IDLE_TIME_MINUTES = 5
local anima = 51809
local afk = os.time()

local function idleCheck()
    local timeDiff = os.difftime(os.time(), afk)
    local randomTime = math.random((MAX_IDLE_TIME_MINUTES * 60) * 0.6, (MAX_IDLE_TIME_MINUTES * 60) * 0.9)

    if timeDiff > randomTime then
        API.PIdle2()
        afk = os.time()
        return true
    end
end

local function isMoving() 
    return API.ReadPlayerMovin()
end

local function teleportWarRetreat()
    if warRetreat.ID ~= 0 and warRetreat.enabled then
        API.DoAction_Ability_Direct(warRetreat, 1, API.OFF_ACT_GeneralInterface_route)

        while not API.PInArea21(3294,3295,10127,10128) do 
            API.RandomSleep2(1000,500,750)
        end
    end

    state = "at_bank"

    API.RandomSleep2(1000, 500, 1000)
end

local function heal()
    if state == "combat" then 
        local hp = API.GetHPrecent()
        if hp < 50 then 
            if eatFoodAB.ID ~= 0 and eatFoodAB.enabled then 
                API.DoAction_Ability_Direct(eatFoodAB, 1, API.OFF_ACT_GeneralInterface_route)
                API.RandomSleep2(500, 250, 500)
            end
        end

        if hp < 30 then 
            teleportWarRetreat()
        end
    end
end

local function checkTimer()
    local timeDiff = os.difftime(os.time(), instanceTimer)
    local randomTime = math.random((60 * 60) * 0.8, (60 * 60) * 0.9)

    if timeDiff > randomTime then 
        teleportWarRetreat()
    end
end

local function openLootWindow() 
    if not API.LootWindowOpen_2() then 
        print("loot window not open")
        result = API.GetAllObjArray1({anima},7,3)
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

local function loot()
    openLootWindow()

    if API.LootWindowOpen_2() and (API.LootWindow_GetData()[1].itemid1 > 0) then
        print("First Loot All Attempt")
        API.DoAction_LootAll_Button()
        API.RandomSleep2(1000, 250, 250)
    end
end

local function healAtBank()
    -- move next to bank
    if state == "at_bank" then 
        local point = WPOINT.new(3299 + math.random(-1, 0), 10131, 0)
        API.DoAction_WalkerW(point)

        while isMoving() do 
            API.RandomSleep2(500,200,400)
        end

        -- wait till hp is full
        while API.GetHPrecent() < 95 do 
            API.RandomSleep2(500,200,400)
        end

        state = "ready_for_portal"
        print(state)
    end
end

local function enterPortal()
    if state == "ready_for_portal" then 
        print("press the portal")
        API.DoAction_Object1(0x39, 0, {121370}, 50)

        API.RandomSleep2(7000,1000,2000)
    
        state = "create_instance"
    end
    print(state)
end

local function startInstance()
    if state == "create_instance" then 
        if not API.PInArea21(1754,1755,1112,1113) then 
            return
        end

        API.DoAction_Object1(0x39, 0, {121338}, 50)

        API.RandomSleep2(5000,500,1000)

        while API.CheckAnim(20) do 
            print("sleep is animating")
            API.RandomSleep2(1000,500,1000)
        end

        API.DoAction_Interface(0x24,0xffffffff,1,1591,60,-1,3808)

        API.RandomSleep2(5000,500,1000)

        print("getting here")

        local playerCoord = API.PlayerCoord()
        local point = WPOINT.new(playerCoord.x + math.random(14, 16), playerCoord.y + math.random(-4, -2), 1)
        API.DoAction_WalkerW(point)
        API.RandomSleep2(500,500,1000)

        instanceTimer = os.time()

        state = "combat"
    end
end

--local function moveToCenter()
--    if state == "combat" then 
--        if not API.PInArea21(14365,14374,3750,3780) then 
--            local point = WPOINT.new(14369 + math.random(-1, 1), 3757 + math.random(-1, 1), 1)
--            --API.DoAction_WalkerW(point)
--            API.DoAction_WalkerW(point)
--            API.RandomSleep2(500,500,1000)
--    
--            state = "combat"
--        end
--    end
--end

API.Write_LoopyLoop(true)
teleportWarRetreat()
while API.Read_LoopyLoop() do 
    idleCheck()
    healAtBank()
    API.RandomSleep2(1000,500,1000)
    enterPortal()
    API.RandomSleep2(1000,500,1000)
    startInstance()
    API.RandomSleep2(1000,500,1000)
    --moveToCenter()
    heal()
    loot()
    checkTimer()
end