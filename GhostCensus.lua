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

local function InitSavedVars()
    if not GhostCensusDB then
        GhostCensusDB = {};
    end
end

EventUtil.ContinueOnAddOnLoaded(addonName, InitSavedVars);