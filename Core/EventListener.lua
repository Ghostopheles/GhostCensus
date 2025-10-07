local DB = GhostCensus.Database;
local Enums = GhostCensus.Enums;

local ICECROWN_UIMAPID = 118;

local EventListener = CreateFrame("Frame");
EventListener.LoggingEnabled = true;

function EventListener:Print(...)
    if not self.LoggingEnabled then
        return;
    end
    GhostCensus.Print("EventListener", ...);
end

function EventListener:OnLoad()
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

    self.Prefixes = DB.Prefixes;

    self.IgnoredChannelNames = {
        ["Trade - City"] = true,
        ["LookingForGroup"] = true,
        ["Services"] = true,
    };

    self.MSPEvent = "MSP_EVENT";

    self.CombatLoggingEnabled = true;

    self:RegisterEvents();
    self:SetScript("OnEvent", self.OnEvent);
end

function EventListener:RegisterEvents()
    for _, eventList in pairs(self.WatchedEvents) do
        for _, event in pairs(eventList) do
            self:RegisterEvent(event);
        end
    end

    self:RegisterEvent("PLAYER_FLAGS_CHANGED");

    if type(msp) == "table" then
        tinsert(msp.callback.updated, function(...) EventListener:HandleMSPDataReceived(...); end);
    end
end

function EventListener:IsValidPrefix(prefix)
    return Enums.AddonMessagePrefixes[prefix] ~= nil;
end

function EventListener:OnEvent(event, ...)
    --if C_Map.GetBestMapForUnit("player") ~= ICECROWN_UIMAPID then
    --    return; -- Ignore events outside of Icecrown
    --end

    if event == "PLAYER_FLAGS_CHANGED" and (... == "player") then
        if UnitIsAFK("player") then
            FlashClientIcon();
        end
        return;
    elseif self.CombatLogEvents[event] then
        return self:HandleCombatLogEvent();
    elseif self.ChatMessageEvents[event] then
        return self:HandleChatMessage(event, ...);
    elseif self.AddonMessageEvents[event] then
        return self:HandleAddonMessage(event, ...);
    elseif event == self.UnitEvents.NAME_PLATE_UNIT_ADDED then
        return self:HandleNameplateAdded(event, ...);
    elseif event == self.UnitEvents.UPDATE_MOUSEOVER_UNIT then
        return self:HandleMouseover(event, ...);
    end
end

function EventListener:ShouldIgnoreChannel(channelName)
    return self.IgnoredChannelNames[channelName];
end

function EventListener:HandleChatMessage(event, ...)
    local channelName = select(9, ...);
    local senderGUID = select(12, ...);

    if self:ShouldIgnoreChannel(channelName) or not senderGUID then
        return;
    end

    DB:AddPlayerEntryByGUID(senderGUID, event);
end

function EventListener:HandleAddonMessage(event, ...)
    local prefix = ...;

    if self:IsValidPrefix(prefix) then
        DB:CountAddonMessagePrefix(prefix);
        DB:CountSource(event);
    end
end

function EventListener:HandleMouseover(event, ...)
    local guid = UnitGUID("mouseover");
    DB:AddPlayerEntryByGUID(guid, event);
end

function EventListener:HandleNameplateAdded(event, nameplate)
    nameplate = C_NamePlate.GetNamePlateForUnit(nameplate);

    if nameplate then
        local guid = nameplate.namePlateUnitGUID;
        DB:AddPlayerEntryByGUID(guid, event);
    end
end

function EventListener:HandleCombatLogEvent(event)
    if not self.CombatLoggingEnabled then
        return;
    end

    local sourceGUID = select(4, CombatLogGetCurrentEventInfo());
    local destGUID = select(8, CombatLogGetCurrentEventInfo());

    DB:AddPlayerEntryByGUID(sourceGUID, self.CombatLogEvents.COMBAT_LOG_EVENT_UNFILTERED);
    DB:AddPlayerEntryByGUID(destGUID, self.CombatLogEvents.COMBAT_LOG_EVENT_UNFILTERED);
end

function EventListener:HandleMSPDataReceived(sender)
    local data = msp.char[sender].field.GU;

    if data then
        local guid = strtrim(data);
        if guid ~= "" and not GhostCensus.UnitGUIDIsCurrentPlayer(guid) then
            DB:AddPlayerEntryByGUID(guid, self.MSPEvent);
        end
    end
end

EventUtil.RegisterOnceFrameEventAndCallback("PLAYER_ENTERING_WORLD", function() EventListener:OnLoad(); end);
