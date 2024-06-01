local LibSerialize = LibStub:GetLibrary("LibSerialize");

local f = CreateFrame("Frame", "GhostCensusExportFrame", UIParent);
f:SetPoint("CENTER");
f:SetSize(600, 500);

f.bg = f:CreateTexture(nil, "BACKGROUND");
f.bg:SetAllPoints();
f.bg:SetColorTexture(0, 0, 0, 0.5);

f.eb = CreateFrame("EditBox", nil, f);
f.eb:SetPoint("TOPLEFT", 10, -10);
f.eb:SetPoint("BOTTOMRIGHT", -10, 10);
f.eb:SetMultiLine(true);
f.eb:SetAutoFocus(false);
f.eb:SetFontObject("ChatFontNormal");
f.eb:SetScript("OnEscapePressed", f.eb.ClearFocus);

f:Hide();

local TAB = "\t";

function Stringify(tbl, tblName, isNested, level)
    level = level or 0;
    local tblString = "";
    local endTblString = "";

    if level > 0 then
        for i=0, level, 1 do
            tblString = tblString .. TAB;
        end
    end

    if isNested then
        tblString = format("[\"%s\"]", tblName);
    else
        tblString = tblName;
    end

    tblString = tblString .. " = {\n";

    for k, v in pairs(tbl) do
        local line = "";
        for i=0, level, 1 do
                line = line .. TAB;
        end
        if type(v) == "table" then
            line = line .. Stringify(v, k, true, level + 1);
        else
            local fmt;
            if type(v) == "string" then
                fmt = "[\"%s\"] = \"%s\"";
            else
                fmt = "[\"%s\"] = %s";
            end

            line = line .. format(fmt, k, tostring(v));
        end
        line = line .. ",\n"
        tblString = tblString .. line;
    end

    if level > 0 then
        for i=0, level - 1, 1 do
            endTblString = endTblString .. TAB;
        end
    end

    endTblString = endTblString .. "}";

    tblString = tblString .. endTblString;

    return tblString;
end

local function Show()
    f.eb:Show();
    local success, data = LibSerialize:Deserialize(GhostCensusDBSerialized);
    if not success then
        print("Deserialization failed: " .. data);
        return;
    end

    f.eb:SetText(Stringify(data, "GhostCensusDB"));
    f:Show();
end

GhostCensus.Export = {};
GhostCensus.Export.Frame = f;

local mt = {
    __call = function() Show(); end,
};

setmetatable(GhostCensus.Export, mt);