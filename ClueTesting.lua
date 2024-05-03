local API = require("api")
local ClueUtils = require("ClueUtils")
local Utils = require("utils")

local startTime, afk, instanceStart = os.time(), os.time(), nil
local MAX_IDLE_TIME_MINUTES = 5
local fail = 0


local Bosses = {
    Bandos = {
        OutsideDoor = 84022,
        InsideDoor = 26425,
        Boss = 6260,
        Minions = {6261,6263,6265},
        SumBetweenDoors = 6,
        Drops = {
            995, --coins
            25022, -- Bandos Helmet
            11724, -- Bandos chestplate
            11726, -- Bandos Tassets
            25025, -- Bandos gloves
            11728, -- Bandos Boots
            25019, -- Bandos Warshield
            11710, -- Godsword shard 1
            11712, -- Godsword shard 2
            11714, -- Godsword shard 3
            11704, -- Bandos Hilt
            30320, -- Warpriest of bandos helm
            30314, -- Warpriest of bandos cuirass
            30317, -- Warpriest of bandos greaves
            30308, -- Warpriest of bandos gauntlets
            30311, -- Warpriest of bandos boots
            30323, -- Warpriest of bandos cape
            42008, -- Sealed clue scroll (hard)
            42009, -- Sealed clue scroll (elite)
            18778, -- Effigy
            25042, -- the glory of general Graardor
            33832, -- Decaying tooth
            14794, -- noted ourg bones
            1514, -- noted magic logs
            226, -- noted limproot
        },
        Portal = 114775,
        Locations = {
            Outside = {x1 = 2850, x2 = 2856, y1 = 5351, y2 = 5362},
            BetweenDoors = {x1 = 2857, x2 = 2862, y1 = 5351, y2 = 5362}
        },
        HighAlchDrops = {}
    }
}

local preset = {
    {
        item = 385, -- sharks
        count = 10,
    }
}

local States = {
    Banking = "Banking",
    GoingToBoss = "Going to Boss",
    InsideInstance = "Inside Instance"
}

local currentState = States.Banking
local SelectedBoss = Bosses.Bandos
local startXp = API.GetSkillXP("CONSTITUTION")

-- GameState checks and idle
local function checkXpIncrease() 
    local newXp = API.GetSkillXP("CONSTITUTION")
    if newXp == startXp then 
        API.logError("no xp increase")
        currentState = States.Banking
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

-- end of gamestate checks and idle

-- instance helper functions

local timer = {
    InterfaceComp5.new(861, 0, -1, -1, 0), InterfaceComp5.new(861, 2, -1, 0, 0),
    InterfaceComp5.new(861, 4, -1, 2, 0), InterfaceComp5.new(861, 8, -1, 4, 0)
}

local function timerHitZero()
    local result = API.ScanForInterfaceTest2Get(false, timer)
    if result and #result > 0 and result[1].textids then
        local textids = result[1].textids
        local startIndex, endIndex = string.find(textids, "00:00")
        if startIndex then
            return true
        else
            return false
        end
    else
        print("No result or textids field not found.")
    end
end

-- end of instance helper functions

-- PreBoss function

local function LoadLastPreset() 
    API.DoAction_Object_string1(0x33,API.OFF_ACT_GeneralObject_route3,{ "Bank chest" },50, true)
end

local function TeleportToWarRetreat() 
    return ClueUtils.DoAbility(ClueUtils.Abilities.WarRetreat)
end

local function PressPortal() 
    if fail > 3 then 
        API.Write_LoopyLoop(false)
        return
    end

    API.DoAction_Object1(0x39, API.OFF_ACT_GeneralObject_route0, {SelectedBoss.Portal}, 50)
    API.RandomSleep2(600,100,300)
    API.WaitUntilMovingandAnimEnds()
    if not API.Compare2874Status(0, false) then 
        API.DoAction_Interface(0xffffffff,0xffffffff,0,847,22,-1,API.OFF_ACT_GeneralInterface_Choose_option)
        API.RandomSleep2(600,100,300)
        API.WaitUntilMovingandAnimEnds()
        currentState = States.GoingToBoss
        fail = 0
    else
        fail = fail +1
        PressPortal()
    end
end

local function PressOutsideDoor() 
    if ClueUtils.AtLocation(SelectedBoss.Locations.Outside) then 
        API.RandomSleep2(1800,200,300)
        API.DoAction_Object1(0x31, API.OFF_ACT_GeneralObject_route0, { SelectedBoss.OutsideDoor },50)
        API.RandomSleep2(1800,200,300)
        API.WaitUntilMovingEnds()
    end
end

local function PressInsideDoor()
    if ClueUtils.AtLocation(SelectedBoss.Locations.BetweenDoors) then 
        if fail > 3 then 
            API.Write_LoopyLoop(false)
            return
        end
        API.DoAction_Object1(0x31, API.OFF_ACT_GeneralObject_route0, { SelectedBoss.InsideDoor },50)
        API.RandomSleep2(600,200,300)
        API.WaitUntilMovingEnds()
        if API.Compare2874Status(12, false) then 
            API.KeyboardPress2(0x32, 0, 50) -- press 2 for instance encounter
            API.RandomSleep2(600,100,300)
            if API.Compare2874Status(18, false) then 
                -- Instance system is open
                fail = 0
                return
            else
                fail = fail + 1 
                PressInsideDoor()
            end
            
        else
            fail = fail + 1 
            PressInsideDoor()
        end
    end
end

local function StartNewInstance() 
    if API.Compare2874Status(18, false) then 
        API.DoAction_Interface(0x24,0xffffffff,1,1591,60,-1,API.OFF_ACT_GeneralInterface_route)
        API.RandomSleep2(2600,500,1000)
    end

    if API.GetAllObjArray1({SelectedBoss.InsideDoor}, 1, {12}) then 
        API.DoAction_Object1(0x31, API.OFF_ACT_GeneralObject_route0, { SelectedBoss.InsideDoor },50)
        API.RandomSleep2(600,200,300)
        API.WaitUntilMovingEnds()
        currentState = States.InsideInstance
    end
end

local function RejoinLastInstance() 
    if API.Compare2874Status(18, false) then 
        API.DoAction_Interface(0x24,0xffffffff,1,1591,122,-1,API.OFF_ACT_GeneralInterface_route)
        API.RandomSleep2(2600,500,1000)
    end

    if API.GetAllObjArray1({SelectedBoss.InsideDoor}, 1, {12}) then 
        API.DoAction_Object1(0x31, API.OFF_ACT_GeneralObject_route0, { SelectedBoss.InsideDoor },50)
        API.RandomSleep2(600,200,300)
        API.WaitUntilMovingEnds()
        currentState = States.InsideInstance
    end
end

local function EnterInstance() 
    if instanceStart == nil then 
        instanceStart = os.time()
        StartNewInstance()
        return
    end

    local timeDiff = os.difftime(os.time(), instanceStart)
    if timeDiff > 3600 then 
        instanceStart = os.time()
        StartNewInstance()
        return
    end

    RejoinLastInstance()
end

-- end of pre boss functions

-- boss functions

local function PrioritizeBoss() 
    local boss = API.GetAllObjArray1({SelectedBoss.Boss}, 50 , {1})[1]
    if boss ~= nil and not ClueUtils.IsTargetingMobID(SelectedBoss.Boss) then 
        API.DoAction_NPC(0x2a,API.OFF_ACT_AttackNPC_route,{SelectedBoss.Boss},50);
    end
end

local function CleanBossRoom() 
    local boss = API.GetAllObjArray1({SelectedBoss.Boss}, 50 , {1})
    local minions = API.GetAllObjArray1(SelectedBoss.Minions, 50, {1})

    if #boss == 0 and #minions == 0 then 
        return true
    else 
        return false
    end
end

local function Loot() 
    if not API.InvFull_() then 
        API.DoAction_Loot_w(SelectedBoss.Drops, 15, API.PlayerCoordfloat(), 15)
    else
        if TeleportToWarRetreat() then 
            currentState = States.Banking
            API.RandomSleep2(1200,0,300)
            API.WaitUntilMovingandAnimEnds()
            return
        end
    end
end

local function HighAlchDrops() 
    ClueUtils.HighAlch(SelectedBoss.HighAlchDrops)
end

local function Bank() 
    if API.GetHPrecent() < 20 then 
        if TeleportToWarRetreat() then 
            currentState = States.Banking
            API.RandomSleep2(1200,0,300)
            API.WaitUntilMovingandAnimEnds()
            return
        end
    end 


    if API.InvFull_() then 
        if TeleportToWarRetreat() then 
            currentState = States.Banking
            API.RandomSleep2(1200,0,300)
            API.WaitUntilMovingandAnimEnds()
            return
        end
    end

    if timerHitZero() and CleanBossRoom() then 
        if TeleportToWarRetreat() then 
            currentState = States.Banking
            instanceStart = nil
            API.RandomSleep2(1200,0,300)
            API.WaitUntilMovingandAnimEnds()
            return
        end
    end
end
-- end boss functions

-- try to figure out current state
local function UpdateState() 
    if not API.IsPlayerMoving_() and not API.CheckAnim(100) then 
        if ClueUtils.AtLocation(SelectedBoss.Locations.Outside) or ClueUtils.AtLocation(SelectedBoss.Locations.BetweenDoors) then 
            currentState = States.GoingToBoss
            return
        end

        if ClueUtils.AtLocation(ClueUtils.Locations.WarRetreat) then 
            currentState = States.Banking
            return
        end

        local inside = API.GetAllObjArray1({SelectedBoss.InsideDoor}, 10, {12})[1]
        local outside = API.GetAllObjArray1({SelectedBoss.OutsideDoor}, 10, {12})[1]
        
        if inside ~= nil and outside ~= nil then 
            if inside.Distance + outside.Distance == SelectedBoss.SumBetweenDoors then 
                currentState = States.GoingToBoss
                return
            end
        end
        currentState = States.InsideInstance
        return
    end
end

while API.Read_LoopyLoop() do
    UpdateState()
    API.DoRandomEvents()
    idleCheck()
    gameStateChecks()
    API.Write_ScripCuRunning0(currentState)
    if fail > 3 then 
        API.Write_LoopyLoop(false)
    end

    if currentState == States.Banking then 
        if ClueUtils.WarRetreatPreBoss(preset, false, 0) then 
            PressPortal()
            API.RandomSleep2(1000,500,1000)
            API.WaitUntilMovingEnds()
            fail = 0
        else 
            fail = fail + 1
        end
        goto continue
    end

    if currentState == States.GoingToBoss then 
        PressOutsideDoor()
        API.RandomSleep2(1200,100,300)
        PressInsideDoor()
        API.RandomSleep2(1200,100,300)
        EnterInstance()
        API.RandomSleep2(1200,100,300)
        goto continue
    end

    if currentState == States.InsideInstance then 
        ClueUtils.IncreasePrayerPoints()
        ClueUtils.EatFood()
        ClueUtils.ActivatePrayer(ClueUtils.Abilities.SoulSplit, ClueUtils.BuffBar.soulsplit)
        PrioritizeBoss()
        Bank()
        Loot()
        goto continue
    end

    ::continue::
    API.RandomSleep2(600,0,200)
end