local ACTOR_POOL_CAPACITY = 80;

local TRANSMOG_SLOTS = TransmogSlotOrder;

local SLOTS_REQUIRED_FOR_GREATNESS = 9;

-- 13 total slots that can be mogged
-- tabard, shirt and offhand can be empty
-- will probably call the outfit loaded after we get 9 pieces populated or something

GhostCensusModelSceneMixin = {};

local function OnActorReleased(actorPool, actor)
    ActorPool_HideAndClearModel(actorPool, actor);
end

---@diagnostic disable-next-line: duplicate-set-field
function GhostCensusModelSceneMixin:OnLoad()
    self.GUIDCache = {};

    self.ActorTemplate = "GhostCensusActorTemplate";
    self.ActorPool = CreateActorPool(self, self.ActorTemplate, OnActorReleased, ACTOR_POOL_CAPACITY);
end

function GhostCensusModelSceneMixin:OnModelOutfitLoaded(actor)
    local transmog = actor:GetItemTransmogInfoList();
    local guid = actor:GetModelUnitGUID();
    if not guid then
        guid = actor.guid;
    end

    GhostCensus.Transmog.GenerateAndLogTransmogData(guid, transmog);
    self:ReleaseActor(actor);
end

function GhostCensusModelSceneMixin:AcquireActor()
    local actor = self.ActorPool:Acquire();
    return actor;
end

function GhostCensusModelSceneMixin:ReleaseActor(actor)
    self.GUIDCache[actor.guid] = nil;
    actor.guid = nil;
    self.ActorPool:Release(actor);
end

function GhostCensusModelSceneMixin:RegisterUnit(unitToken)
    if not UnitExists(unitToken) or not UnitIsPlayer(unitToken) then
        return;
    end

    local guid = UnitGUID(unitToken);
    if self.GUIDCache[guid] or not guid then
        return;
    end

    local actor = self:AcquireActor();
    if not actor then
        return;
    end

    actor:SetModelByUnit(unitToken, true, true, false, true, false);
    actor.guid = guid;
    self.GUIDCache[guid] = actor;
end

------------

GhostCensusActorMixin = {};

function GhostCensusActorMixin:OnModelLoaded()
    self.OutfitLoaded = false;
    self:StartOutfitPoll();
end

function GhostCensusActorMixin:StartOutfitPoll()
    local callback = C_FunctionContainers.CreateCallback(function()
        if not self.OutfitLoaded and self:IsOutfitLoaded() then
            self.OutfitLoaded = true;
            self:GetParent():OnModelOutfitLoaded(self);
            self.OutfitPoll:Cancel();
            self.OutfitPoll = nil;
        end
    end);

    self.OutfitPoll = C_Timer.NewTicker(0, callback, 2000);
end

function GhostCensusActorMixin:IsOutfitLoaded()
    local transmogList = self:GetItemTransmogInfoList();

    local populatedSlots = 0;
    for _, invSlot in ipairs(TRANSMOG_SLOTS) do
        local slot = transmogList[invSlot];
        if slot and slot.appearanceID ~= 0 then
            populatedSlots = populatedSlots + 1;
        end
    end

    return populatedSlots >= SLOTS_REQUIRED_FOR_GREATNESS;
end