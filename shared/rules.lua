--[[ ═══════════════════════════════════════════════════════════════════════════
     LXR-DOORS — Shared rules: who may work a door, which key fits
     ═══════════════════════════════════════════════════════════════════════════
     Pure functions over Config.List and the core's job registry; the client
     mirrors them for the card, the server decides with them.
     ═══════════════════════════════════════════════════════════════════════════
     © 2026 iBoss21 / LXRCore — All Rights Reserved
     ═══════════════════════════════════════════════════════════════════════════ ]]

LXRDoors = LXRDoors or {}
local D = LXRDoors

local byId
function D.Get(id)
    if not byId then byId = {} for _, d in ipairs(Config.List) do byId[d.id] = d end end
    return byId[id]
end
function D.Refresh() byId = nil end

---@param job table|nil { name, grade }  (grade may be a number or { level })
local function gradeOf(job)
    if not job then return 0 end
    local g = job.grade
    if type(g) == 'table' then g = g.level end
    return tonumber(g) or 0
end

---Does a role (job or gang) open this door.
---@param door table
---@param ctx table { job = { name, grade, type }, gang = { name, grade } }
function D.RoleOpens(door, ctx)
    local who = door.who or {}
    if who.anyone then return true end
    local job = ctx and ctx.job
    if job and job.name then
        if who.jobs and who.jobs[job.name] ~= nil and gradeOf(job) >= (tonumber(who.jobs[job.name]) or 0) then return true end
        if who.jobTypes then
            local jtype = job.type or (LXRShared.Jobs and LXRShared.Jobs[job.name] and LXRShared.Jobs[job.name].type)
            for _, t in ipairs(who.jobTypes) do if t == jtype then return true end end
        end
    end
    local gang = ctx and ctx.gang
    if gang and gang.name and who.gangs and who.gangs[gang.name] ~= nil and gradeOf(gang) >= (tonumber(who.gangs[gang.name]) or 0) then return true end
    return false
end

---Does this key item (name + info) fit the door.
function D.KeyFits(name, info, door)
    local rule = Config.Keys[name]
    if not rule then return false end
    local ok, res = pcall(rule, info or {}, door)
    return ok and res == true
end

---Scan a satchel for a fitting key. `items` is the slot table.
function D.KeyIn(items, door)
    for _, it in pairs(items or {}) do
        if it and Config.Keys[it.name] and D.KeyFits(it.name, it.info, door) then return it end
    end
    return nil
end

---May the player work the door at all (role or key).
function D.MayWork(door, ctx, items)
    return D.RoleOpens(door, ctx) or D.KeyIn(items, door) ~= nil
end

---Is a lockpick in the satchel.
function D.PickIn(items)
    for _, it in pairs(items or {}) do
        if it then for _, name in ipairs(Config.Pick.items) do if it.name == name and (it.amount or 0) > 0 then return it end end end
    end
    return nil
end

---Game door state for a lock flag.
function D.GameState(locked)
    if not locked then return 0 end
    return Config.Doors.breakable and 2 or 1
end

---Relock delay for a door in ms (0 = never).
function D.AutoLock(door)
    if door.autoLock ~= nil then return tonumber(door.autoLock) or 0 end
    return tonumber(Config.Doors.autoLockMs) or 0
end
