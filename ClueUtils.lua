local API = require("api")
local DeadUtils = require("utils")
local ClueUtils = {}

ClueUtils.MostUsedIDS = {
    WarAltar = 114748, -- summoning renewal and prayer
    WarRetreatBank = 114750 -- bank at war retreat
}


ClueUtils.Abilities = {
    ThreadsOfFate = API.GetABs_name1("Threads of Fate"),
    SpecialAttack = API.GetABs_name1("Weapon Special Attack"),
    EatFood = API.GetABs_name1("Eat Food"),
    DeflectMagic = API.GetABs_name1("Deflect Magic"),
    SoulSplit = API.GetABs_name1("Soul Split"),
    SuperRestore = API.GetABs_name1("Super restore potion"),
    Resonance = API.GetABs_name1("Resonance"),
    Surge = API.GetABs_name1("Surge"),
    Darkness = API.GetABs_name1("Darkness"),
    WarRetreat = API.GetABs_name1("War's Retreat Teleport")
}

ClueUtils.Locations = {
    WarRetreat = {x1 = 3279, x2 = 3309, y1 = 10113, y2 = 10143}
}

ClueUtils.BuffBar = {
    prayMageAncient = 26041,
    soulsplit = 26033,
    Ressonance = 14222,
    Darkness = 30122
}

ClueUtils.DeBuffBar = {
    Excalibur = 14632,
    ElvenShard = 43358
}

---@param ability Abilitybar
---@return boolean
function ClueUtils.IsAbilityAvailable(ability) 
    local update = API.GetABs_name1(ability.name)
    return update ~= nil and update.enabled and update.cooldown_timer == 0
end

---@param ability Abilitybar
function ClueUtils.DoAbility(ability) 
    if ClueUtils.IsAbilityAvailable(ability) then 
        API.DoAction_Ability_Direct(ability, 1, API.OFF_ACT_GeneralInterface_route)
    else
        print("ability not available: ", ability.name)
    end
end

function ClueUtils.AtLocation(loc) 
    return API.PInArea21(loc.x1, loc.x2, loc.y1, loc.y2)
end

function ClueUtils.OpenInventoryIfNeeded() 
    if not API.InventoryInterfaceCheckvarbit() then 
        API.KeyboardPress2(0x42,50,150) -- press b
    end
end

-- can be used to activate prayer or buffbar like darkness
---@param ability Abilitybar
---@param buffbarID number
function ClueUtils.ActivatePrayer(ability, buffbarID) 
    local prayer = API.Buffbar_GetIDstatus(buffbarID, false)
    if prayer.found then 
        return
    end

    ClueUtils.DoAbility(ability)
end

function ClueUtils.IncreasePrayerPoints() 
    local pray = API.GetPrayPrecent()
    local elvenCD = API.DeBuffbar_GetIDstatus(ClueUtils.DeBuffBar.ElvenShard, false)
    local elvenFound = API.InvItemcount_1(ClueUtils.DeBuffBar.ElvenShard)
    if pray < 50 then 
        if not elvenCD.found and elvenFound > 0 then 
            API.DoAction_Inventory1(ClueUtils.DeBuffBar.ElvenShard, 43358, 1, API.OFF_ACT_GeneralInterface_route)
        else 
            ClueUtils.DoAbility(ClueUtils.Abilities.SuperRestore)
        end
    end
end

function ClueUtils.EatFood() 
    local hp = API.GetHPrecent()
    if hp < 60 then 
        ClueUtils.DoAbility(ClueUtils.Abilities.EatFood)
    end
end

---@return boolean
function ClueUtils.HasTarget() 
    return API.Local_PlayerInterActingWith_Id() ~= 0
end

---@param mobName string
---@return boolean
function ClueUtils.IsTargetingMob(mobName) 
    if ClueUtils.HasTarget() then 
        return API.ReadLpInteracting().Name == mobName
    end

    return false

end

---@param obj userdata --vector<int>
function ClueUtils.OpenLootTable(obj) 
    if not API.LootWindowOpen_2() then 
        if #API.GetAllObjArray1(obj, 20, {3}) > 0 then 
            API.KeyboardPress("\\", 0, 50)
        end
    end
end

function ClueUtils.LootAll() 
    ClueUtils.OpenLootTable()

    if API.LootWindowOpen_2() and (API.LootWindow_GetData()[1].itemid1 > 0) then 
        API.DoAction_LootAll_Button()
    end
end

---@param ability Abilitybar
---@return boolean
function ClueUtils.IsAbilityQueued(ability) 
    return DeadUtils.isSkillQueued(ability.name)
end

---@param pouch number
---@return boolean
function ClueUtils.RenewFamiliar(pouch) 
    if not ClueUtils.AtLocation(ClueUtils.Locations.WarRetreat) then 
        ClueUtils.DoAbility(ClueUtils.Abilities.WarRetreat)
        API.RandomSleep2(1200,600,1200)
        API.WaitUntilMovingEnds()
    end

    if API.GetSummoningPoints_() < 300 then 
        API.DoAction_Object1(0x3d,API.OFF_ACT_GeneralObject_route0,{ClueUtils.MostUsedIDS.WarAltar} ,50)
        API.RandomSleep2(600,0,0)
        API.WaitUntilMovingandAnimEnds()
        API.RandomSleep2(1200,0,0)
    end

    if not API.BankOpen2() then 
        API.DoAction_Object1(0x2e, API.OFF_ACT_GeneralObject_route1, {ClueUtils.MostUsedIDS.WarRetreatBank}, 50) 
        API.RandomSleep2(600,0,0)
        API.WaitUntilMovingEnds()
    end

    if API.BankOpen2() then 
        API.KeyboardPress2(0x33,0,50) -- deposit all
        API.RandomSleep2(1000, 500, 1000)

        API.DoAction_Bank(pouch, 1, API.OFF_ACT_GeneralInterface_route)
        API.RandomSleep2(1000, 500, 1000)

        API.KeyboardPress2(0x1B, 50, 150) -- close bank
        API.RandomSleep2(1000, 500, 1000)
    end

    if API.InvStackSize(pouch) < 1 then 
        return false
    end

    API.DoAction_Inventory2({pouch}, 0, 1, API.OFF_ACT_GeneralInterface_route)
    API.RandomSleep2(600,100,300)
    API.WaitUntilMovingEnds()
    ClueUtils.OpenInventoryIfNeeded()

    return true
end

return ClueUtils

-- walk with multiple steps use API.DoAction_WalkerW(normal_tile)