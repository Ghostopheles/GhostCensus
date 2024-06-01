---@class GhostCensusRPDatasheet
---@field UsesExtended boolean
---@field UsesCustomPronouns boolean
---@field UsesCustomGuild boolean
---@field UsesCustomVoiceReference boolean
---@field Icon string
---@field IsTrial boolean
---@field Client string
---@field ClientVersion string
---@field ExtendedVersion number
---@field ExtendedVersionInternal number

GhostCensus.RP = {};

local GUID_CACHE = {};

local TIMEOUT_SECONDS = 500;

local Events = {
    RP_DATA_UPDATED = "RP_DATA_UPDATED",
};
GhostCensus.RP.Events = Events;

local function MakeCallbackEvents()
    local tbl = {};
    for _, event in pairs(Events) do
        tinsert(tbl, event);
    end

    return tbl;
end

local Registry = CreateFromMixins(CallbackRegistryMixin);
Registry:OnLoad();
Registry:GenerateCallbackEvents(MakeCallbackEvents());

GhostCensus.RP.EventRegistry = Registry;

function GhostCensus.RP:CreateTimeout(playerName)
    local callback = C_FunctionContainers.CreateCallback(function() GUID_CACHE[playerName] = nil; end);
    C_Timer.After(TIMEOUT_SECONDS, callback);
end

function GhostCensus.RP:OnRPDataReceived(playerName)
    if not playerName or not GUID_CACHE[playerName] then
        return;
    end

    if not TRP3_API.register.isUnitIDKnown(playerName) then return end;

    self.EventRegistry:TriggerEvent(Events.RP_DATA_UPDATED, playerName, GUID_CACHE[playerName]);
end

function GhostCensus.RP:RequestProfile(playerName, guid)
    if GUID_CACHE[playerName] then
        return;
    end

    GUID_CACHE[playerName] = guid;

    TRP3_API.r.sendQuery(playerName);
    TRP3_API.r.sendMSPQuery(playerName);
    self:CreateTimeout(playerName);
end

---@param playerName string
---@param guid? WOWGUID
---@return GhostCensusRPDatasheet?
function GhostCensus.RP:GenerateDatasheet(playerName, guid)
    if not C_AddOns.IsAddOnLoaded("TotalRP3") or not playerName then
        return;
    end

    local player = AddOn_TotalRP3.Player.CreateFromCharacterID(playerName);

    if player:IsCurrentUser() then
        return;
    end

    if not player:GetProfile() then
        if guid then
            self:RequestProfile(playerName, guid);
        end

        return;
    end

    local usesPronouns = player:GetCustomPronouns() ~= nil;

    local customGuild = player:GetCustomGuildMembership();
    local usesGuild = customGuild.name ~= nil and customGuild.rank ~= nil;

    local usesVoiceRef = player:GetCustomVoiceReference() ~= nil;
    local customIcon = player:GetCustomIcon();
    local isTrial = player:IsOnATrialAccount();

    local registerData = TRP3_API.register.getUnitIDCharacter(playerName);
    local client = registerData.client;
    local clientVersion = registerData.clientVersion;
    local extendedVersionInternal = registerData.extended or 0;
    local extendedVersion = registerData.extendedVersion;

    local usesExtended = extendedVersionInternal > 0;

    if usesExtended and client == "TRP3: Extended" then
        client = "Total RP 3";
    end

    return {
        UsesExtended = usesExtended,
        UsesCustomPronouns = usesPronouns,
        UsesCustomGuild = usesGuild,
        UsesCustomVoiceReference = usesVoiceRef,
        Icon = customIcon,
        IsTrial = isTrial,
        Client = client,
        ClientVersion = clientVersion,
        ExtendedVersion = extendedVersion,
        ExtendedVersionInternal = extendedVersionInternal
    };
end

TRP3_API.RegisterCallback(TRP3_Addon, TRP3_Addon.Events.REGISTER_DATA_UPDATED, function(_, ...)
    GhostCensus.RP:OnRPDataReceived(...);
end);

tinsert(msp.callback.received, function(playerName) GhostCensus.RP:OnRPDataReceived(playerName); end);