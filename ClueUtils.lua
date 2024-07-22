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
    DEFENSIVES = {
        Resonance = API.GetABs_name1("Resonance"),
        Freedom = API.GetABs_name1("Freedom"),
        Anticipation = API.GetABs_name1("Anticipation"),
        Devotion = API.GetABs_name1("Devotion"),
        Bash = API.GetABs_name1("Bash"),
        Revenge = API.GetABs_name1("Revenge"),
        Provoke = API.GetABs_name1("Provoke"),
        Immortality = API.GetABs_name1("Immortality"),
        Reflect = API.GetABs_name1("Reflect"),
        Divert = API.GetABs_name1("Divert"),
        Rejuvenate = API.GetABs_name1("Rejuvenate"),
        Debilitate = API.GetABs_name1("Debilitate"),
        Preparation = API.GetABs_name1("Preparation"),
        Barricade = API.GetABs_name1("Barricade"),
        NaturalInstinct = API.GetABs_name1("Natural Instinct"),
    },

    HP = {
        EatFood = API.GetABs_name1("Eat Food"),
        SpecialAttack = API.GetABs_name1("Weapon Special Attack"),
        EOF = API.GetABs_name1("Essence of Finality"),
        UndeadSlayer = API.GetABs_name1("Undead Slayer"),
        DragonSlayer = API.GetABs_name1("Dragon Slayer"),
        DemonSlayer = API.GetABs_name1("Demon Slayer"),
        Limitless = API.GetABs_name1("Limitless"),
        IOH = API.GetABs_name1("Ingenuity of the Humans"),
        Sacrifice = API.GetABs_name1("Sacrifice"),
        TuskasWrath = API.GetABs_name1("Tuska's Wrath"),
        StormShards = API.GetABs_name1("Storm Shards"),
        Shatter = API.GetABs_name1("Shatter"),
        Reprisal = API.GetABs_name1("Reprisal"),
        Onslaught = API.GetABs_name1("Onslaught"),
    },

    NECRO = {
        ThreadsOfFate = API.GetABs_name1("Threads of Fate"),
        Darkness = API.GetABs_name1("Darkness"),
        LifeTransfer = API.GetABs_name1("Life Transfer"),
        InvokeLordofBones = API.GetABs_name1("Invoke Lord of Bones"),
        InvokeDeath = API.GetABs_name1("Invoke Death"),
        SplitSoul = API.GetABs_name1("Split Soul"),
        ArmyConjure = API.GetABs_name1("Conjure Undead Army"),
        ConjureGhost = API.GetABs_name1("Conjure Vengeful Ghost"),
        ConjureSkeleton = API.GetABs_name1("Conjure Skeleton Warrior"),
        ConjureZombie = API.GetABs_name1("Conjure Putried Zombie"),
        CommandGhost = API.GetABs_name1("Command Vengeful Ghost"),
        CommandSkeleton = API.GetABs_name1("Command Skeleton Warrior"),
        CommandZombie = API.GetABs_name1("Command Putried Zombie"),
        SoulSap = API.GetABs_name1("Soul Sap"),
        VolleyOfSouls = API.GetABs_name1("Volley of Souls"),
        TouchOfDeath = API.GetABs_name1("Touch of Death"),
        FingerDeath = API.GetABs_name1("Finger of Death"),
        Necromancy = API.GetABs_name1("Basic<nbsp>Attack"),
        LivingDeath = API.GetABs_name1("Living Death"),
        DeathSkull = API.GetABs_name1("Death Skulls"),
        BloodSiphon = API.GetABs_name1("Blood Siphon"),
        Bloat = API.GetABs_name1("Bloat"),
        SpectralScythe = API.GetABs_name1("Spectral Scythe"),
    },

    MELEE = {
        Slice = API.GetABs_name1("Slice"),
        Backhand = API.GetABs_name1("Backhand"),
        LesserSmash = API.GetABs_name1("Lesser Smash"),
        LesserHavoc = API.GetABs_name1("Lesser Havoc"),
        LesserSever = API.GetABs_name1("Lesser Sever"),
        Slaughter = API.GetABs_name1("Slaughter"),
        Overpower = API.GetABs_name1("Overpower"),
        Havoc = API.GetABs_name1("Havoc"),
        Forceful = API.GetABs_name1("Forceful"),
        Smash = API.GetABs_name1("Smash"),
        Barge = API.GetABs_name1("Barge"),
        GreaterBarge = API.GetABs_name1("Greater Barge"),
        Flurry = API.GetABs_name1("Flurry"),
        GreaterFlurry = API.GetABs_name1("Greater Flurry"),
        Sever = API.GetABs_name1("Sever"),
        Hurricane = API.GetABs_name1("Hurricane"),
        BladedDive = API.GetABs_name1("Bladed Dive"),
        Massacre = API.GetABs_name1("Massacre"),
        BloodTendrils = API.GetABs_name1("Blood Tendrils"),
        MeteorStrike = API.GetABs_name1("Meteor Strike"),
        BalancedStrike = API.GetABs_name1("Balanced Strike"),
        LesserDismember = API.GetABs_name1("Lesser Dismember"),
        Kick = API.GetABs_name1("Kick"),
        Stomp = API.GetABs_name1("Stomp"),
        Punish = API.GetABs_name1("Punish"),
        Dismember = API.GetABs_name1("Dismember"),
        GreaterFury = API.GetABs_name1("Greater Fury"),
        Fury = API.GetABs_name1("Fury"),
        Destroy = API.GetABs_name1("Destroy"),
        Quake = API.GetABs_name1("Quake"),
        Berserk = API.GetABs_name1("Berserk"),
        Cleave = API.GetABs_name1("Cleave"),
        Assault = API.GetABs_name1("Assault"),
        Decimate = API.GetABs_name1("Decimate"),
        Pulverise = API.GetABs_name1("Pulverise"),
        Frenzy = API.GetABs_name1("Frenzy"),
        ChaosRoar = API.GetABs_name1("Chaos Roar"),
    },

    RANGED = {
        PiercingShot = API.GetABs_name1("Piercing Shot"),
        BindingShot = API.GetABs_name1("Binding Shot"),
        SnapShot = API.GetABs_name1("Snap Shot"),
        LesserDazingShot = API.GetABs_name1("Lesser Dazing Shot"),
        LesserNeedleStrike = API.GetABs_name1("Lesser Needle Strike"),
        LesserFragmentationShot = API.GetABs_name1("Lesser Fragmentation Shot"),
        LesserSnipe = API.GetABs_name1("Lesser Snipe"),
        QuiverAmmoSlot1 = API.GetABs_name1("Quiver ammo slot 1"),
        QuiverAmmoSlot2 = API.GetABs_name1("Quiver ammo slot 2"),
        Deadshot = API.GetABs_name1("Deadshot"),
        TightBindings = API.GetABs_name1("Tight Bindings"),
        Snipe = API.GetABs_name1("Snipe"),
        DazingShot = API.GetABs_name1("Dazing Shot"),
        GreaterDazingShot = API.GetABs_name1("Greater Dazing Shot"),
        Demoralise = API.GetABs_name1("Demoralise"),
        NeedleStrike = API.GetABs_name1("Needle Strike"),
        Rout = API.GetABs_name1("Rout"),
        FragmentationShot = API.GetABs_name1("Fragmentation Shot"),
        RapidFire = API.GetABs_name1("Rapid Fire"),
        Ricochet = API.GetABs_name1("Ricochet"),
        GreaterRicochet = API.GetABs_name1("Greater Ricochet"),
        Bombardment = API.GetABs_name1("Bombardment"),
        SaltTheWound = API.GetABs_name1("Salt the Wound"),
        IncendiaryShot = API.GetABs_name1("Incendiary Shot"),
        CorruptionShot = API.GetABs_name1("Corruption Shot"),
        ShadowTendrils = API.GetABs_name1("Shadow Tendrils"),
        Unload = API.GetABs_name1("Unload"),
        DeathsSwiftness = API.GetABs_name1("Death's Swiftness"),
        GreaterDeathsSwiftness = API.GetABs_name1("Greater Death's Swiftness"),
    },

    MAGIC = {
        Wrack = API.GetABs_name1("Wrack"),
        WrackAndRuin = API.GetABs_name1("Wrack and Ruin"),
        Impact = API.GetABs_name1("Impact"),
        Asphyxiate = API.GetABs_name1("Asphyxiate"),
        LesserCombust = API.GetABs_name1("Lesser Combust"),
        LesserDragonBreath = API.GetABs_name1("Lesser Dragon Breath"),
        LesserSonicWave = API.GetABs_name1("Lesser Sonic Wave"),
        LesserConcentratedBlast = API.GetABs_name1("Lesser Concentrated Blast"),
        Omnipower = API.GetABs_name1("Omnipower"),
        DeepImpact = API.GetABs_name1("Deep Impact"),
        DragonBreath = API.GetABs_name1("Dragon Breath"),
        SonicWave = API.GetABs_name1("Sonic Wave"),
        Shock = API.GetABs_name1("Shock"),
        ConcentratedBlast = API.GetABs_name1("Concentrated Blast"),
        GreaterConcentratedBlast = API.GetABs_name1("Greater Concentrated Blast"),
        Horror = API.GetABs_name1("Horror"),
        Combust = API.GetABs_name1("Combust"),
        Detonate = API.GetABs_name1("Detonate"),
        Chain = API.GetABs_name1("Chain"),
        GreaterChain = API.GetABs_name1("Greater Chain"),
        WildMagic = API.GetABs_name1("Wild Magic"),
        Metamorphosis = API.GetABs_name1("Metamorphosis"),
        MagmaTempest = API.GetABs_name1("Magma Tempest"),
        CorruptionBlast = API.GetABs_name1("Corruption Blast"),
        SmokeTendrils = API.GetABs_name1("Smoke Tendrils"),
        GreaterSonicWave = API.GetABs_name1("Greater Sonic Wave"),
        Tsunami = API.GetABs_name1("Tsunami"),
        Sunshine = API.GetABs_name1("Sunshine"),
        GreaterSunshine = API.GetABs_name1("Greater Sunshine"),
    },

    AGILITY = {
        Surge = API.GetABs_name1("Surge"),
        Escape = API.GetABs_name1("Escape"),
        Dive = API.GetABs_name1("Dive"),
    },

    MAGICSPELLS = {
        HighAlch = API.GetABs_name1("High Level Alchemy"),
        Bind = API.GetABs_name1("Bind"),
        Snare = API.GetABs_name1("Snare"),
        Vulnerability = API.GetABs_name1("Vulnerability"),
        EnfeebleEntangle = API.GetABs_name1("EnfeebleEntangle"),
        Stagger = API.GetABs_name1("Stagger"),
        SpiritualHealing = API.GetABs_name1("Spiritual Healing"),
        DisruptionShield = API.GetABs_name1("Disruption Shield"),
        Vengeance = API.GetABs_name1("Vengeance"),
        VengeanceGroup = API.GetABs_name1("Vengeance Group"),
        PrismOfRestoration = API.GetABs_name1("Prism of Restoration"),
        Intercept = API.GetABs_name1("Intercept"),
        ShieldDome = API.GetABs_name1("Shield Dome"),
        SmokeCloud = API.GetABs_name1("Smoke Cloud"),
        AnimateDead = API.GetABs_name1("Animate Dead"),
        SpellbookSwap = API.GetABs_name1("Spellbook Swap"),
    },

    CURSES = {
        ProtectItem = API.GetABs_name1("Protect Item"),
        DeflectSummoning = API.GetABs_name1("Deflect Summoning"),
        DeflectMagic = API.GetABs_name1("Deflect Magic"),
        DeflectRanged = API.GetABs_name1("Deflect Ranged"),
        DeflectMelee = API.GetABs_name1("Deflect Melee"),
        DeflectNecromancy = API.GetABs_name1("Deflect Necromancy"),
        LeechRangedStrength = API.GetABs_name1("Leech Ranged Strength"),
        LeechMagicStrength = API.GetABs_name1("Leech Magic Strength"),
        LeechMeleeStrength = API.GetABs_name1("Leech Melee Strength"),
        LeechNecromancyStrength = API.GetABs_name1("Leech Necromancy Strength"),
        LightForm = API.GetABs_name1("Light Form"),
        DarkForm = API.GetABs_name1("Dark Form"),
        ChronicleAttraction = API.GetABs_name1("Chronicle Attraction"),
        SuperheatForm = API.GetABs_name1("Superheat Form"),
        SoulSplit = API.GetABs_name1("Soul Split"),
        Fortitude = API.GetABs_name1("Fortitude"),
        Turmoil = API.GetABs_name1("Turmoil"),
        Anguish = API.GetABs_name1("Anguish"),
        Torment = API.GetABs_name1("Torment"),
        Sorrow = API.GetABs_name1("Sorrow"),
        Malevolence = API.GetABs_name1("Malevolence"),
        Desolation = API.GetABs_name1("Desolation"),
        Affliction = API.GetABs_name1("Affliction"),
        Ruination = API.GetABs_name1("Ruination"),
    },

    SUPPORT = {
        HolyOverload = API.GetABs_name1("Holy overload potion"),
        Adrenaline = API.GetABs_name1("Super adrenaline potion"),
    },

    -- This is here just because of compatibility
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
    HighAlch = API.GetABs_name1("High Level Alchemy"),
    Disassemble = API.GetABs_name1("Disassemble"),
    SuperAntiFire = API.GetABs_name1("Super antifire potion"),
    Devotion = API.GetABs_name1("Devotion"),
}

ClueUtils.AbilitiesID = {
    Necro = {
        ConjureUndeadArmy = 32988,
        SoulSap = 30080,
        TouchOfDeath = 30076,
        Necromancy = 30015,
        SoulStrike = 30082,
        Volley = 30088,
        FingerDeath = 30077,
        SpectralScythe = 30084,
        Bloat = 30016,
        DeathSkulls = 30074,
        LivingDeath = 30078,
        Darkness = 30700,
        InvokeDeath = 30702,
        ThreadsOfFate = 30734,
    },
    Defensives = {
        Freedom = 14220,
        Antecipation = 14219,
        Preparation = 14223,
        Devotion = 21665,
        Debilitate = 14226,
        Reflect = 14225,
        Revenge = 14227,
        Ressonance = 14222,
        Immortality = 14230,
        NatureInstinct = 16549,
        Cease = 15036,
        Provoke = 14221,
    },
    HP = {
        EatFood = 1601,
        SpecialAtk = 26105,
    },
    Support = {
        HolyOverload = 33244,
        SuperRestore = 3024,
        SuperAdrenaline = 39212,
    },
    Agility = {
        Surge = 14233,
        Escape = 14245,
        Dive = 23714,
        Barge = 14208,
    },
    Curses = {
        Sorrow = 30771,
        DeflectMagic = 26041,
        DeflectRange = 26044,
        DeflectMelee = 26040,
        SoulSplit = 26033,
    },
    Teleports = {
        WarRetreatTeleport = 12532,
    }
}

ClueUtils.Potions = {
    SuperRestore = {3024, 3026, 3028, 3030},
    Adrenaline = {39212, 39214, 39216, 39218},
    HolyOverload = {33246, 33244, 33242, 33240, 33238, 33236},
}

ClueUtils.Locations = {
    WarRetreat = {x1 = 3270, x2 = 3325, y1 = 10113, y2 = 10163},
    DeathOffice = {x1 = 400, x2 = 430, y1 = 670, y2 = 680},
    AnacroniaLoadstone = {x1 = 5400, x2 = 5500, y1 = 2250, y2 = 2400},
}

ClueUtils.BuffBar = {
    prayRangeAncient = 26044,
    prayMageAncient = 26041,
    prayMeleeAncient =  26040,
    soulsplit = 26033,
    Ressonance = 14222,
    Darkness = 30122,
    LivingDeath = 30078,
    Necrosis = 30101,
    Souls = 30123,
    Skeleton = 30102,
    antifire = 30093,
    Devotion = 21665, 
    Overload = 26093,
    Sorrow = 30771,
}

ClueUtils.DeBuffBar = {
    Excalibur = 14632,
    ElvenShard = 43358,
    SpecialAtkNecro = 55524,
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

---@param ability Abilitybar
function ClueUtils.DoAbilityForced(ability) 
    if ClueUtils.IsAbilityAvailable(ability) then 
        API.DoAction_Ability_Direct(ability, 1, API.OFF_ACT_GeneralInterface_route)
    end 
end

----------------------------------------------------------
---@param ability Abilitybar
---@return boolean
function ClueUtils.IsAbilityAvailable2(ability) 
    return ability ~= nil and ability.enabled and ability.cooldown_timer == 0
end

---@param id number
---@return boolean
function ClueUtils.IsAbilityAvailableID(id) 
    local ability = API.GetABs_id(id)
    return ability ~= nil and ability.enabled and ability.cooldown_timer == 0
end

---@param id number
---@return boolean
function ClueUtils.DoAbility2(id) 
    local ability = API.GetABs_id(id)
    if ClueUtils.IsAbilityAvailable2(ability) then 
        API.DoAction_Ability_Direct(ability, 1, API.OFF_ACT_GeneralInterface_route)
        return true
    else
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

function ClueUtils.isAbilityQueued()
    return API.VB_FindPSettinOrder(5861, 0).state ~= 0
end

-- can be used to activate prayer or buffbar like darkness
---@param id number
---@param buffbarID number
function ClueUtils.ActivatePrayer(id, buffbarID) 
    local prayer = API.Buffbar_GetIDstatus(buffbarID, false)
    if prayer.found then 
        return
    end

    ClueUtils.DoAbility2(id)
end

function ClueUtils.ActivatePotion(ids, buffbarID) 
    local prayer = API.Buffbar_GetIDstatus(buffbarID, false)
    if prayer.found then 
        return
    end

    return API.DoAction_Inventory2(ids, 0, 1, API.OFF_ACT_GeneralInterface_route)
end

-- can be used to deactivate prayer
---@param id number
---@param buffbarID number
function ClueUtils.DeactivatePrayer(id, buffbarID) 
    local prayer = API.Buffbar_GetIDstatus(buffbarID, false)
    if not prayer.found then 
        return
    end

    ClueUtils.DoAbility2(id)
end

function ClueUtils.IncreasePrayerPoints() 
    local pray = API.GetPrayPrecent()
    print(pray)
    local elvenCD = API.DeBuffbar_GetIDstatus(ClueUtils.DeBuffBar.ElvenShard, false)
    local elvenFound = API.InvItemcount_1(ClueUtils.DeBuffBar.ElvenShard)
    if pray < 50 then 
        if not elvenCD.found and elvenFound > 0 then 
            API.DoAction_Inventory1(ClueUtils.DeBuffBar.ElvenShard, 43358, 1, API.OFF_ACT_GeneralInterface_route)
        else 
            ClueUtils.DoAbility2(ClueUtils.AbilitiesID.Support.SuperRestore)
        end
    end
end

function ClueUtils.IncreasePrayerPoints2() 
    local pray = API.GetPray_()
    print(pray)
    local elvenCD = API.DeBuffbar_GetIDstatus(ClueUtils.DeBuffBar.ElvenShard, false)
    local elvenFound = API.InvItemcount_1(ClueUtils.DeBuffBar.ElvenShard)
    if pray < 500 then 
        if not elvenCD.found and elvenFound > 0 then 
            API.DoAction_Inventory1(ClueUtils.DeBuffBar.ElvenShard, 43358, 1, API.OFF_ACT_GeneralInterface_route)
        else 
            return API.DoAction_Inventory2(ClueUtils.Potions.SuperRestore, 0, 1, API.OFF_ACT_GeneralInterface_route)
        end
    end
end

function ClueUtils.EatFood() 
    local hp = API.GetHPrecent()
    if hp < 60 then 
        ClueUtils.DoAbility2(ClueUtils.AbilitiesID.HP.EatFood)
    end
end

function ClueUtils.EatFood2() 
    local hp = API.GetHP_()
    if hp < 6000 then 
        ClueUtils.DoAbility2(ClueUtils.AbilitiesID.HP.EatFood)
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
    if ClueUtils.isAbilityQueued() then 
        return
    end

    if ClueUtils.InLivingDeath() then 
        -- TODO check if has target to not waste time of rotation
        return ClueUtils.LivingDeathRotation()
    end

    if ClueUtils.DoAbility(ClueUtils.Abilities.NECRO.LivingDeath) then 
        return
    end

    if not ClueUtils.ConjuresAlive() then 
        if ClueUtils.DoAbility(ClueUtils.Abilities.NECRO.ArmyConjure) then 
            return
        end
    end

    if ClueUtils.SoulStack() >= 3 then 
        if ClueUtils.DoAbility(ClueUtils.Abilities.NECRO.VolleyOfSouls) then 
            return
        end
    end

    if ClueUtils.DoAbility(ClueUtils.Abilities.NECRO.CommandGhost) then 
        return
    end

    if ClueUtils.DoAbility(ClueUtils.Abilities.NECRO.CommandSkeleton) then 
        return
    end

    if ClueUtils.NecroStacks() >= 12 then 
        if ClueUtils.DoAbility(ClueUtils.Abilities.NECRO.FingerDeath) then 
            return
        end
    end

    if ClueUtils.DoAbility(ClueUtils.Abilities.NECRO.TouchOfDeath) then 
        return
    end

    if ClueUtils.DoAbility(ClueUtils.Abilities.NECRO.SoulSap) then 
        return
    end

    ClueUtils.DoAbility(ClueUtils.Abilities.NECRO.Necromancy)
end

function ClueUtils.NecroBestAbilityAvoidUltimates() 
    if ClueUtils.isAbilityQueued() then 
        return
    end

    if not ClueUtils.ConjuresAlive() then 
        if ClueUtils.DoAbility(ClueUtils.Abilities.NECRO.ArmyConjure) then 
            return
        end
    end

    if ClueUtils.SoulStack() >= 3 then 
        if ClueUtils.DoAbility(ClueUtils.Abilities.NECRO.VolleyOfSouls) then 
            return
        end
    end

    print("ghost")
    print(ClueUtils.DoAbility(ClueUtils.Abilities.NECRO.CommandGhost))
    if ClueUtils.DoAbility(ClueUtils.Abilities.NECRO.CommandGhost) then 
        return
    end

    print("skeleton")
    print(ClueUtils.DoAbility(ClueUtils.Abilities.NECRO.CommandSkeleton))
    if ClueUtils.DoAbility(ClueUtils.Abilities.NECRO.CommandSkeleton) then 
        return
    end

    if ClueUtils.NecroStacks() >= 12 then 
        if ClueUtils.DoAbility(ClueUtils.Abilities.NECRO.FingerDeath) then 
            return
        end
    end

    if ClueUtils.DoAbility(ClueUtils.Abilities.NECRO.TouchOfDeath) then 
        return
    end

    if ClueUtils.DoAbility(ClueUtils.Abilities.NECRO.SoulSap) then 
        return
    end

    ClueUtils.DoAbility(ClueUtils.Abilities.NECRO.Necromancy)
end

function ClueUtils.NecroBestAbilityAvoidUltimatesRevo() 
    if ClueUtils.isAbilityQueued() then 
        return
    end

    if ClueUtils.SoulStack() >= 3 then 
        if ClueUtils.DoAbility(ClueUtils.Abilities.NECRO.VolleyOfSouls) then 
            return
        end
    end

    if ClueUtils.NecroStacks() >= 6 then 
        if ClueUtils.DoAbility(ClueUtils.Abilities.NECRO.FingerDeath) then 
            return
        end
    end
end

function ClueUtils.AOENecro() 
    if ClueUtils.isAbilityQueued() then 
        return
    end

    if API.GetAddreline_() >= 90 then 
        if ClueUtils.DoAbility2(ClueUtils.AbilitiesID.Necro.Bloat) then 
            return
        end
    end

    if ClueUtils.DoAbility2(ClueUtils.AbilitiesID.Necro.ThreadsOfFate) then 
        return
    end

    local sAtk = API.DeBuffbar_GetIDstatus(ClueUtils.DeBuffBar.SpecialAtkNecro, false)
    if not sAtk.found then 
        if ClueUtils.DoAbility2(ClueUtils.AbilitiesID.HP.SpecialAtk) then 
            return
        end
    end

    if ClueUtils.DoAbility2(ClueUtils.AbilitiesID.Necro.SoulSap) then 
        return
    end
end

---@param items userdata --vector<number>
---@return boolean
function ClueUtils.HighAlch(items) 
    for _, item in pairs(items) do
        if API.InvItemcount_1(item) > 0 then 
            if ClueUtils.DoSpecialAbility(ClueUtils.Abilities.HighAlch) then 
                if API.DoAction_Inventory2({item}, 0, 0, API.OFF_ACT_GeneralInterface_route1) then 
                    return true
                end
            end
        end
    end

    return false
end

---@param inventoryItems userdata --vector<inventoryItems>
---@return boolean
function ClueUtils.CheckItems(inventoryItems) 
    for _, obj in pairs(inventoryItems) do 
        local count = API.InvItemcount_1(obj.item)
        if not (count == obj.count) then 
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


    if renewFamiliar and DeadUtils.getFamiliarDuration() < 5 then 
        if not ClueUtils.RenewFamiliar(pouch) then 
            return false
        end
    end

    for _, obj in pairs(inventoryItems) do 
        local count = API.InvItemcount_1(obj.item)
        if not (count == obj.count) then 
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

---@param items userdata --vector<number>
---@return boolean
function ClueUtils.Disassemble(items)
    for _, item in pairs(items) do
        if API.InvItemcount_1(item) > 0 then 
            if ClueUtils.DoSpecialAbility(ClueUtils.Abilities.Disassemble) then 
                if API.DoAction_Inventory2({item}, 0, 0, API.OFF_ACT_GeneralInterface_route1) then 
                    return true
                end
            end
        end
    end

    return false
end

--- Is non interface interface open
---@return boolean
function ClueUtils.isNonInterfaceOpen()
    return API.VB_FindPSett(2874, 1, 0).state == 0
end

--- Loop to check if the player is interacting
---@param id number
---@param loops number
---@return boolean
function ClueUtils.IsTargetingMobIDWithLoop(id, loop) 
    for i=loop,0,-1 do 
        local interact = API.Local_PlayerInterActingWith_Id()
        if interact == id then 
            return true
        end

        if API.VB_FindPSettinOrder(11625, 0).state == -1 then
            return true
        end
    end

    local boss = API.GetAllObjArray1({id}, 50 , {1})[1]
    if boss ~= nil and boss.Life == 0 then 
        return true
    end
    
    return false
end

--- Loop to check id of interacting != 0
---@param loops number
---@return number
function ClueUtils.IsTargetingMob(loop) 
    for i=loop,0,-1 do 
        local interact = API.Local_PlayerInterActingWith_Id()
        if interact ~= 0 then 
            return interact
        end
    end
    
    return 0
end

--- Move and target
--- @param point wpoint
--- @param target number
function ClueUtils.MoveAndTarget(wpoint, mob)
    API.DoAction_Tile(wpoint)
    API.RandomSleep2(600,0,50)
    API.WaitUntilMovingEnds(2, 2)
    API.DoAction_NPC(0x2a,API.OFF_ACT_AttackNPC_route,{mob},50);
end

---@param id number
function ClueUtils.PrayerFlicking(id) 
    if id == ClueUtils.AbilitiesID.Curses.DeflectMelee then 
        if not DeadUtils.isDeflectMelee() then 
            return ClueUtils.DoAbility2(ClueUtils.AbilitiesID.Curses.DeflectMelee)
        end

        return
    end

    if id == ClueUtils.AbilitiesID.Curses.DeflectMagic then 
        if not DeadUtils.isDeflectMagic() then 
            return ClueUtils.DoAbility2(ClueUtils.AbilitiesID.Curses.DeflectMagic)
        end

        return
    end

    if id == ClueUtils.AbilitiesID.Curses.DeflectRange then 
        if not DeadUtils.isDeflectRange() then 
            return ClueUtils.DoAbility2(ClueUtils.AbilitiesID.Curses.DeflectRange)
        end

        return
    end

    if id == ClueUtils.AbilitiesID.Curses.SoulSplit then 
        if not DeadUtils.isSoulSplitting() then 
            return ClueUtils.DoAbility2(ClueUtils.AbilitiesID.Curses.SoulSplit)
        end

        return
    end
end

return ClueUtils

-- walk with multiple steps use API.DoAction_WalkerW(normal_tile)