GhostCensus.Integrations.TRP3.MapScan = {};

local moduleName = "CensusMapScan";

local broadcast = AddOn_TotalRP3.Communications.broadcast;
local Map = AddOn_TotalRP3.Map;
local Ellyb = TRP3_API.Ellyb;

local function calculateAverage(t)
    local sum = 0
    for _,v in pairs(t) do
        sum = sum + v
    end
    return sum / #t
end

local debugTimes = {};

local function generateDataSheet(sender, position, poiInfo)
    local startTime = debugprofilestop();
    local player = AddOn_TotalRP3.Player.CreateFromCharacterID(sender);

    local dataSheet = {};

    if TRP3_API.register.isUnitIDKnown(sender) then
        dataSheet.IsTrial = player:IsOnATrialAccount() or nil;
        dataSheet.AccountType = player:GetAccountType() or nil;
    end

    dataSheet.ProfileID = player:GetProfileID() or nil;
    dataSheet.IsCurrentUser = player:IsCurrentUser() or nil;
    dataSheet.CharacterID = player:GetCharacterID() or nil;
    dataSheet.IsInWarMode = poiInfo.hasWarModeActive;
    dataSheet.Position = {x = position.x, y = position.y};
    dataSheet.RoleplayStatus = poiInfo.roleplayStatus;
    dataSheet.FormattedName = player:GenerateFormattedName(TRP3_PlayerNameFormat.Colored) or nil;
    dataSheet.FirstName = player:GetFirstName() or nil;
    dataSheet.LastName = player:GetLastName() or nil;
    dataSheet.ShortTitle = player:GetTitle() or nil;
    dataSheet.FullTitle = player:GetFullTitle() or nil;
    dataSheet.RoleplayExperience = player:GetRoleplayExperience() or nil;
    dataSheet.Pronouns = player:GetCustomPronouns() or nil;
    dataSheet.Icon = player:GetCustomIcon() or nil;

    local endTime = debugprofilestop();
    table.insert(debugTimes, endTime - startTime);

    return dataSheet;
end

Ghost.Events.RegisterCallback(TRP3_Addon, TRP3_Addon.Events.WORKFLOW_ON_LOADED, function()
	local SCAN_COMMAND = "C_SCAN";
	local GhostCensusScanner = AddOn_TotalRP3.MapScanner("GhostCensusScan");

    local startTime;
    local endTime;

    GhostCensusScanner.scanIcon = Ellyb.Icon(TRP3_InterfaceIcons.PlayerScanIcon);
	GhostCensusScanner.scanOptionText = "GhostCensus Character Scan";
	GhostCensusScanner.scanTitle = "GhostCensus Scan";
	GhostCensusScanner.dataProviderTemplate = nil;
    GhostCensusScanner.charactersFound = 0;
    GhostCensusScanner.duration = 2;

	function GhostCensusScanner:Scan()
        startTime = debugprofilestop();
        GhostCensus.Print(moduleName, "Scanning...");
		broadcast.broadcast(SCAN_COMMAND, Map.getDisplayedMapID());
	end

    local resetScan = GhostCensusScanner.ResetScanData;

    function GhostCensusScanner:ResetScanData()
        self.charactersFound = 0;
        resetScan(self);
    end

    local onScanDataReceived = AddOn_TotalRP3.MapScanner.OnScanDataReceived;

    local function OnScanDataReceivedWrapper(self, sender, x, y, poiInfo)
        local pos = CreateVector2D(x, y);

        local dataSheet = generateDataSheet(sender, pos, poiInfo);
        local dataSheetName = "TRP3MapScanData"
        local source = GhostCensus.Database.Sources.TOTALRP3;

        GhostCensus.Database:AddPlayerEntry(sender, source, dataSheet, dataSheetName);
        GhostCensusScanner.charactersFound = GhostCensusScanner.charactersFound + 1;

        onScanDataReceived(self, sender, x, y, poiInfo);
    end

    AddOn_TotalRP3.MapScanner.OnScanDataReceived = OnScanDataReceivedWrapper

	function GhostCensusScanner:CanScan()
		local x, y = Map.getPlayerCoordinates();
		if not x or not y then
			return false;
		end

		return true;
	end

    function GhostCensusScanner:OnScanCompleted()
        endTime = debugprofilestop();
        GhostCensus.Print(moduleName, "Scan completed in " .. floor(endTime - startTime) .. "ms (Average: " .. calculateAverage(debugTimes) .. "ms)");
        GhostCensus.Print(moduleName, self.charactersFound .. " unique characters found!");
    end

    GhostCensus.Integrations.TRP3.MapScan.Scanner = GhostCensusScanner;
    TRP3_API.MapScannersManager.register(GhostCensusScanner);
end)