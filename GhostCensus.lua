-------------------------------------------
-- don't look in here
-- there's nothing to see
-- leave this alone
-------------------------------------------
local addonName = ...;

GhostCensus = {
    Config = {
        ThemeColor = "ff3279a8",
    },
};

local DEFAULT_METRICS = {
    Sex = {
        Neutral = 0,
        Male = 0,
        Female = 0,
    },
    Faction = {
        Alliance = 0,
        Horde = 0,
        Neutral = 0,
    },
    Class = {
        WARRIOR = 0,
        PALADIN = 0,
        HUNTER = 0,
        ROGUE = 0,
        PRIEST = 0,
        DEATHKNIGHT = 0,
        SHAMAN = 0,
        MAGE = 0,
        WARLOCK = 0,
        MONK = 0,
        DRUID = 0,
        DEMONHUNTER = 0,
        EVOKER = 0,
        Adventurer = 0, -- just in case??
    },
    Race = {
        Human = 0,
        Orc = 0,
        Dwarf = 0,
        NightElf = 0,
        Scourge = 0,
        Tauren = 0,
        Gnome = 0,
        Troll = 0,
        Goblin = 0,
        BloodElf = 0,
        Draenei = 0,
        Worgen = 0,
        Pandaren_A = 0,
        Pandaren_H = 0,
        Pandaren_N = 0,
        Nightborne = 0,
        HighmountainTauren = 0,
        VoidElf = 0,
        LightforgedDraenei = 0,
        ZandalariTroll = 0,
        KulTiran = 0,
        DarkIronDwarf = 0,
        MagharOrc = 0,
        Mechagnome = 0,
        Dracthyr_A = 0,
        Dracthyr_H = 0,
        Earthen_A = 0,
        Earthen_H = 0,
    },
    Realms = {},
    Sources = {},
    AddonPrefixes = {},
    UniqueCharacters = 0,
};
GhostCensus.DEFAULT_METRICS = DEFAULT_METRICS;

local function InitSavedVars()
    if not GhostCensusDB then
        GhostCensusDB = {
            Metrics = CopyTable(DEFAULT_METRICS),
        };
    end
end

EventUtil.ContinueOnAddOnLoaded(addonName, InitSavedVars);

function GhostCensus.HasCharacterBeenLogged(guid)
    local db = GhostCensus.Database;
    return not db:IsNew(guid);
end

function GhostCensus.HasUnitBeenLogged(unit)
    unit = unit or "target";

    if not UnitExists(unit) then
        print("Queried unit does not exist.");
        return;
    end

    local db = GhostCensus.Database;
    local guid = UnitGUID(unit);

    return not db:IsNew(guid);
end