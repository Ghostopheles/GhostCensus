function GhostCensus.GeneratePrintPrefix(moduleName, addNewLine)
    local prefix;

    if not moduleName then
        prefix = "|c" .. GhostCensus.Config.ThemeColor .. "GhostCensus|r: ";
    else
        prefix = "|c" .. GhostCensus.Config.ThemeColor .. "GhostCensus|r.|c" .. GhostCensus.Config.ThemeColor .. moduleName .. "|r: ";
    end

    if addNewLine then
        return prefix .. "\n";
    else
        return prefix;
    end
end

function GhostCensus.Print(module, ...)
    if not ... then
        return;
    end

    local message;
    local newTable = {};
    for _, v in ipairs({...}) do
        if v then
            local str = tostring(v);
            table.insert(newTable, str);
        end
    end
    message = strjoin(", ", unpack(newTable));

    local prefix = GhostCensus.GeneratePrintPrefix(module);
    print(prefix .. message);
end

function GhostCensus.Dump(module, message)
    message = message or "nil";

    local prefix = GhostCensus.GeneratePrintPrefix(module, true);
    print(prefix);
	DevTools_Dump(message);
end

function GhostCensus.UnitNameIsCurrentPlayer(name)
    return name == GhostCensus.Globals.PlayerName or name == GhostCensus.Globals.PlayerNameNoRealm;
end

function GhostCensus.UnitGUIDIsCurrentPlayer(guid)
    return guid == GhostCensus.Globals.PlayerGUID;
end

function GhostCensus.UnitNameIsCursed(name)
    return string.find(name, "xtensionxtooltip2");
end