--[[
    Script:     Croesus Fishing
    Author:     Clue
    Version:    1.0

    Released:   14/04/2024

]]

local API = require("api")
startTime, afk = os.time(), os.time()

API.SetDrawTrackedSkills(true)

--[[Variables]]--

local fungus = {
    enriched = 52323, -- needs confirmation
    normal = 52321
}

local enrichedGuards = {
    guard1 = 28436,
    guard2 = 28433,
    guard3 = 28427,
    guard4 = 28430
}

local normalGuards = {
    guard1 = 28426,
    guard2 = 28429,
    guard3 = 28432,
    guard4 = 28435
}

local Abilities = {
    NormalFungus = API.GetABs_name1("Fungal algae"),
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
    if not API.CheckAnim(150) and findEnrich() then
        print("[" .. os.date("%X") .. "] Enriched Found")
        API.DoAction_NPC(0x3c, API.OFF_ACT_InteractNPC_route, { enrichedGuards.guard1, enrichedGuards.guard2, enrichedGuards.guard3, enrichedGuards.guard4 }, 50)
        API.RandomSleep2(2000, 600, 900)
    elseif not API.CheckAnim(150) and not findEnrich() then
        print("[" .. os.date("%X") .. "] No Enriched. Harvesting Normal")
        API.DoAction_NPC(0x3c, API.OFF_ACT_InteractNPC_route, {normalGuards.guard1, normalGuards.guard2, normalGuards.guard3, normalGuards.guard4}, 50)
        API.RandomSleep2(2000, 600, 900)
    end
end

local function harvesNotEnriched() 
    if not API.CheckAnim(150) then 
        API.DoAction_NPC(0x3c, API.OFF_ACT_InteractNPC_route, {normalGuards.guard1, normalGuards.guard2, normalGuards.guard3, normalGuards.guard4}, 50)
        API.RandomSleep2(2000, 600, 900)
    end
end

local function dropFungus()
    print("droping items")
    API.KeyboardPress31(0x20, 0, 50) -- space bar
    repeat
        if API.InvItemcount_1(fungus.normal) > 0 then
            API.KeyboardPress31(0x36, 3000,1000) -- key '6'
            --API.DoAction_Ability_Direct(Abilities.NormalFungus, 1, API.OFF_ACT_GeneralInterface_route)
        elseif API.InvItemcount_1(fungus.enriched) > 0 then
            API.KeyboardPress31(0x37, 3000,1000) -- key '7'
        end
    until API.InvItemcount_1(fungus.enriched) == 0 and API.InvItemcount_1(fungus.normal) == 0
end

while (API.Read_LoopyLoop()) do
    API.DoRandomEvents()
    idleCheck()
    local level = API.GetSkillByName("FISHING").level
    if API.InvFull_() then
        dropFungus()
    else
        if level >= 92 then 
            harvestGuard()
        else
            harvesNotEnriched()
        end
        API.RandomSleep2(2000, 600, 900)
    end
end
