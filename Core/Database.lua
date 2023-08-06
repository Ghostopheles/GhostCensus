GhostCensus.Database = {};

GhostCensus.Database.Sources = {
    -- Addon sources
    CHAT_MSG_ADDON = "ADDON_MSG",
    CHAT_MSG_ADDON_LOGGED = "ADDON_MSG_LOGGED",
    TRP3_MAP_SCAN = "TRP3_MAP_SCAN",
    MSP_EVENT = "MSP_EVENT",

    -- Chat event sources
    CHAT_MSG_SAY = "CHAT_SAY",
    CHAT_MSG_ACHIEVEMENT = "CHAT_ACHIEVEMENT",
    CHAT_MSG_CHANNEL_JOIN = "CHAT_CHANNEL_JOIN",
    CHAT_MSG_CHANNEL_LEAVE = "CHAT_CHANNEL_LEAVE",
    CHAT_MSG_CHANNEL = "CHAT_CHANNEL",
    CHAT_MSG_EMOTE = "CHAT_EMOTE",
    CHAT_MSG_TEXT_EMOTE = "CHAT_TEXT_EMOTE",
    CHAT_MSG_WHISPER = "CHAT_WHISPER",
    CHAT_MSG_YELL = "CHAT_YELL",

    -- Unit event sources
    UPDATE_MOUSEOVER_UNIT = "MOUSEOVER",
    NAME_PLATE_UNIT_ADDED = "NAMEPLATE_ADDED",

    -- Combat log event sources
    COMBAT_LOG_EVENT_UNFILTERED = "COMBAT_LOG",
};

GhostCensus.Database.Prefixes = {
    ["TRP3.3"] = "TotalRP3", -- used for TRP3 <-> TRP3 comms
    ["+RP"] = "CrossRP", -- crossRP
    RPB1 = "RPB1", -- used for 'hello' pings and map scan requests
    MSP2 = "MSP2", -- used for comms to/from non-TRP3 users
};

GhostCensus.Database.Genders = {
    [1] = "Neutral",
    [2] = "Male",
    [3] = "Female",
};

GhostCensus.Database.Factions = {
    Alliance = "Alliance",
    Horde = "Horde",
    Neutral = "Neutral",
};

GhostCensus.Database.RaceIDToFaction = {
    [1] = GhostCensus.Database.Factions.Alliance, -- human
    [2] = GhostCensus.Database.Factions.Horde, -- orc
    [3] = GhostCensus.Database.Factions.Alliance, -- dwarf
    [4] = GhostCensus.Database.Factions.Alliance, -- night elf
    [5] = GhostCensus.Database.Factions.Horde, -- undead
    [6] = GhostCensus.Database.Factions.Horde, -- tauren
    [7] = GhostCensus.Database.Factions.Alliance, -- gnome
    [8] = GhostCensus.Database.Factions.Horde, -- troll
    [9] = GhostCensus.Database.Factions.Horde, -- goblin
    [10] = GhostCensus.Database.Factions.Horde, -- blood elf
    [11] = GhostCensus.Database.Factions.Alliance, -- draenei
    [22] = GhostCensus.Database.Factions.Alliance, -- worgen
    [24] = GhostCensus.Database.Factions.Neutral, -- neutral panda
    [25] = GhostCensus.Database.Factions.Alliance, -- alliance panda
    [26] = GhostCensus.Database.Factions.Horde, -- horde panda
    [27] = GhostCensus.Database.Factions.Horde, -- nightborne
    [28] = GhostCensus.Database.Factions.Horde, -- highmountain tauren
    [29] = GhostCensus.Database.Factions.Alliance, -- void elf
    [30] = GhostCensus.Database.Factions.Alliance, -- lightforged draenei
    [31] = GhostCensus.Database.Factions.Horde, -- zandalari troll
    [32] = GhostCensus.Database.Factions.Alliance, -- kul'tiran
    [34] = GhostCensus.Database.Factions.Alliance, -- dark iron dwarf
    [35] = GhostCensus.Database.Factions.Horde, -- vulpera
    [36] = GhostCensus.Database.Factions.Horde, -- mag'har orc
    [37] = GhostCensus.Database.Factions.Alliance, -- mechagnome
    [52] = GhostCensus.Database.Factions.Alliance, -- alliance dracthyr
    [70] = GhostCensus.Database.Factions.Horde, -- horde dracthyr
};

local defaultMetrics = {
    Gender = {
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
    Realm = {},
}

local DB = GhostCensus.Database;

local function slashShowUniqueCharacters()
    DB:Print("Unique characters seen: " .. DB.data.UniqueCharactersSeen);
end

local function slashShowDB(target)
    if not IsAddOnLoaded("Blizzard_DebugTools") then
        local success, result = LoadAddOn("Blizzard_DebugTools");
        assert(success, "Failed to load Blizzard_DebugTools: " .. (result or "Error N/A"))
    end

    if not target then
        local name, realm = UnitFullName("target");
        if not name then return; end
        if not realm then realm = GetNormalizedRealmName(); end
        target = name .. "-" .. realm;
    end

    DisplayTableInspectorWindow(DB.data[target]);
end

local function slashShowDBMetrics()
    if not IsAddOnLoaded("Blizzard_DebugTools") then
        local success, result = LoadAddOn("Blizzard_DebugTools");
        assert(success, "Failed to load Blizzard_DebugTools: " .. (result or "Error N/A"))
    end

    DisplayTableInspectorWindow(DB.data.Metrics);
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
    self.data = GhostCensusDB;
    self.data.UniqueCharactersSeen = self.data.UniqueCharactersSeen or 0;
    self.data.SourcesCount = self.data.SourcesCount or {};
    self.data.Metrics = self.data.Metrics or defaultMetrics;
    self.LastCharacterSeen = nil;

    for k, _ in pairs(self.Sources) do
        if type(self.data.SourcesCount[k]) ~= "number" then
            if k ~= "ADDON_PREFIXES" then
                self.data.SourcesCount[k] = 0;
            end
        end
    end

    if not self.data.SourcesCount.ADDON_PREFIXES or type(self.data.SourcesCount.ADDON_PREFIXES) ~= "table" then
        local addonPrefixes = {};
        for prefix, _ in pairs(self.Prefixes) do
            addonPrefixes[prefix] = 0;
        end
        self.data.SourcesCount.ADDON_PREFIXES = addonPrefixes;
    end

    GhostCensus.Slash:RegisterCommand("show", slashShowDB);
    GhostCensus.Slash:RegisterCommand("wipe", slashClearDB);
    GhostCensus.Slash:RegisterCommand("count", slashShowUniqueCharacters);
    GhostCensus.Slash:RegisterCommand("metrics", slashShowDBMetrics);
end

function DB:AddPlayerEntryByGUID(guid, source, customDatasheet, customDatasheetName, timestamp)
    if C_Map.GetBestMapForUnit("player") ~= 118 then
        return;
    end

    if not guid or GhostCensus.UnitGUIDIsCurrentPlayer(guid) or not C_PlayerInfo.GUIDIsPlayer(guid) then
        return;
    end

    local localPlayerName, localPlayerRealm = UnitName("player"), GetNormalizedRealmName();
    if not localPlayerRealm then
        return;
    end

    local _, class, _, race, sex, name, realm = GetPlayerInfoByGUID(guid);

    if not name then
        return;
    end

    if not realm or realm == "" then
        realm = localPlayerRealm;
    end

    local normalizedPlayerName = name .. "-" .. realm;
    if normalizedPlayerName == localPlayerName .. "-" .. localPlayerRealm then
        return;
    end

    local playerDataEntry = self.data[normalizedPlayerName] or {};

    if timestamp then
        if playerDataEntry.Timestamp and (timestamp - playerDataEntry.Timestamp) < 60 then
            return;
        end
        playerDataEntry.Timestamp = timestamp;
    end

    playerDataEntry.TimesSeen = (playerDataEntry.TimesSeen or 0) + 1;
    playerDataEntry.GUID = guid;
    playerDataEntry.Sex = self.Genders[sex];
    playerDataEntry.Race = race;
    playerDataEntry.Class = class;

    if customDatasheet then
        playerDataEntry[customDatasheetName] = customDatasheet;
    end

    local TRP3DataSheet = GhostCensus.Integrations.TRP3.DataGatherer:GenerateTRP3DataSheet(guid);

    if TRP3DataSheet then
        playerDataEntry["TRP3Data"] = TRP3DataSheet;
    end

    if self:IsNew(normalizedPlayerName) then
        self:CountUniquePlayer();
        local faction = self:GetPlayerFactionFromGUID(guid);
        self:CountMetrics(class, race, sex, realm, faction);
        self.LastCharacterSeen = normalizedPlayerName;
    end

    self:CountSource(source);
    self.data[normalizedPlayerName] = playerDataEntry;
    self:Commit();
end

function DB:AddDataToPlayerEntryByName(playerName, source, customDatasheet, customDatasheetName)
    local localPlayerName, localPlayerRealm = UnitName("player"), GetNormalizedRealmName();
    if not localPlayerRealm then
        return;
    end

    if playerName == localPlayerName .. "-" .. localPlayerRealm then
        return;
    end

    if self:IsNew(playerName) then
        self:CountUniquePlayer();
        self.LastCharacterSeen = playerName;
    end

    local playerDataEntry = self.data[playerName] or {};
    playerDataEntry.TimesSeen = (playerDataEntry.TimesSeen or 0) + 1;

    playerDataEntry[customDatasheetName] = customDatasheet;

    self:CountSource(source);
    self.data[playerName] = playerDataEntry;
    self:Commit();
end

function DB:AddShallowPlayerEntry(playerName, source, addonMessagePrefix)
    if GhostCensus.UnitNameIsCursed(playerName) or playerName == "" then
        return;
    end

    local playerDataEntry = self.data[playerName];

    if playerDataEntry then
        playerDataEntry.TimesSeen = (playerDataEntry.TimesSeen or 0) + 1;
    else
        playerDataEntry = {};
        playerDataEntry.TimesSeen = 1;
        self:CountUniquePlayer();
        self.LastCharacterSeen = playerName;
    end

    if addonMessagePrefix then
        self:CountAddonMessagePrefix(addonMessagePrefix);
    end

    self:CountSource(source);
    self.data[playerName] = playerDataEntry;
    self:Commit();
end

function DB:GetPlayerFactionFromGUID(playerGUID)
    local raceID = C_PlayerInfo.GetRace({guid = playerGUID});
    local faction = self.RaceIDToFaction[raceID];
    return faction;
end

function DB:CountAddonMessagePrefix(prefix)
    self.data.SourcesCount.ADDON_PREFIXES[prefix] = (self.data.SourcesCount.ADDON_PREFIXES[prefix] or 0) + 1;
end

function DB:CountSource(source)
    self.data.SourcesCount[source] = (self.data.SourcesCount[source] or 0) + 1;

    if source == "TRP3_MAP_SCAN" then
        self.data.SourcesCount.CHAT_MSG_ADDON = self.data.SourcesCount.CHAT_MSG_ADDON - 1;
    end
end

function DB:CountUniquePlayer()
    self.data.UniqueCharactersSeen = (self.data.UniqueCharactersSeen or 0) + 1;
end

function DB:CountMetrics(class, race, sex, realm, faction)
    self.data.Metrics.Class[class] = (self.data.Metrics.Class[class] or 0) + 1;
    self.data.Metrics.Race[race] = (self.data.Metrics.Race[race] or 0) + 1;

    local gender = self.Genders[sex];
    self.data.Metrics.Gender[gender] = (self.data.Metrics.Gender[gender] or 0) + 1;
    self.data.Metrics.Realm[realm] = (self.data.Metrics.Realm[realm] or 0) + 1;
    self.data.Metrics.Faction[faction] = (self.data.Metrics.Faction[faction] or 0) + 1;
end

function DB:IsNew(playerName)
    return self.data[playerName] == nil;
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

local loadHandler = CreateFrame("Frame");
loadHandler:RegisterEvent("PLAYER_ENTERING_WORLD");
loadHandler:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        local isInitialLogin, _ = ...;
        DB:Init();

        if isInitialLogin then
            DB:Print("Database loaded.");
        end
    end
end);
