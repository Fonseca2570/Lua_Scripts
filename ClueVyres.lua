--[[
  Still in progress  


--]]

local API = require("api")
local ClueUtils = require("ClueUtils")
local startTime, afk, lastLoot, lastCorrection = os.time(), os.time(), os.time(), os.time()
local MAX_IDLE_TIME_MINUTES = 5
local MaxLootAllMinutes = 1
local MaxTimeForPositionCorrectionMinutes = 3

API.SetDrawLogs(true)
API.SetDrawTrackedSkills(true)

local IDS = {
    DarkmeyerDoor = 59961,
    DrakenMedallion = 21576,
    SplitBarkHelm = 3385,
    SplitBarkBody = 3387,
    DragonSpear = 1249
}

local Abilities = {
    HighAlch = API.GetABs_name1("High Level Alchemy")
}

local Locations = {
    InsideDarkMeyer = {x1 = 3623, x2 = 3630, y1 = 3360, y2 = 3370},
    OutsideDarkMeyer = {x1 = 3500, x2 = 3622, y1 = 3300, y2 = 3400}
}

local Position = WPOINT.new(3606,3356,0)

local Configs = {
    HighAlch = true,
    Dissassemble = false,
}

local States = {
    Banking = "Banking",
    MovingToVyres = "Moving",
    Killing = "Killing"
}

local CurrentState = States.Banking
local startXp = API.GetSkillXP("PRAYER")

-- helper functions
local function checkXpIncrease() 
    local newXp = API.GetSkillXP("PRAYER")
    if newXp == startXp then 
        API.logError("no xp increase")
        API.Write_LoopyLoop(false)
    else
        startXp = newXp
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


local function LootAll() 
    local timeDiff = os.difftime(os.time(), lastLoot)
    local randomTime = math.random((MaxLootAllMinutes * 60) * 0.8, (MaxLootAllMinutes * 60))
    
    if timeDiff > randomTime then 
        ClueUtils.LootAll()
        lastLoot = os.time()
    end
end


local function CorrectPosition() 
    local timeDiff = os.difftime(os.time(), lastCorrection)
    local randomTime = math.random((MaxTimeForPositionCorrectionMinutes * 60) * 0.8, (MaxTimeForPositionCorrectionMinutes * 60))
    
    if timeDiff > randomTime then 
        API.DoAction_Tile(Position)
        API.RandomSleep2(600,100,200)
        API.WaitUntilMovingEnds()
        lastCorrection = os.time()
    end
end

local function LoadLastPreset() 
    API.DoAction_Object_string1(0x33,API.OFF_ACT_GeneralObject_route3,{ "Bank chest" },50, true)
end

local function TeleportToDrakenmeyer() 
    -- press DrakenMedallion
    API.DoAction_Inventory1(IDS.DrakenMedallion, 0, 1, API.OFF_ACT_GeneralInterface_route)
    -- check if window is open
    if API.Compare2874Status(13, false) then 
         -- press the option to darkmeyer
        API.KeyboardPress2(0x34,50,100)
    end
    
    -- wait for animation to end
    API.RandomSleep2(1800,100,300)
    API.WaitUntilMovingandAnimEnds()
end

-- migrate this to ClueUtils
local function HighAlch() 
    if API.InvItemcount_1(IDS.SplitBarkBody) > 0 then 
        if ClueUtils.DoSpecialAbility(Abilities.HighAlch) then 
            API.RandomSleep2(600,50,100)
            -- press item
            API.DoAction_Inventory2({IDS.SplitBarkBody},0,0, API.OFF_ACT_GeneralInterface_route1)
            API.RandomSleep2(1200,50,100)
        end
    end

    if API.InvItemcount_1(IDS.SplitBarkHelm) > 0 then 
        if ClueUtils.DoSpecialAbility(Abilities.HighAlch) then 
            API.RandomSleep2(600,50,100)
            -- press item
            API.DoAction_Inventory2({IDS.SplitBarkHelm},0,0, API.OFF_ACT_GeneralInterface_route1)
            API.RandomSleep2(1200,50,100)
        end
    end

    if API.InvItemcount_1(IDS.DragonSpear) > 0 then 
        if ClueUtils.DoSpecialAbility(Abilities.HighAlch) then 
            API.RandomSleep2(600,50,100)
            -- press item
            API.DoAction_Inventory2({IDS.DragonSpear},0,0, API.OFF_ACT_GeneralInterface_route1)
            API.RandomSleep2(1200,50,100)
        end
    end
end

local function Dissassemble() 
    -- TODO
end

local function UpdateState() 
    if ClueUtils.AtLocation(ClueUtils.Locations.WarRetreat) then 
        CurrentState = States.Banking
        return
    end

    if ClueUtils.AtLocation(Locations.InsideDarkMeyer) then 
        CurrentState = States.MovingToVyres
        return
    end

    if ClueUtils.AtLocation(Locations.OutsideDarkMeyer) and CurrentState == States.MovingToVyres then 
        API.RandomSleep2(600,100,300)
        API.WaitUntilMovingEnds()
        CurrentState = States.Killing
        return
    end
end

while API.Read_LoopyLoop() do 
    API.DoRandomEvents()
    idleCheck()
    gameStateChecks()
    UpdateState()
    ClueUtils.IncreasePrayerPoints()
    API.Write_ScripCuRunning0(CurrentState)

    if CurrentState == States.Banking then 
        if not ClueUtils.AtLocation(ClueUtils.Locations.WarRetreat) then 
            ClueUtils.DoAbility(ClueUtils.Abilities.WarRetreat)
            API.RandomSleep2(1200,100,300)
            API.WaitUntilMovingandAnimEnds()
        end

        if API.GetPrayPrecent() < 90 then 
            API.DoAction_Object1(0x3d,API.OFF_ACT_GeneralObject_route0,{ClueUtils.MostUsedIDS.WarAltar} ,50)
            API.RandomSleep2(600,0,0)
            API.WaitUntilMovingandAnimEnds()
            API.RandomSleep2(1200,0,0)
        end

        LoadLastPreset()
        while API.GetHPrecent() < 90 do
            API.RandomSleep2(1200,100,300)
        end
       
        API.WaitUntilMovingEnds()
        TeleportToDrakenmeyer()
        
    end


    if CurrentState == States.MovingToVyres then 
        if API.PInArea(Position.x, 2, Position.y, 2, Position.z) then 
            CurrentState = States.Killing
        end


        if ClueUtils.AtLocation(Locations.InsideDarkMeyer) then 
            -- press the door
            API.DoAction_Object2(0x31,0,{ IDS.DarkmeyerDoor },50, WPOINT.new(3622,3364,0));
            API.RandomSleep2(1200,100,200)
            API.WaitUntilMovingEnds()
            API.RandomSleep2(1200,100,200)
            API.DoAction_Tile(Position)
            API.RandomSleep2(600,100,200)
            API.WaitUntilMovingEnds()
            UpdateState()
        else 
            API.DoAction_Tile(Position)
            API.RandomSleep2(600,100,200)
            API.WaitUntilMovingEnds()
            UpdateState()
        end
    end

    if CurrentState == States.Killing then 
        LootAll()
        CorrectPosition()
        if Configs.HighAlch then 
            HighAlch() 
        end
        if API.GetHPrecent() < 20 then 
            if API.GetPrayPrecent() < 20 then 
                ClueUtils.DoAbility(ClueUtils.Abilities.WarRetreat)
                API.RandomSleep2(600,100,200)
                goto continue
            else
                ClueUtils.ActivatePrayer(ClueUtils.Abilities.SoulSplit, ClueUtils.BuffBar.soulsplit)
            end
        end

        if API.GetHPrecent() > 90 then 
            ClueUtils.DeactivatePrayer(ClueUtils.Abilities.SoulSplit, ClueUtils.BuffBar.soulsplit)
        end
    end


    ::continue::
    API.RandomSleep2(600,100,300)
end