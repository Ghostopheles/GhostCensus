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

function GhostCensus.HasCharacterBeenLogged(unitName, realm, guid)
    local db = GhostCensus.Database;
    local hash = db:GenerateHash(format("%s-%s%s", unitName, realm, guid));
    return not db:IsNew(hash);
end

function GhostCensus.HasUnitBeenLogged(unit)
    unit = unit or "target";

    if not UnitExists(unit) then
        print("Queried unit does not exist.");
        return;
    end

    local db = GhostCensus.Database;
    local name, realm = UnitFullName(unit);
    if not realm or realm == "" then
        realm = GetNormalizedRealmName();
    end

    local id = format("%s-%s%s", name, realm, UnitGUID(unit));
    local hash = db:GenerateHash(id);

    return not db:IsNew(hash);
end