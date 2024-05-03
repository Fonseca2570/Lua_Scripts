local API = require("api")
local DeadUtils = require("utils")
local ClueUtils = {}

---@class InventoryItems
---@field item number
---@field count number

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
    WarRetreat = API.GetABs_name1("War's Retreat Teleport"),
    ArmyConjure = API.GetABs_name1("Conjure Undead Army"),
    SoulSap = API.GetABs_name1("Soul Sap"),
    VolleyOfSouls = API.GetABs_name1("Volley of Souls"),
    TouchOfDeath = API.GetABs_name1("Touch of Death"),
    FingerDeath = API.GetABs_name1("Finger of Death"),
    Necromancy = API.GetABs_name1("Basic<nbsp>Attack"),
    LivingDeath = API.GetABs_name1("Living Death"),
    DeathSkull = API.GetABs_name1("Death Skulls"),
    CommandGhost = API.GetABs_name1("Command Vengeful Ghost"),
    CommandSkeleton = API.GetABs_name1("Command Skeleton Warrior"),
    HighAlch = API.GetABs_name1("High Level Alchemy")
}

ClueUtils.Locations = {
    WarRetreat = {x1 = 3279, x2 = 3309, y1 = 10113, y2 = 10143}
}

ClueUtils.BuffBar = {
    prayMageAncient = 26041,
    soulsplit = 26033,
    Ressonance = 14222,
    Darkness = 30122,
    LivingDeath = 30078,
    Necrosis = 30101,
    Souls = 30123,
    Skeleton = 30102
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
---@return boolean
function ClueUtils.DoAbility(ability) 
    if ClueUtils.IsAbilityAvailable(ability) then 
        API.DoAction_Ability_Direct(ability, 1, API.OFF_ACT_GeneralInterface_route)
        return true
    else
        print("ability not available: ", ability.name)
        return false
    end
end

-- used for high alch
---@param ability Abilitybar
---@return boolean
function ClueUtils.DoSpecialAbility(ability) 
    if ClueUtils.IsAbilityAvailable(ability) then 
        API.DoAction_Ability_Direct(ability, 0, API.OFF_ACT_Bladed_interface_route)
        return true
    else
        print("ability not available: ", ability.name)
        return false
    end
end

---@return boolean
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

-- can be used to deactivate prayer
---@param ability Abilitybar
---@param buffbarID number
function ClueUtils.DeactivatePrayer(ability, buffbarID) 
    local prayer = API.Buffbar_GetIDstatus(buffbarID, false)
    if not prayer.found then 
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

---@param id number
---@return boolean
function ClueUtils.IsTargetingMobID(id) 
    local interact = API.Local_PlayerInterActingWith_Id()
    return interact == id
end

function ClueUtils.OpenLootTable() 
    if not API.LootWindowOpen_2() then 
            API.KeyboardPress("\\", 0, 50)
            API.RandomSleep2(600,100,200)
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

---@return number
function ClueUtils.NecroStacks() 
    local buff = API.Buffbar_GetIDstatus(ClueUtils.BuffBar.Necrosis, false)
    if buff ~= nil then 
        return buff.conv_text
    end

    return 0
end

---@return number
function ClueUtils.SoulStack() 
    local buff = API.Buffbar_GetIDstatus(ClueUtils.BuffBar.Souls, false)
    if buff ~= nil then 
        return buff.conv_text
    end

    return 0
end

---@return boolean
function ClueUtils.ConjuresAlive() 
    local buff = API.Buffbar_GetIDstatus(ClueUtils.BuffBar.Skeleton, false)
    return buff.found
end

---@return boolean
function ClueUtils.InLivingDeath() 
    local buff = API.Buffbar_GetIDstatus(ClueUtils.BuffBar.LivingDeath, false)
    return buff.found
end

function ClueUtils.LivingDeathRotation() 
    if ClueUtils.DoAbility(ClueUtils.Abilities.DeathSkull) then 
        return
    end

    if ClueUtils.NecroStacks() >= 6 then 
        if ClueUtils.DoAbility(ClueUtils.Abilities.FingerDeath) then 
            return
        end
    end

    if ClueUtils.DoAbility(ClueUtils.Abilities.TouchOfDeath) then 
        return
    end
    
    ClueUtils.DoAbility(ClueUtils.Abilities.Necromancy)
end 

function ClueUtils.NecroBestAbility() 
    if DeadUtils.isAbilityQueued() then 
        return
    end

    if ClueUtils.InLivingDeath() then 
        return ClueUtils.LivingDeathRotation()
    end

    if ClueUtils.DoAbility(ClueUtils.Abilities.LivingDeath) then 
        return
    end

    if not ClueUtils.ConjuresAlive() then 
        if ClueUtils.DoAbility(ClueUtils.Abilities.ArmyConjure) then 
            return
        end
    end

    if ClueUtils.SoulStack >= 3 then 
        if ClueUtils.DoAbility(ClueUtils.Abilities.VolleyOfSouls) then 
            return
        end
    end

    if ClueUtils.DoAbility(ClueUtils.Abilities.CommandGhost) then 
        return
    end

    if ClueUtils.DoAbility(ClueUtils.Abilities.CommandSkeleton) then 
        return
    end

    if ClueUtils.NecroStacks() >= 12 then 
        if ClueUtils.DoAbility(ClueUtils.Abilities.FingerDeath) then 
            return
        end
    end

    if ClueUtils.DoAbility(ClueUtils.Abilities.TouchOfDeath) then 
        return
    end

    if ClueUtils.DoAbility(ClueUtils.Abilities.SoulSap) then 
        return
    end

    ClueUtils.DoAbility(ClueUtils.Abilities.Necromancy)
end


---@param items userdata --vector<number>
---@return boolean
function ClueUtils.HighAlch(items) 
    for _, item in pairs(items) do
        if API.InvItemcount_1(item) > 0 then 
            return ClueUtils.DoSpecialAbility(ClueUtils.Abilities.HighAlch)
        end
    end

    return false
end

---@param inventoryItems userdata --vector<inventoryItems>
---@return boolean
function ClueUtils.CheckItems(inventoryItems) 
    for _, obj in pairs(inventoryItems) do 
        count = API.InvItemcount_1(obj.item)
        if count < obj.count then 
            return false
        end
    end

    return true
end

---@param inventoryItems userdata --vector<InventoryItems>
---@param pouch number
---@param renewFamiliar boolean
---@return boolean
function ClueUtils.WarRetreatPreBoss(inventoryItems, renewFamiliar, pouch) 
    if not ClueUtils.AtLocation(ClueUtils.Locations.WarRetreat) then 
        if not ClueUtils.DoAbility(ClueUtils.Abilities.WarRetreat) then 
            return false
        end

        API.RandomSleep2(4000,100,400)
        API.WaitUntilMovingandAnimEnds()
    end


    if renewFamiliar then 
        if not ClueUtils.RenewFamiliar(pouch) then 
            return false
        end
    end

    for _, obj in pairs(inventoryItems) do 
        count = API.InvItemcount_1(obj.item)
        if count < obj.count then 
            API.DoAction_Object_string1(0x33,API.OFF_ACT_GeneralObject_route3,{ "Bank chest" }, 50, true) -- load last preset
            API.RandomSleep2(1200,0,200) -- 
            API.WaitUntilMovingEnds()

            if not ClueUtils.CheckItems(inventoryItems) then 
                return false -- load last preset dind't work so it fails
            end
        end
    end

    if API.GetHPrecent() < 90 then 
        API.RandomSleep2(6000,100,400)
    end

    if API.GetPrayPrecent() < 90 then 
        API.DoAction_Object1(0x3d,API.OFF_ACT_GeneralObject_route0,{ClueUtils.MostUsedIDS.WarAltar} ,50)
        API.RandomSleep2(600,0,0)
        API.WaitUntilMovingandAnimEnds()
        API.RandomSleep2(1200,0,0)
    end

    return true
end

return ClueUtils

-- walk with multiple steps use API.DoAction_WalkerW(normal_tile)