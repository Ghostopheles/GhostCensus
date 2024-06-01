---@class GhostCensusTRP3Datasheet
---@field UsesCustomPronouns boolean
---@field UsesCustomGuild boolean
---@field UsesCustomVoiceReference boolean
---@field Icon string
---@field IsTrial boolean

GhostCensus.TRP3 = {};

---@return GhostCensusTRP3Datasheet?
function GhostCensus.TRP3:GenerateDataSheet(guid)
    if not C_AddOns.IsAddOnLoaded("TotalRP3") or not guid then
        return;
    end

    local player = AddOn_TotalRP3.Player.CreateFromGUID(guid);

    if player:IsCurrentUser() or not player:GetProfile() then
        return;
    end

    local usesPronouns = player:GetCustomPronouns() ~= nil;

    local customGuild = player:GetCustomGuildMembership();
    local usesGuild = customGuild.name ~= nil and customGuild.rank ~= nil;

    local usesVoiceRef = player:GetCustomVoiceReference() ~= nil;
    local customIcon = player:GetCustomIcon();
    local isTrial = player:IsOnATrialAccount();

    return {
        UsesCustomPronouns = usesPronouns,
        UsesCustomGuild = usesGuild,
        UsesCustomVoiceReference = usesVoiceRef,
        Icon = customIcon,
        IsTrial = isTrial,
    };
end