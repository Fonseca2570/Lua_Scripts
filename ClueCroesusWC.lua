--[[
    Script:     Croesus WC
    Author:     Clue
    Version:    1.0

    Released:   28/04/2024

]]

local API = require("api")
startTime, afk = os.time(), os.time()

API.SetDrawTrackedSkills(true)

--[[Variables]]--

local normalGuards = {
    guard1 = 121756,
    guard2 = 121753, 
    guard3 = 121750, 
    guard4 = 121747
}
------------------------------------------------------------------------

local function idleCheck() 
    local timeDiff = os.difftime(os.time(), afk)
    local randomTime = math.random((5 * 60) * 0.6, (5 * 60) * 0.9)

    if timeDiff > randomTime then
        API.PIdle2()
        afk = os.time()
    end
end

local function findNonEnrich() 
    local objs = API.ReadAllObjectsArray({12}, {normalGuards.guard1, normalGuards.guard2, normalGuards.guard3, normalGuards.guard4 }, {})
    for _, obj in ipairs(objs) do
        if obj.Bool1 == 0 then
            return obj
        end
    end
    return nil
end 

local function findEnrich()
    local objs = API.ReadAllObjectsArray({12}, {normalGuards.guard1, normalGuards.guard2, normalGuards.guard3, normalGuards.guard4 }, {})
    for _, obj in ipairs(objs) do
        if obj.Bool1 == 1 then 
            return obj
        end
    end
    return findNonEnrich()
end


while (API.Read_LoopyLoop()) do
    API.DoRandomEvents()
    idleCheck()
    local level = API.GetSkillByName("WOODCUTTING").level
    if not API.CheckAnim(80) then 
        if level >= 92 then 
            obj = findEnrich()
            if obj ~= nil then 
                API.API.DoAction_Object1(0x3b, API.OFF_ACT_GeneralObject_route0, {obj.Id}, 50)
                API.RandomSleep2(2000, 600, 900)
            end
        else
            obj = findNonEnrich()
            if obj ~= nil then 
                API.DoAction_Object1(0x3b, API.OFF_ACT_GeneralObject_route0, {obj.Id}, 50)
                API.RandomSleep2(2000, 600, 900)
            end
        end
    end
    API.RandomSleep2(2000, 600, 900)
end
