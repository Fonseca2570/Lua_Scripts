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
local warRetreat = API.GetABs_name1("War Retreat")
local eatFoodAB = API.GetABs_name1("Eat Food")

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
    end

    state = "at_bank"

    API.RandomSleep2(1000, 500, 1000)
end

local function heal()
    local hp = API.GetHPrecent()
    if hp < 50 then 
        if eatFoodAB.ID ~= 0 and eatFoodAB.enabled then 
            API.DoAction_Ability_Direct(eatFoodAB, 1, API.OFF_ACT_GeneralInterface_route)
            UTILS.randomSleep(600)
        else
            teleportWarRetreat()
        end
    end
end

local function checkTimer()
end

local function loot()
    if API.LootWindowOpen_2() and (API.LootWindow_GetData()[1].itemid1 > 0) then
        print("First Loot All Attempt")
        API.DoAction_LootAll_Button()
        API.RandomSleep2(1000, 250, 250)
    end
end

local function healAtBank()
    -- move next to bank
    local point = WPOINT.new(1164 + math.random(-1, 1), 1827 + math.random(-1, 1), 1) -- TODO this coodinates are not right
    API.DoAction_WalkerW(point)

    -- wait till hp is full
    while API.GetHPrecent() < 95 do 
        API.RandomSleep2(500,200,400)
    end

    state = "ready_for_portal"
end

local function enterPortal()
    API.DoAction_Object1(0x39, 0, {127376}, 50) -- TODO ids are wrong

    while isMoving() do 
        API.RandomSleep2(500,500,1000)
    end

    state = "create_instance"
end

local function startInstance()
end

local function moveToCenter()
    local point = WPOINT.new(1164 + math.random(-1, 1), 1827 + math.random(-1, 1), 1) -- TODO this coodinates are not right
    API.DoAction_WalkerW(point)
end

API.Write_LoopyLoop(true)

while API.Read_LoopyLoop() do 

end