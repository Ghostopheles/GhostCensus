local Globals = GhostCensus.Globals;
local Slash = GhostCensus.Slash;
local Enums = GhostCensus.Enums;

GhostCensus.Database = {};

local COOLDOWN_PERIOD = 300;

local DB = GhostCensus.Database;

local DEFAULT_METRICS = GhostCensus.DEFAULT_METRICS;

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
    local entry = self.data[guid] or {};

    local timestamp = GetServerTime();
    if entry.Timestamp and (timestamp - entry.Timestamp) < COOLDOWN_PERIOD then
        return;
    end

    entry.Timestamp = timestamp;
    entry.Sex = Enums.Sex[sex];
    entry.Race = race;
    entry.Class = class;
    entry.Realm = realm;

    local RPDataSheet = GhostCensus.RP:GenerateDatasheet(normalizedPlayerName, guid);

    if RPDataSheet then
        entry.RPData = RPDataSheet;
    end

    local unitToken = UnitTokenFromGUID(guid);
    if unitToken then
        GhostCensus.Transmog.PollOutfitForUnit(unitToken);
    end

    if self:IsNew(guid) then
        self:CountSource(source);
        self:CountUniquePlayer();
        local faction = self:GetPlayerFactionFromGUID(guid);
        self:CountMetrics(class, race, sex, realm, faction);
        self.LastCharacterSeen = normalizedPlayerName;
    end

    self.data[guid] = entry;
    self:Commit();
end

function DB:UpdateRPDataForPlayerEntry(playerName, guid)
    local entry = self.data[guid];
    if not entry then
        return;
    end

    local datasheet = GhostCensus.RP:GenerateDatasheet(playerName);
    entry.RPData = datasheet;

    self.data[guid] = entry;
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

    local entry = self.data[guid];
    if not entry then
        return;
    end

    entry["Transmog"] = transmogData;

    self.data[guid] = entry;
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

function DB:ShouldAppendFactionToRace(raceName)
    return raceName == "Dracthyr" or raceName == "Earthen" or raceName == "Pandaren";
end

function DB:GetFactionTagForFaction(faction)
    return "_" .. strsub(faction, 1, 1);
end

function DB:CountMetrics(class, race, sex, realm, faction)
    local metrics = self.data.Metrics;

    if self:ShouldAppendFactionToRace(race) then
        local tag = self:GetFactionTagForFaction(faction);
        race = race .. tag;
    end

    metrics.Class[class] = (metrics.Class[class] or 0) + 1;
    metrics.Race[race] = (metrics.Race[race] or 0) + 1;
    metrics.Sex[sex] = (metrics.Sex[sex] or 0) + 1;
    metrics.Realms[realm] = (metrics.Realms[realm] or 0) + 1;
    metrics.Faction[faction] = (metrics.Faction[faction] or 0) + 1;

    self.data.Metrics = metrics;
    self:Commit();
end

function DB:IsNew(guid)
    return self.data[guid] == nil;
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