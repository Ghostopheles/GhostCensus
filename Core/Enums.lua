GhostCensus.Enums = {};

GhostCensus.Enums.Sources = {
    -- Addon sources
    CHAT_MSG_ADDON = "CHAT_MSG_ADDON",
    CHAT_MSG_ADDON_LOGGED = "CHAT_MSG_ADDON_LOGGED",
    TRP3_MAP_SCAN = "TRP3_MAP_SCAN",
    MSP_EVENT = "MSP_EVENT",

    -- Chat event sources
    CHAT_MSG_SAY = "CHAT_MSG_SAY",
    CHAT_MSG_ACHIEVEMENT = "CHAT_MSG_ACHIEVEMENT",
    CHAT_MSG_CHANNEL_JOIN = "CHAT_MSG_CHANNEL_JOIN",
    CHAT_MSG_CHANNEL_LEAVE = "CHAT_MSG_CHANNEL_LEAVE",
    CHAT_MSG_CHANNEL = "CHAT_MSG_CHANNEL",
    CHAT_MSG_EMOTE = "CHAT_MSG_EMOTE",
    CHAT_MSG_TEXT_EMOTE = "CHAT_MSG_TEXT_EMOTE",
    CHAT_MSG_WHISPER = "CHAT_MSG_WHISPER",
    CHAT_MSG_YELL = "CHAT_MSG_YELL",

    -- Unit event sources
    UPDATE_MOUSEOVER_UNIT = "UPDATE_MOUSEOVER_UNIT",
    NAME_PLATE_UNIT_ADDED = "NAME_PLATE_UNIT_ADDED",

    -- Combat log event sources
    COMBAT_LOG_EVENT_UNFILTERED = "COMBAT_LOG_EVENT_UNFILTERED",
};

GhostCensus.Enums.AddonMessagePrefixes = {
    ["TRP3.3"] = "TotalRP3", -- used for TRP3 <-> TRP3 comms
    ["+RP"] = "CrossRP", -- crossRP
    RPB1 = "RPB1", -- used for 'hello' pings and map scan requests
    MSP2 = "MSP2", -- used for comms to/from non-TRP3 users
};

GhostCensus.Enums.Sex = {
    [1] = "Neutral",
    [2] = "Male",
    [3] = "Female",
};

GhostCensus.Enums.Factions = {
    Alliance = "Alliance",
    Horde = "Horde",
    Neutral = "Neutral",
};

GhostCensus.Enums.RaceIDToFaction = {
    [1] = GhostCensus.Enums.Factions.Alliance, -- human
    [2] = GhostCensus.Enums.Factions.Horde, -- orc
    [3] = GhostCensus.Enums.Factions.Alliance, -- dwarf
    [4] = GhostCensus.Enums.Factions.Alliance, -- night elf
    [5] = GhostCensus.Enums.Factions.Horde, -- undead
    [6] = GhostCensus.Enums.Factions.Horde, -- tauren
    [7] = GhostCensus.Enums.Factions.Alliance, -- gnome
    [8] = GhostCensus.Enums.Factions.Horde, -- troll
    [9] = GhostCensus.Enums.Factions.Horde, -- goblin
    [10] = GhostCensus.Enums.Factions.Horde, -- blood elf
    [11] = GhostCensus.Enums.Factions.Alliance, -- draenei
    [22] = GhostCensus.Enums.Factions.Alliance, -- worgen
    [24] = GhostCensus.Enums.Factions.Neutral, -- neutral panda
    [25] = GhostCensus.Enums.Factions.Alliance, -- alliance panda
    [26] = GhostCensus.Enums.Factions.Horde, -- horde panda
    [27] = GhostCensus.Enums.Factions.Horde, -- nightborne
    [28] = GhostCensus.Enums.Factions.Horde, -- highmountain tauren
    [29] = GhostCensus.Enums.Factions.Alliance, -- void elf
    [30] = GhostCensus.Enums.Factions.Alliance, -- lightforged draenei
    [31] = GhostCensus.Enums.Factions.Horde, -- zandalari troll
    [32] = GhostCensus.Enums.Factions.Alliance, -- kul'tiran
    [34] = GhostCensus.Enums.Factions.Alliance, -- dark iron dwarf
    [35] = GhostCensus.Enums.Factions.Horde, -- vulpera
    [36] = GhostCensus.Enums.Factions.Horde, -- mag'har orc
    [37] = GhostCensus.Enums.Factions.Alliance, -- mechagnome
    [52] = GhostCensus.Enums.Factions.Alliance, -- alliance dracthyr
    [70] = GhostCensus.Enums.Factions.Horde, -- horde dracthyr
    [84] = GhostCensus.Enums.Factions.Horde, -- horde earthen dwarf
    [85] = GhostCensus.Enums.Factions.Alliance -- alliance earthen dwarf
};