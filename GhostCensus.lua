-------------------------------------------
-- don't look in here
-- there's nothing to see
-- leave this alone
-------------------------------------------

GhostCensus = {};
GhostCensus.Config = {
    ThemeColor = "ff3279a8"
};

local saveDataHandler = CreateFrame("Frame");
saveDataHandler:RegisterEvent("PLAYER_ENTERING_WORLD");
saveDataHandler:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        if not GhostCensusDB then
            GhostCensusDB = GhostCensus.Table.new{};
        end

        if not GhostCensus.Table.IsGhostly(GhostCensusDB) then
            GhostCensusDB = GhostCensus.Table.from(GhostCensusDB, "GhostCensusDB");
        end

        GhostCensus.Globals = {
            PlayerName = GetUnitName("player") .. "-" .. GetNormalizedRealmName();
            PlayerRealm = GetNormalizedRealmName();
            PlayerNameNoRealm = GetUnitName("player", false);
            PlayerGUID = UnitGUID("player");
        }
    end
end)



