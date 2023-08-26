GhostCensus.EventListener = CreateFrame("Frame", "GhostEventListener", UIParent)
GhostCensus.EventListener.loggingEnabled = true

function GhostCensus.EventListener:Print(...)
    if not self.loggingEnabled then
        return;
    end
    GhostCensus.Print("EventListener", ...);
end

function GhostCensus.EventListener:GetUsablePlayerName(playerName)
    local name, realm = strsplit("-", playerName, 2);

    if realm == nil then
        realm = GhostCensus.Globals.PlayerRealm;
    end

    return name .. "-" .. realm;
end

function GhostCensus.EventListener:OnLoad()
    self.ChatMessageEvents = {
        CHAT_MSG_ACHIEVEMENT = "CHAT_MSG_ACHIEVEMENT",
        CHAT_MSG_CHANNEL_JOIN = "CHAT_MSG_CHANNEL_JOIN",
        CHAT_MSG_CHANNEL = "CHAT_MSG_CHANNEL",
        CHAT_MSG_EMOTE = "CHAT_MSG_EMOTE",
        CHAT_MSG_SAY = "CHAT_MSG_SAY",
        CHAT_MSG_TEXT_EMOTE = "CHAT_MSG_TEXT_EMOTE",
        CHAT_MSG_WHISPER = "CHAT_MSG_WHISPER",
        CHAT_MSG_YELL = "CHAT_MSG_YELL",
    };

    self.AddonMessageEvents = {
        CHAT_MSG_ADDON = "CHAT_MSG_ADDON",
        CHAT_MSG_ADDON_LOGGED = "CHAT_MSG_ADDON_LOGGED",
    };

    self.UnitEvents = {
        UPDATE_MOUSEOVER_UNIT = "UPDATE_MOUSEOVER_UNIT",
        NAME_PLATE_UNIT_ADDED = "NAME_PLATE_UNIT_ADDED",
    };

    self.CombatLogEvents = {
        COMBAT_LOG_EVENT_UNFILTERED = "COMBAT_LOG_EVENT_UNFILTERED",
    };

    self.WatchedEvents = {self.ChatMessageEvents, self.AddonMessageEvents, self.UnitEvents, self.CombatLogEvents};

    self.Prefixes = GhostCensus.Database.Prefixes;

    self.IgnoredChannelNames = {
        "Trade - City",
        "LookingForGroup",
        "Services",
    };

    self.MSPEvent = "MSP_EVENT";

    self.CombatLoggingEnabled = true;

    self:RegisterEvents();
    self:SetScript("OnEvent", self.OnEvent);
end

function GhostCensus.EventListener:RegisterEvents()
    for _, eventList in pairs(self.WatchedEvents) do
        for _, event in pairs(eventList) do
            self:RegisterEvent(event);
        end
    end

    self:RegisterEvent("PLAYER_FLAGS_CHANGED");
end

function GhostCensus.EventListener:IsValidPrefix(prefix)
    for k, _ in pairs(self.Prefixes) do
        if prefix == k then
            return true;
        end
    end
end

function GhostCensus.EventListener:OnEvent(event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        if not select(1, ...) then
            return;
        end

        self:OnLoad()
    elseif event == "PLAYER_FLAGS_CHANGED" and (... == "player") then
        if UnitIsAFK("player") then
            FlashClientIcon();
        end
        return;
    elseif tContains(self.CombatLogEvents, event) then
        return self:HandleCombatLogEvent();
        --return;
    elseif tContains(self.ChatMessageEvents, event) then
        return self:HandleChatMessage(event, ...);
        --return;
    elseif tContains(self.AddonMessageEvents, event) then
        return self:HandleAddonMessage(event, ...);
    elseif event == self.UnitEvents.NAME_PLATE_UNIT_ADDED then
        return self:HandleNameplateAdded(event, ...);
        --return;
    elseif event == self.UnitEvents.UPDATE_MOUSEOVER_UNIT then
        return self:HandleMouseover(event, ...);
        --return;
    end
end

function GhostCensus.EventListener:HandleChatMessage(event, ...)
    local _, _, _, _, playerName2, specialFlags, _, _, channelName, _, lineID, senderGUID, _ = ...;
    
    for _, ignoredChannel in ipairs(self.IgnoredChannelNames) do
        if string.match(channelName, ignoredChannel) then
            return;
        end
    end

    if not senderGUID or GhostCensus.UnitGUIDIsCurrentPlayer(senderGUID) or not C_PlayerInfo.GUIDIsPlayer(senderGUID) then -- skip messages from self and npcs
        return;
    end

    local dataSheet = {};
    local dataSheetName = "ChatMessageData";

    dataSheet.ChannelName = channelName or "None";
    dataSheet.TargetPlayerName = playerName2;
    dataSheet.IsGM = specialFlags:find("GM") ~= nil;
    dataSheet.ChatLineID = lineID;

    GhostCensus.Database:AddPlayerEntryByGUID(senderGUID, self.ChatMessageEvents[event], dataSheet, dataSheetName);
end

function GhostCensus.EventListener:HandleAddonMessage(event, ...)
    local prefix, _, _, sender, _ = ...;

    if self:IsValidPrefix(prefix) and GhostCensus.Database:IsNew(sender) then
        GhostCensus.Database:CountAddonMessagePrefix(prefix);
        GhostCensus.Database:CountSource(event);
        return;
    end
end

function GhostCensus.EventListener:HandleMouseover(_, ...)
    local guid = UnitGUID("mouseover");
    local event = self.UnitEvents.UPDATE_MOUSEOVER_UNIT;

    GhostCensus.Database:AddPlayerEntryByGUID(guid, self.UnitEvents[event]);
end

function GhostCensus.EventListener:HandleNameplateAdded(_, nameplate)
    nameplate = C_NamePlate.GetNamePlateForUnit(nameplate);

    if not nameplate then
        return;
    end

    local guid = nameplate.namePlateUnitGUID;

    GhostCensus.Database:AddPlayerEntryByGUID(guid, self.UnitEvents.NAME_PLATE_UNIT_ADDED);
end

function GhostCensus.EventListener:HandleCombatLogEvent()
    if not GhostCensus.EventListener.CombatLoggingEnabled then
        return;
    end

    local timestamp, subevent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = CombatLogGetCurrentEventInfo();

    GhostCensus.Database:AddPlayerEntryByGUID(sourceGUID, self.CombatLogEvents.COMBAT_LOG_EVENT_UNFILTERED, nil, nil, timestamp);
    GhostCensus.Database:AddPlayerEntryByGUID(destGUID, self.CombatLogEvents.COMBAT_LOG_EVENT_UNFILTERED, nil, nil, timestamp);
end

function GhostCensus.EventListener:HandleMSPDataReceived(sender)
    local data = msp.char[sender].field.GU;

    if data then
        local guid = strtrim(data);
        if guid ~= "" and guid ~= UnitGUID("player") then
            if C_PlayerInfo.GUIDIsPlayer(guid) and GhostCensus.Database:IsNew(sender) then
                GhostCensus.Database:AddPlayerEntryByGUID(guid, self.MSPEvent);
            end
        end
    end
end

GhostCensus.EventListener:RegisterEvent("PLAYER_ENTERING_WORLD");
GhostCensus.EventListener:SetScript("OnEvent", GhostCensus.EventListener.OnLoad);

GhostCensus.EventListener.EventFrame = CreateFrame("Frame");

tinsert(msp.callback.updated, function(...) GhostCensus.EventListener:HandleMSPDataReceived(...) end);
