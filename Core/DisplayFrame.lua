GhostCensus.Display = CreateFrame("Frame", nil, UIParent, "ResizeLayoutFrame");

function GhostCensus.Display:OnLoad()
    self.DB = GhostCensus.Database.data;
    self:SetSize(100, 100);
    self:ClearAllPoints();

    if Ghost and Ghost.NetWatch then
        self:SetPoint("BOTTOMLEFT", Ghost.NetWatch, "TOPLEFT", 0, 5);
    else
        self:SetPoint("LEFT", UIParent, "LEFT", 20, 0);
    end

    self.TitleText = self:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    self.TitleText:ClearAllPoints();
    self.TitleText:SetPoint("TOPLEFT", self, "TOPLEFT", 3, 0);
    self.TitleText:SetJustifyH("CENTER");
    self.TitleText:SetJustifyV("TOP");
    self.TitleText:SetTextScale(1.5);

    self.Text = self:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    self.Text:ClearAllPoints();
    self.Text:SetPoint("TOPLEFT", self, "TOPLEFT", 3, -25);
    self.Text:SetJustifyH("CENTER");
    self.Text:SetJustifyV("TOP");
    self.Text:SetTextColor(1, 1, 1, 1);
    self.Text:SetTextScale(1.2);

    self.LastSeenText = self:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    self.LastSeenText:ClearAllPoints();
    self.LastSeenText:SetPoint("TOPLEFT", self.Text, "BOTTOMLEFT", 0, -3);
    self.LastSeenText:SetJustifyH("CENTER");
    self.LastSeenText:SetJustifyV("TOP");
    self.LastSeenText:SetTextColor(1, 1, 1, 1);
    self.LastSeenText:SetTextScale(1.2);

    self.bg = self:CreateTexture(nil, "BACKGROUND");
    self.bg:SetColorTexture(0, 0, 0, 0.6);
    self.bg:SetAllPoints(self);
    self.bg:Hide();

    self:SetMovable(true);
    self:EnableMouse(true);
    self:RegisterForDrag("LeftButton");
    self:SetScript("OnMouseDown", function()
        self:StartMoving();
        self.bg:Show();
    end);
    self:SetScript("OnMouseUp", function()
        self:StopMovingOrSizing();
        self.bg:Hide();
    end);

    UIParent:HookScript("OnUpdate", function()
        self:Update();
    end)

    self:Update();

    self.Text:Show();
    self:Show();
end

function GhostCensus.Display:Update()
    if not self.DB then
        return;
    end

    local displayTitle = "|cff3279a8GhostCensus|r"
    local uniqueCharacters = self.DB.Metrics.UniqueCharacters;

    local displayString = string.format("Unique Characters Seen: %s", BreakUpLargeNumbers(uniqueCharacters) or "N/A");
    local lastSeen = string.format("Last Unique Character Seen: %s", GhostCensus.Database.LastCharacterSeen or "N/A")

    self.TitleText:SetText(displayTitle);
    self.Text:SetText(displayString);
    self.LastSeenText:SetText(lastSeen);
    self:MarkDirty();
end

function GhostCensus.Display:ToggleShown()
    self:SetShown(not self:IsShown());
end

GhostCensus.Display:RegisterEvent("PLAYER_ENTERING_WORLD");
GhostCensus.Display:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        local isInitialLogin, isReloadingUi = ...;
        if isInitialLogin or isReloadingUi then
            self:OnLoad();
        end
    end
end)
