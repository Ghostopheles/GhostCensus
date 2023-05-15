GhostCensus.EventListener = CreateFrame("Frame", "GhostEventListener", UIParent)
GhostCensus.EventListener.loggingEnabled = true

function GhostCensus.EventListener:Print(...)
    if not self.loggingEnabled then
        return
    end
    GhostCensus.Print("EventListener", ...)
end

function GhostCensus.EventListener:GetUsablePlayerName(playerName)
    local name, realm = strsplit("-", playerName, 2);

    if realm == nil then
        realm = "MoonGuard"
    end

    return name .. "-" .. realm
end

function GhostCensus.EventListener:OnLoad()
    self.ChatMessageEvents = {
        CHAT_MSG_ACHIEVEMENT = "CHAT_MSG_ACHIEVEMENT",
        CHAT_MSG_CHANNEL_JOIN = "CHAT_MSG_CHANNEL_JOIN",
        CHAT_MSG_CHANNEL_LEAVE = "CHAT_MSG_CHANNEL_LEAVE",
        CHAT_MSG_CHANNEL = "CHAT_MSG_CHANNEL",
        CHAT_MSG_EMOTE = "CHAT_MSG_EMOTE",
        CHAT_MSG_SAY = "CHAT_MSG_SAY",
        CHAT_MSG_TEXT_EMOTE = "CHAT_MSG_TEXT_EMOTE",
        CHAT_MSG_WHISPER = "CHAT_MSG_WHISPER",
        CHAT_MSG_YELL = "CHAT_MSG_YELL",
    }

    self.AddonMessageEvents = {
        CHAT_MSG_ADDON = "CHAT_MSG_ADDON",
    }

    self.UnitEvents = {
        UNIT_AURA = "UNIT_AURA",
        UPDATE_MOUSEOVER_UNIT = "UPDATE_MOUSEOVER_UNIT",
    }

    self.WatchedEvents = {self.ChatMessageEvents, self.AddonMessageEvents, self.UnitEvents}

    self.Prefixes = {
        ["TRP3.3"] = "TotalRP3",
        RPB1 = "RPB1",
        DTLS = "Details",
        LRS = "LRS",
        MSP2 = "MSP2",
        ELVUI = "ELVUI_VERSIONCHK",
        ELVUIPLUGIN = "ElvUIPluginVC",
    }

    self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvents()
    self:SetScript("OnEvent", self.OnEvent)
end

function GhostCensus.EventListener:RegisterEvents()
    for _, eventList in pairs(self.WatchedEvents) do
        for _, event in pairs(eventList) do
            self:RegisterEvent(event)
        end
    end
end

function GhostCensus.EventListener:OnEvent(event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        self:OnLoad()
        self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    elseif tContains(self.ChatMessageEvents, event) then
        return self:HandleChatMessage(event, ...)
    elseif tContains(self.AddonMessageEvents, event) then
        return self:HandleAddonMessage(event, ...)
    end
end

function GhostCensus.EventListener:HandleChatMessage(event, ...)
    local _, sender, _, _, playerName2, specialFlags, _, channelName, _, _, lineID, senderGUID, _ = ...;

    if not senderGUID or GhostCensus.UnitGUIDIsCurrentPlayer(senderGUID) or not C_PlayerInfo.GUIDIsPlayer(senderGUID) then -- skip messages from self and npcs
        return;
    end

    local dataSheet = {};
    local dataSheetName = "ChatMessageData";
    local _, class, _, race, sex, name, realm = GetPlayerInfoByGUID(senderGUID);

    if not realm or realm == "" then
        realm = "MoonGuard"
    end

    local playerName = name .. "-" .. realm;
    dataSheet.Class = class;
    dataSheet.Race = race;
    dataSheet.Sex = sex;
    dataSheet.SenderGUID = senderGUID;
    dataSheet.ChannelName = channelName or "None";
    dataSheet.TargetPlayerName = playerName2;
    dataSheet.IsGM = specialFlags:find("GM") ~= nil;
    dataSheet.ChatLineID = lineID;

    GhostCensus.Database:AddPlayerEntry(playerName, GhostCensus.Database.Sources[event], dataSheet, dataSheetName);

    if playerName2 ~= sender and not GhostCensus.UnitNameIsCurrentPlayer(playerName2) then
        GhostCensus.Database:AddShallowPlayerEntry(playerName2, GhostCensus.Database.Sources[event]);
    end
end

function GhostCensus.EventListener:HandleAddonMessage(event, ...)
    local prefix, _, _, sender, target, _ = ...;

    if not tContains(self.Prefixes, prefix) then
        return;
    end

    if GhostCensus.UnitNameIsCurrentPlayer(sender) then -- skip messages from self
        return;
    end

    local name, realm = strsplit("-", sender, 2);
    if not realm or realm == "" then
        realm = "MoonGuard"
    end

    name = name .. "-" .. realm

    local dataSheet = {};
    local dataSheetName = "AddonMessageData";
    dataSheet.Prefix = prefix;

    GhostCensus.Database:AddPlayerEntry(name, GhostCensus.Database.Sources.CHAT_MSG_ADDON, dataSheet, dataSheetName);

    if target ~= sender and not GhostCensus.UnitNameIsCurrentPlayer(target) then
        GhostCensus.Database:AddShallowPlayerEntry(target, GhostCensus.Database.Sources.CHAT_MSG_ADDON);
    end
end

function GhostCensus.EventListener:HandleUnitEvent(event, ...)
    if event == self.UnitEvents.UPDATE_MOUSEOVER_UNIT then
        local guid = UnitGUID("mouseover");

        if not guid or GhostCensus.UnitGUIDIsCurrentPlayer(guid) or not C_PlayerInfo.GUIDIsPlayer(guid) then -- skip updating self or npcs
            return;
        end

        local dataSheet = {};
        local dataSheetName = "MouseoverData";
        local _, class, _, race, sex, name, realm = GetPlayerInfoByGUID(guid);

        if not realm or realm == "" then
            realm = "MoonGuard"
        end

        local playerName = name .. "-" .. realm;
        dataSheet.Class = class;
        dataSheet.Race = race;
        dataSheet.Sex = sex;
        dataSheet.GUID = guid;
        dataSheet.ChannelName = channelName or "None";
        dataSheet.TargetPlayerName = playerName2;
        dataSheet.IsGM = specialFlags:find("GM") ~= nil;
        dataSheet.ChatLineID = lineID;

        GhostCensus.Database:AddPlayerEntry(playerName, GhostCensus.Database.Sources[event], dataSheet, dataSheetName);
    end
end

GhostCensus.EventListener:RegisterEvent("PLAYER_ENTERING_WORLD")
GhostCensus.EventListener:SetScript("OnEvent", GhostCensus.EventListener.OnLoad)

GhostCensus.EventListener.EventFrame = CreateFrame("Frame")
