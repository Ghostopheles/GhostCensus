GhostCensus.Database = {};

GhostCensus.Database.Sources = {
    -- Addon sources
    CHAT_MSG_ADDON = "ADDON_MSG",

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
    UNIT_AURA = "UNIT_AURA",
    UPDATE_MOUSEOVER_UNIT = "UPDATE_MOUSEOVER_UNIT",
}

local DB = GhostCensus.Database;

local function slashShowUniqueCharacters()
    DB:Print("Unique characters seen: " .. DB.data.UniqueCharactersSeen);
end

local function slashShowDB()
    if not IsAddOnLoaded("Blizzard_DebugTools") then
        local success, result = LoadAddOn("Blizzard_DebugTools");
        assert(success, "Failed to load Blizzard_DebugTools: " .. (result or "Error N/A"))
    end

    DisplayTableInspectorWindow(DB.data);
end

local function slashClearDB(commit)
    commit = (commit == "1" or commit == 1)

    DB:Wipe(commit)
    if commit then
        C_UI.Reload()
    end
end

function DB:Print(...)
    GhostCensus.Print("Database", ...);
end

function DB:Init()
    self.data = GhostCensusDB;
    self.data.UniqueCharactersSeen = self.data.UniqueCharactersSeen or 0;

    GhostCensus.Slash:RegisterCommand("show", slashShowDB)
    GhostCensus.Slash:RegisterCommand("wipe", slashClearDB)
    GhostCensus.Slash:RegisterCommand("count", slashShowUniqueCharacters)
end

function DB:AddPlayerEntry(playerName, source, dataSheet, dataSheetName)
    if not playerName or playerName == "" then
        return;
    end

    local playerDataEntry = self.data[playerName] or {};

    local meta = {};
    meta.TimesSeen = (playerDataEntry.TimesSeen or 0) + 1;

    playerDataEntry.Meta = meta;
    playerDataEntry.Source = source;
    playerDataEntry[dataSheetName] = dataSheet;

    if self:IsNew(playerName) then
        self.data.UniqueCharactersSeen = self.data.UniqueCharactersSeen + 1;
    end

    self.data[playerName] = playerDataEntry;
    self:Commit();
end

function DB:AddShallowPlayerEntry(playerName, source)
    if GhostCensus.UnitNameIsCursed(playerName) or playerName ~= "" then
        return;
    end

    if self.data[playerName] then
        self.data[playerName].Meta.TimesSeen = self.data[playerName].Meta.TimesSeen + 1;
    else
        self:AddPlayerEntry(playerName, source, {}, "ShallowData");
    end
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
        DB:Init();
        DB:Print("Database loaded.");
    end
end);
