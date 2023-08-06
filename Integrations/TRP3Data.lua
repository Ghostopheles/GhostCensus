GhostCensus.Integrations.TRP3.DataGatherer = {};

function GhostCensus.Integrations.TRP3.DataGatherer:GenerateTRP3DataSheet(guid)
    if not IsAddOnLoaded("TotalRP3") or not guid then
        return;
    end

    local player = AddOn_TotalRP3.Player.CreateFromGUID(guid);

    if player:IsCurrentUser() then
        return;
    end

    local dataSheet = {};

    local success, accountType = pcall(player.GetAccountType, player);

    if success then
        dataSheet.IsTrial = player:IsOnATrialAccount() or nil;
        dataSheet.AccountType = accountType;
    end

    dataSheet.ProfileID = player:GetProfileID() or nil;
    dataSheet.CharacterID = player:GetCharacterID() or nil;
    dataSheet.RoleplayStatus = player:GetRoleplayStatus() or nil;
    dataSheet.FormattedName = player:GenerateFormattedName(TRP3_PlayerNameFormat.Colored) or nil;
    dataSheet.FirstName = player:GetFirstName() or nil;
    dataSheet.LastName = player:GetLastName() or nil;
    dataSheet.ShortTitle = player:GetTitle() or nil;
    dataSheet.FullTitle = player:GetFullTitle() or nil;
    dataSheet.RoleplayExperience = player:GetRoleplayExperience() or nil;
    dataSheet.Pronouns = player:GetCustomPronouns() or nil;
    dataSheet.Icon = player:GetCustomIcon() or nil;
    dataSheet.CustomGuild = player:GetCustomGuildMembership() or nil;
    dataSheet.VoiceReference = player:GetCustomVoiceReference() or nil;

    return dataSheet;
end