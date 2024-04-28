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

local enrichedGuards = {
    guard1 = 28436, -- TODO
    guard2 = 28433, -- TODO
    guard3 = 28427, -- TODO
    guard4 = 28430 -- TODO
}

local normalGuards = {
    guard1 = 28426, -- TODO
    guard2 = 28429, -- TODO
    guard3 = 28432, -- TODO
    guard4 = 28435 -- TODO
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

local function findEnrich()
    local objs = API.ReadAllObjectsArray({1}, {enrichedGuards.guard1, enrichedGuards.guard2, enrichedGuards.guard3, enrichedGuards.guard4 }, {})
    for _, obj in ipairs(objs) do
        for _, id in pairs(enrichedGuards) do
            if obj.Id == id then
                return true 
            end
        end
    end
    return false
end

local function harvestGuard()
    if not API.CheckAnim(80) and findEnrich() then
        print("[" .. os.date("%X") .. "] Enriched Found")
        API.DoAction_NPC(0x3c, API.OFF_ACT_InteractNPC_route, { enrichedGuards.guard1, enrichedGuards.guard2, enrichedGuards.guard3, enrichedGuards.guard4 }, 50)
        API.RandomSleep2(2000, 600, 900)
    elseif not API.CheckAnim(80) and not findEnrich() then
        print("[" .. os.date("%X") .. "] No Enriched. Harvesting Normal")
        API.DoAction_NPC(0x3c, API.OFF_ACT_InteractNPC_route, {normalGuards.guard1, normalGuards.guard2, normalGuards.guard3, normalGuards.guard4}, 50)
        API.RandomSleep2(2000, 600, 900)
    end
end

local function harvesNotEnriched() 
    if not API.CheckAnim(80) then 
        API.DoAction_NPC(0x3c, API.OFF_ACT_InteractNPC_route, {normalGuards.guard1, normalGuards.guard2, normalGuards.guard3, normalGuards.guard4}, 50)
        API.RandomSleep2(2000, 600, 900)
    end
end

while (API.Read_LoopyLoop()) do
    API.DoRandomEvents()
    idleCheck()
    local level = API.GetSkillByName("WOODCUTTING").level
    if level >= 92 then 
        harvestGuard()
    else
        harvesNotEnriched()
    end
    API.RandomSleep2(2000, 600, 900)
end
