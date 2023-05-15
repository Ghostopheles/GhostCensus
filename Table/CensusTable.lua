GhostCensus.Table = {}

function GhostCensus.Table.throw(err)
    error("Ghost.Table: " .. err, 2)
end

function GhostCensus.Table.check(a, b)
    if getmetatable(a) ~= GhostCensus.__mt or getmetatable(b) ~= GhostCensus.__mt then
        return false
    else
        return true
    end
end

function GhostCensus.Table.IsGhostly(t)
    return getmetatable(t) == GhostCensus.__mt
end

function GhostCensus.Table.new(t, name)
    local newTable = {}
    if name then
        t.__name = name
    end

    setmetatable(newTable, GhostCensus.__mt)
    for _, l in ipairs(t) do newTable[l] = true end
    return newTable
end

function GhostCensus.Table.from(t, name)
    if name then
        t.__name = name
    end
    setmetatable(t, GhostCensus.__mt)
    return t
end

function GhostCensus.Table.union(a, b)
    if not GhostCensus.Table.check(a, b) then
        error("attempt to add a GhostTable with a non-Ghostly value", 2)
    end

    local res = GhostCensus.Table.new{}
    for k in pairs(a) do res[k] = true end
    for k in pairs(b) do res[k] = true end
    return res
end

function GhostCensus.Table.reset(t)
    return GhostCensus.Table.new(wipe(t))
end

function GhostCensus.Table.tostring(set)
    return set.__name or "GhostTable"
end

function GhostCensus.Table.print(s)
    GhostCensus.Print("Table", GhostCensus.Table.tostring(s))
end

function GhostCensus.Table.dump(s)
    GhostCensus.Dump("Table", s)
end

GhostCensus.__mt = {}
GhostCensus.__mt.__index = {}
GhostCensus.__mt.__index.Reset = GhostCensus.Table.reset
GhostCensus.__mt.__index.IsGhostly = GhostCensus.Table.IsGhostly
GhostCensus.__mt.__index.GetDebugName = GhostCensus.Table.tostring
GhostCensus.__mt.__add = GhostCensus.Table.union
GhostCensus.__mt.__tostring = GhostCensus.Table.tostring
GhostCensus.__mt.__call = GhostCensus.Table.print