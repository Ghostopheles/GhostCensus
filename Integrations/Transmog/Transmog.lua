local _SCENE = GhostCensusModelScene;

local INVSLOT_TO_NAME = {
    [INVSLOT_HEAD] = HEADSLOT,
    [INVSLOT_SHOULDER] = SHOULDERSLOT,
    [INVSLOT_BACK] = BACKSLOT,
    [INVSLOT_BODY] = SHIRTSLOT,
    [INVSLOT_CHEST] = CHESTSLOT,
    [INVSLOT_TABARD] = TABARDSLOT,
    [INVSLOT_WRIST] = WRISTSLOT,
    [INVSLOT_HAND] = HANDSLOT,
    [INVSLOT_WAIST] = WAISTSLOT,
    [INVSLOT_LEGS] = LEGSSLOT,
    [INVSLOT_FEET] = FEETSLOT,
    [INVSLOT_MAINHAND] = MAINHANDSLOT,
    [INVSLOT_OFFHAND] = SECONDARYHANDSLOT,
};


---@class GhostCensusTransmog
local Transmog = {};

function Transmog.PollOutfitForUnit(unitToken)
    _SCENE:RegisterUnit(unitToken);
end

function Transmog.GenerateAndLogTransmogData(guid, transmog)
    local datasheet = {};

    for invSlot, invSlotName in pairs(INVSLOT_TO_NAME) do
        local entry = transmog[invSlot];
        if entry then
            local slot = {
                Name = invSlotName,
                SlotID = invSlot,
                AppearanceID = entry.appearanceID,
                SecondaryAppearanceID = entry.secondaryAppearanceID,
                IllusionID = entry.illusionID,
            };
            tinsert(datasheet, slot);
        end
    end

    GhostCensus.Database:UpdateTransmogForPlayer(guid, datasheet);
end

------------

GhostCensus.Transmog = Transmog;