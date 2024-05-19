local API = require("api")

local startTime, afk, lastSwitch = os.time(), os.time(), os.time()
local MAX_IDLE_TIME_MINUTES = 5
local SwitchDivineChargesMinutes = 30
local fail = 0

API.SetDrawTrackedSkills(true)

local enrichedId = {}
local normalId = {}
local riftIds = {
    normal = 87306,
    cache = 93489
}
local chronicleIds = {
    normal = -1;
    enhanced = 51489
} 

local Abilites = {
    Vacum = API.GetABs_name1("Divine-o-matic vacuum"),
    Empty = API.GetABs_name1("Divine charge (empty)")
}

local Configs = {
    UseVacum = false
}

-- Define the wisp IDs for each type of wisp
local wispIds = {
    {normal = {18150, 18173}, enriched = {-1, -1}},    -- Pale Wisps
    {normal = {18151, 18174}, enriched = {18152, 18175}}, -- Flickering Wisps
    {normal = {18153, 18176}, enriched = {18154, 18177}}, -- Bright Wisps
    {normal = {18155, 18178}, enriched = {18156, 18179}}, -- Glowing Wisps
    {normal = {18157, 18180}, enriched = {18158, 18181}}, -- Sparkling Wisps
    {normal = {18159, 18182}, enriched = {18160, 18183}}, -- Gleaming Wisps
    {normal = {18161, 18184}, enriched = {18162, 18185}}, -- Vibrant Wisps
    {normal = {18163, 18186}, enriched = {18164, 18187}}, -- Lustrous Wisps
    {normal = {18165, 18188}, enriched = {18166, 18189}}, -- Brilliant Wisps
    {normal = {18167, 18190}, enriched = {18168, 18191}}, -- Radiant wisps
    {normal = {18169, 18192}, enriched = {18170, 18193}}, -- Luminous Wisps
    {normal = {18171, 18194}, enriched = {18172, 18195}}, -- Incandescent Wisps
    {normal = {13614, 13616}, enriched = {13615, 13617}}, -- Elder Wisps
}

local memoryIds = {
    29384, -- Pale Memory
    29385, 29396, -- Flickering Memory
    29386, 29397, -- Bright Memory
    29387, 29398, -- Glowing Memory
    29388, 29399, -- Sparkling Memory
    29389, 29400, -- Gleaming Memory
    29390, 29401, -- Vibrant Memory
    29391, 29402, -- Lustrous Memory
    29392, 29403, -- Brilliant Memory
    29393, 29404, -- Radiant Memory
    29394, 29405, -- Luminous Memory
    29395, 29406, -- Incandescent Memory
    31326, 31327, -- Elder Memory
}

local startXp = API.GetSkillXP("DIVINATION")

-- GameState checks and idle
local function checkXpIncrease() 
    local newXp = API.GetSkillXP("DIVINATION")
    if newXp == startXp then 
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
        checkXpIncrease()
        return true
    end
end

local function refreshDivineCarges() 
    local timeDiff = os.difftime(os.time(), lastSwitch)
    local randomTime = math.random((SwitchDivineChargesMinutes * 60) * 0.8, (SwitchDivineChargesMinutes * 60))

    if timeDiff > randomTime then 
        API.DoAction_Ability_Direct(Abilites.Vacum, 4, API.OFF_ACT_GeneralInterface_route)
        API.RandomSleep2(1200,100,600)
        API.DoAction_Ability_Direct(Abilites.Empty, 3, API.OFF_ACT_GeneralInterface_route)
        API.RandomSleep2(1200,100,600)
        lastSwitch = os.time()
    end
end

-- Find wisps near you and set normalIds and enrichedIds
for _, ids in ipairs(wispIds) do
    local result = API.GetAllObjArrayInteract(ids.normal, 20, {1})
    if #result > 0 then 
        normalId = ids.normal
        enrichedId = ids.enriched
        break
    end
end

-- Convert memories at the rift
local function convertMemories()
    print("Converting memories...")
    if API.DoAction_Object_valid1(0xc8, API.OFF_ACT_GeneralObject_route0, { riftIds.normal , riftIds.cache }, 50, true) then
        API.RandomSleep2(1200,500,1000)
    end
end

local function harvest(id)
    print("Harvesting wisps with IDs:", table.concat(id, ", "))
    if API.DoAction_NPC(0xc8, API.OFF_ACT_InteractNPC_route,  id , 50) then
        API.RandomSleep2(2000, 1000, 3000)
    end
end

if normalId == -1 then
    print("No wisps found. Stopping script")
    API.Write_LoopyLoop(false)
end

while API.Read_LoopyLoop() do
    idleCheck()
    API.DoRandomEvents()
    API.DoRandomEvent(18204)

    if Configs.UseVacum then 
        refreshDivineCarges()
    end

    if not API.CheckAnim(60) then 
        if API.InvFull_() then
            convertMemories()
        elseif API.InvStackSize(chronicleIds.enhanced) >= 10 then
            if API.DoAction_Object_valid1(0x29, 160, { riftIds.normal , riftIds.cache}, 50, true) then
                API.RandomSleep2(1200,100,300)
            end
        else 
            local enriched = API.GetAllObjArrayInteract({enrichedId}, 20, {1})
            if #enriched > 0 then 
                harvest(enrichedId)
            else
                harvest(normalId)
            end
        end
    end
    API.RandomSleep2(300, 300, 300)
end