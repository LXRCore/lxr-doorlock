--[[ ═══════════════════════════════════════════════════════════════════════════
     LXR-DOORS — Server: the lock states
     ═══════════════════════════════════════════════════════════════════════════
     One table of states, persisted when configured, replicated to every
     client through GlobalState['door:<id>']. Every toggle is checked here:
     distance, role or key, rate. Lockpicking is a hook: a minigame resource
     reports success and this file decides whether that door was pickable,
     whether the player really held a pick, and how long it stays open.
     ═══════════════════════════════════════════════════════════════════════════
     © 2026 iBoss21 / LXRCore — All Rights Reserved
     ═══════════════════════════════════════════════════════════════════════════ ]]

local LXRCore = exports['lxr-core']:GetCoreObject()
local LXR = exports['lxr-core']:GetLXR()
local D = LXRDoors
local RES = GetCurrentResourceName()
local state = {}      -- id → locked (boolean)
local timers = {}     -- id → relock deadline (GetGameTimer)
local buckets = {}

local function limited(src)
    local b = buckets[src]
    local now = GetGameTimer()
    if not b or now - b.at > Config.Security.rateLimit.windowMs then b = { at = now, n = 0 } buckets[src] = b end
    b.n = b.n + 1
    return b.n > Config.Security.rateLimit.burst
end
local function player(src) return LXRCore.Functions.GetPlayer(src) end
local function notify(src, key, kind, vars) LXRCore.Notify(src, Lang:t(key, vars), kind or 'info') end
local function near(src, door)
    local ped = GetPlayerPed(src)
    if ped == 0 then return false end
    return #(GetEntityCoords(ped) - door.coords) <= math.max(Config.Security.maxDistance, (door.distance or Config.Doors.distance) + 1.0)
end
local function ctxOf(P)
    local job = P.PlayerData.job or {}
    local def = LXRShared.Jobs and LXRShared.Jobs[job.name]
    return { job = { name = job.name, grade = job.grade, type = def and def.type }, gang = P.PlayerData.gang }
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- 💾 STATE
-- ═══════════════════════════════════════════════════════════════════════════════
if Config.Doors.persist then
    LXRCore.DB.RegisterMigration(RES, '0001_doors', [[
CREATE TABLE IF NOT EXISTS `lxr_doors` (
  `id` VARCHAR(64) NOT NULL,
  `locked` TINYINT(1) NOT NULL DEFAULT 1,
  `updated` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
]])
end

local function publish(id)
    GlobalState['door:' .. id] = state[id] == true
end

local function set(id, locked, src, reason)
    local door = D.Get(id)
    if not door then return false end
    locked = locked == true
    if state[id] == locked then return true end
    state[id] = locked
    publish(id)
    if Config.Doors.persist then
        LXRCore.DB.UpdateAsync('INSERT INTO lxr_doors (id, locked) VALUES (?, ?) ON DUPLICATE KEY UPDATE locked = VALUES(locked)', { id, locked and 1 or 0 })
    end
    local relock = D.AutoLock(door)
    if not locked and relock > 0 then timers[id] = GetGameTimer() + relock else timers[id] = nil end
    LXRCore.Emit('lxr:doors:changed', nil, id, locked, src, reason)
    if Config.Debug.log then LXRCore.Log.info('doors', (locked and 'locked ' or 'unlocked ') .. id, { source = src, reason = reason }) end
    return true
end

CreateThread(function()
    local saved = {}
    if Config.Doors.persist then
        local rows = LXRCore.DB.Query('SELECT id, locked FROM lxr_doors') or {}
        for _, r in ipairs(rows) do saved[r.id] = r.locked == 1 end
    end
    for _, d in ipairs(Config.List) do
        state[d.id] = saved[d.id]
        if state[d.id] == nil then state[d.id] = d.locked ~= false end
        publish(d.id)
    end
    if Config.Debug.printBanner then print(('^1[lxr-doors]^7 v%s — %d doors, persist %s'):format(GetResourceMetadata(RES, 'version', 0), #Config.List, tostring(Config.Doors.persist))) end
    -- relock timers
    while true do
        Wait(1000)
        local now = GetGameTimer()
        for id, at in pairs(timers) do
            if now >= at then timers[id] = nil set(id, true, nil, 'autolock') end
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🔑 TOGGLE
-- ═══════════════════════════════════════════════════════════════════════════════
LXR.RPC.Register('lxr-doors:toggle', function(src, id, wantLocked)
    if limited(src) then return false, 'rate' end
    local P, door = player(src), D.Get(id)
    if not P or not door then return false, 'invalid' end
    if not near(src, door) then
        LXRCore.Log.exploit('doors', 'toggle out of range', { source = src, door = id })
        return false, 'too_far'
    end
    local allowed = D.MayWork(door, ctxOf(P), P.PlayerData.items) or IsPlayerAceAllowed(src, Config.Security.adminAce)
    if not allowed then return false, 'no_key' end
    local locked = wantLocked
    if locked == nil then locked = not state[id] end
    set(id, locked, src, 'toggle')
    return true, state[id]
end)

-- a minigame reports a successful pick
RegisterNetEvent('lxr-doors:server:picked', function(id, broke)
    local src = source
    if limited(src) then return end
    local P, door = player(src), D.Get(id)
    if not P or not door or not Config.Pick.enabled or not door.pickable then return end
    if not near(src, door) then return LXRCore.Log.exploit('doors', 'pick out of range', { source = src, door = id }) end
    local pick = D.PickIn(P.PlayerData.items)
    if not pick then return LXRCore.Log.exploit('doors', 'pick without a lockpick', { source = src, door = id }) end
    if broke then P.Functions.RemoveItem(pick.name, 1, pick.slot, 'lockpick broke') end
    if not state[id] then return end
    set(id, false, src, 'picked')
    timers[id] = GetGameTimer() + (tonumber(Config.Pick.relockMs) or 0)
    if Config.Pick.alertLaw then LXRCore.Emit('lxr:doors:picked', nil, id, src, door.coords, door.town) end
    notify(src, 'info.picked', 'success', { label = door.label })
end)

-- may this player run the pick minigame here (asked before the client starts it)
LXR.RPC.Register('lxr-doors:canPick', function(src, id)
    if limited(src) then return false, 'rate' end
    local P, door = player(src), D.Get(id)
    if not P or not door or not Config.Pick.enabled or not door.pickable then return false, 'invalid' end
    if not state[id] then return false, 'open' end
    if not near(src, door) then return false, 'too_far' end
    if not D.PickIn(P.PlayerData.items) then return false, 'no_pick' end
    return true, door.label
end)

-- a knock is a /me everyone near the door sees
RegisterNetEvent('lxr-doors:server:knock', function(id)
    local src = source
    if limited(src) then return end
    local door = D.Get(id)
    if not door or not near(src, door) then return end
    if GetResourceState('lxr-me') == 'started' then exports['lxr-me']:Say(src, 'me', Lang:t('me.knock', { label = door.label })) end
    LXRCore.Emit('lxr:doors:knocked', nil, id, src)
end)

AddEventHandler('playerDropped', function() buckets[source] = nil end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- 📤 EXPORTS
-- ═══════════════════════════════════════════════════════════════════════════════
exports('IsLocked', function(id) return state[id] == true end)
exports('SetLocked', function(id, locked, reason) return set(id, locked, nil, reason or 'export') end)
exports('GetDoor', function(id) return D.Get(id) end)
exports('GetState', function() local out = {} for k, v in pairs(state) do out[k] = v end return out end)
exports('AddDoor', function(def)
    if type(def) ~= 'table' or not def.id or not def.hashes or not def.coords then return false end
    for i, d in ipairs(Config.List) do if d.id == def.id then table.remove(Config.List, i) end end
    Config.List[#Config.List + 1] = def
    D.Refresh()
    state[def.id] = def.locked ~= false
    publish(def.id)
    TriggerClientEvent('lxr-doors:client:added', -1, def)
    return true
end)
exports('DoorsForJob', function(jobName)
    local out = {}
    for _, d in ipairs(Config.List) do if D.RoleOpens(d, { job = { name = jobName, grade = 99, type = LXRShared.Jobs and LXRShared.Jobs[jobName] and LXRShared.Jobs[jobName].type } }) then out[#out + 1] = d.id end end
    return out
end)
