local Globals = GhostCensus.Globals;
local Slash = GhostCensus.Slash;
local Enums = GhostCensus.Enums;

GhostCensus.Database = {};

local COOLDOWN_PERIOD = 300;
local band = bit.band;
local bxor = bit.bxor;

local DB = GhostCensus.Database;

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
        Pandaren = 0,
        Nightborne = 0,
        HighmountainTauren = 0,
        VoidElf = 0,
        LightforgedDraenei = 0,
        ZandalariTroll = 0,
        KulTiran = 0,
        DarkIronDwarf = 0,
        MagharOrc = 0,
        Mechagnome = 0,
        Dracthyr = 0,
    },
    Realms = {},
    Sources = {},
    AddonPrefixes = {},
    UniqueCharacters = 0,
};

for k, _ in pairs(Enums.Sources) do
    DEFAULT_METRICS.Sources[k] = 0;
end

for k, _ in pairs(Enums.AddonMessagePrefixes) do
    DEFAULT_METRICS.AddonPrefixes[k] = 0;
end

local function slashClearDB(commit)
    commit = (commit == "1" or commit == 1);

    DB:Wipe(commit)
    if commit then
        C_UI.Reload();
    end
end

function DB:Print(...)
    GhostCensus.Print("Database", ...);
end

function DB:Init()
    if not Globals then
        Globals = GhostCensus.Globals;
    end

    self.data = CopyTable(GhostCensusDB);
    self.data.Metrics = self.data.Metrics or DEFAULT_METRICS;
    self.LastCharacterSeen = nil;

    Slash:RegisterCommand("wipe", slashClearDB);

    GhostCensus.RP.EventRegistry:RegisterCallback(GhostCensus.RP.Events.RP_DATA_UPDATED, self.UpdateRPDataForPlayerEntry, self);

    self:Print("Database loaded.");
end

function DB:GenerateHash(str)
    local prime = 16777619;
    local hash = 2166136261;

    for i = 1, #str do
        hash = bit.bxor(hash, str:byte(i));
        hash = bit.band((hash * prime), 0xFFFFFFFF);
    end

    return string.format("%08x", hash);
end

--- All arguments must be non-nil and not an empty string
function DB:Validate(...)
    for i=1, select("#", ...) do
        local value = select(i, ...);
        if not value or value == "" then
            return false;
        end
    end

    return true;
end

function DB:AddPlayerEntryByGUID(guid, source)
    if not guid or not C_PlayerInfo.GUIDIsPlayer(guid) or GhostCensus.UnitGUIDIsCurrentPlayer(guid) then
        return;
    end

    local _, class, _, race, sex, name, realm = GetPlayerInfoByGUID(guid);

    if not self:Validate(class, race, sex, name) then
        return;
    end

    if not self:Validate(realm) then
        realm = Globals.PlayerRealm;
    end

    local normalizedPlayerName = name .. "-" .. realm;
    local playerHash = self:GenerateHash(normalizedPlayerName .. guid);
    local entry = self.data[playerHash] or {};

    local timestamp = GetServerTime();
    if entry.Timestamp and (timestamp - entry.Timestamp) < COOLDOWN_PERIOD then
        return;
    end

    entry.Timestamp = timestamp;
    entry.Sex = Enums.Sex[sex];
    entry.Race = race;
    entry.Class = class;
    entry.Realm = realm;

    if entry.IsTimerunner == nil then
        entry.IsTimerunner = C_ChatInfo.IsTimerunningPlayer(guid);
    end

    local RPDataSheet = GhostCensus.RP:GenerateDatasheet(normalizedPlayerName, guid);

    if RPDataSheet then
        entry["RPData"] = RPDataSheet;
    end

    local unitToken = UnitTokenFromGUID(guid);
    if unitToken then
        GhostCensus.Transmog.PollOutfitForUnit(unitToken);
    end

    if self:IsNew(playerHash) then
        self:CountUniquePlayer();
        local faction = self:GetPlayerFactionFromGUID(guid);
        self:CountMetrics(class, race, sex, realm, faction);
        self.LastCharacterSeen = normalizedPlayerName;
    end

    self:CountSource(source);
    self.data[playerHash] = entry;
    self:Commit();
end

function DB:UpdateRPDataForPlayerEntry(playerName, guid)
    local playerHash = self:GenerateHash(playerName .. guid);
    local entry = self.data[playerHash];
    if not entry then
        return;
    end

    local datasheet = GhostCensus.RP:GenerateDatasheet(playerName);
    entry["RPData"] = datasheet;

    self.data[playerHash] = entry;
    self:Commit();
end

function DB:UpdateTransmogForPlayer(guid, transmogData)
    local _, class, _, race, sex, name, realm = GetPlayerInfoByGUID(guid);

    if not self:Validate(class, race, sex, name) then
        return;
    end

    if not self:Validate(realm) then
        realm = Globals.PlayerRealm;
    end

    local normalizedPlayerName = name .. "-" .. realm;

    local playerHash = self:GenerateHash(normalizedPlayerName .. guid);
    local entry = self.data[playerHash];
    if not entry then
        return;
    end

    entry["Transmog"] = transmogData;

    self.data[playerHash] = entry;
    self:Commit();
end

function DB:GetPlayerFactionFromGUID(playerGUID)
    local raceID = C_PlayerInfo.GetRace({guid = playerGUID});
    local faction = Enums.RaceIDToFaction[raceID];
    return faction;
end

function DB:CountAddonMessagePrefix(prefix)
    if not Enums.AddonMessagePrefixes[prefix] then
        return;
    end

    self.data.Metrics.AddonPrefixes[prefix] = (self.data.Metrics.AddonPrefixes[prefix] or 0) + 1;
    self:Commit();
end

function DB:CountSource(source)
    if not Enums.Sources[source] then
        return;
    end

    self.data.Metrics.Sources[source] = (self.data.Metrics.Sources[source] or 0) + 1;
    self:Commit();
end

function DB:CountUniquePlayer()
    self.data.Metrics.UniqueCharacters = (self.data.Metrics.UniqueCharacters or 0) + 1;
    self:Commit();
end

function DB:CountMetrics(class, race, sex, realm, faction)
    local metrics = self.data.Metrics;

    metrics.Class[class] = (metrics.Class[class] or 0) + 1;
    metrics.Race[race] = (metrics.Race[race] or 0) + 1;
    metrics.Sex[sex] = (metrics.Sex[sex] or 0) + 1;
    metrics.Realms[realm] = (metrics.Realms[realm] or 0) + 1;
    metrics.Faction[faction] = (metrics.Faction[faction] or 0) + 1;

    self.data.Metrics = metrics;
    self:Commit();
end

function DB:IsNew(playerHash)
    return self.data[playerHash] == nil;
end

function DB:Commit()
    GhostCensusDB = self.data;
end

function DB:Wipe(commit)
    self.data = {};

    if commit then
        self:Commit();
        self:Print("Saved data wiped.");
    else
        self:Print("Session table wiped.");
    end
end