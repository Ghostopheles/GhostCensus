SLASH_GCS1, SLASH_GCS2 = "/gcs", "/ghostcensus"

local moduleName = "Slash";

GhostCensus.Slash = {};
GhostCensus.Slash.Commands = {};

function GhostCensus.Slash:RegisterCommand(cmd, func)
    self.Commands[cmd] = func;
end

function SlashCmdList.GCS(msg)
    local args = {strsplit(" ", msg)}
    local cmd = args[1]
    if not cmd then
        GhostCensus.Print(moduleName, "You gotta give me something, man.")
        return
    end
    table.remove(args, 1)

    local func = GhostCensus.Slash.Commands[cmd]
    if not func then
        GhostCensus.Print(moduleName, "Unknown command: " .. cmd)
        return
    end

    local success, result = pcall(func, unpack(args))
    assert(success, "Error while executing registered function...\n" .. (result or ""))
    GhostCensus.Print(moduleName, result)
end