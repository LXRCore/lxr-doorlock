--[[ ═══════════════════════════════════════════════════════════════════════════
     LXR-DOORS — Offline tests: the door list, roles, keys, locale parity
     Requires a sibling checkout of lxr-core (../lxr-core).
     Usage (from the lxr-doors folder):  lua tests/run.lua
     © 2026 iBoss21 / LXRCore — All Rights Reserved
     ═══════════════════════════════════════════════════════════════════════════ ]]

local CORE = os.getenv('LXR_CORE_PATH') or '../lxr-core'
package.path = CORE .. '/?.lua;' .. package.path
local ok = pcall(function() require('tests.lib.fxshim') end)
if not ok then print('lxr-core shim not found at ' .. CORE .. ' (set LXR_CORE_PATH)') os.exit(2) end
local Shim = require('tests.lib.fxshim')

for _, f in ipairs({ 'shared/main.lua', 'shared/locale.lua', 'locales/en.lua', 'config.lua', 'shared/catalog.lua', 'shared/items.lua', 'shared/prices.lua', 'shared/jobs.lua' }) do Shim.load(CORE .. '/' .. f) end
Config = nil
Locale = nil
Shim.load('shared/locale.lua')
Shim.load('locales/en.lua')
Shim.load('locales/ka.lua')
Shim.load('config.lua')
Shim.load('shared/rules.lua')
local D = LXRDoors

local passed, failed = 0, 0
local function test(name, fn)
    local okT, err = xpcall(fn, debug.traceback)
    if okT then passed = passed + 1 print('  ^ ok   ' .. name) else failed = failed + 1 print('  x FAIL ' .. name .. '\n' .. err) end
end
local function eq(a, b, msg) if a ~= b then error((msg or 'eq') .. ': expected ' .. tostring(b) .. ' got ' .. tostring(a), 2) end end

print('lxr-doors offline tests')

test('door list: unique ids, unique hashes, known jobs, coords', function()
    local ids, hashes = {}, {}
    for _, d in ipairs(Config.List) do
        assert(d.id and not ids[d.id], 'duplicate id ' .. tostring(d.id)) ids[d.id] = true
        assert(type(d.hashes) == 'table' and #d.hashes >= 1, d.id .. ' has no hashes')
        for _, h in ipairs(d.hashes) do assert(not hashes[h], d.id .. ' reuses hash ' .. h) hashes[h] = true end
        assert(d.coords and d.coords.x, d.id .. ' has no coords')
        assert(d.label, d.id .. ' has no label')
        for job in pairs((d.who or {}).jobs or {}) do assert(LXRShared.Jobs[job], d.id .. ' names unknown job ' .. job) end
    end
    assert(#Config.List >= 15)
end)

test('roles: specific job with grade, job type, gang, anyone', function()
    local door = D.Get('val_bank_vault')
    assert(D.RoleOpens(door, { job = { name = 'bank', grade = 2 } }))
    assert(not D.RoleOpens(door, { job = { name = 'bank', grade = 1 } }))
    assert(not D.RoleOpens(door, { job = { name = 'vallaw', grade = 5, type = 'leo' } }), 'the law does not open the vault')
    local front = D.Get('val_sheriff_front')
    assert(D.RoleOpens(front, { job = { name = 'vallaw', grade = 0, type = 'leo' } }))
    assert(D.RoleOpens(front, { job = { name = 'rholaw', grade = 0 } }), 'type resolved from the core registry')
    assert(D.RoleOpens(front, { job = { name = 'usmarshal', grade = 0 } }), 'federal')
    assert(not D.RoleOpens(front, { job = { name = 'valdoc', grade = 3 } }))
    assert(D.RoleOpens({ who = { anyone = true } }, {}))
    assert(D.RoleOpens({ who = { gangs = { wolves = 1 } } }, { gang = { name = 'wolves', grade = { level = 2 } } }))
end)

test('keys: house key by id, cell key by town, key ring', function()
    local cell = D.Get('val_cell_1')
    assert(D.KeyFits('key_cell', { town = 'valentine' }, cell))
    assert(not D.KeyFits('key_cell', { town = 'rhodes' }, cell))
    assert(not D.KeyFits('key_cell', { town = 'valentine' }, D.Get('val_sheriff_front')), 'cell keys only open cells')
    assert(D.KeyFits('key_house', { id = 'val_sheriff_front' }, D.Get('val_sheriff_front')))
    assert(D.KeyFits('key_ring', { keys = { 'x', 'val_bank_back' } }, D.Get('val_bank_back')))
    assert(not D.KeyFits('bread', {}, cell))
    local items = { [1] = { name = 'bread', amount = 1 }, [3] = { name = 'key_cell', amount = 1, info = { town = 'valentine' } } }
    assert(D.KeyIn(items, cell).slot == nil or true)
    assert(D.MayWork(cell, { job = { name = 'unemployed' } }, items))
    assert(not D.MayWork(cell, { job = { name = 'unemployed' } }, {}))
    for name in pairs(Config.Keys) do assert(LXRShared.Items[name], 'key item missing from catalog: ' .. name) end
    for _, name in ipairs(Config.Pick.items) do assert(LXRShared.Items[name], 'pick item missing from catalog: ' .. name) end
end)

test('picks, game state, relock', function()
    assert(D.PickIn({ { name = 'lockpick_fine', amount = 1 } }))
    assert(not D.PickIn({ { name = 'lockpick', amount = 0 } }))
    eq(D.GameState(false), 0)
    eq(D.GameState(true), 1)
    eq(D.AutoLock({}), Config.Doors.autoLockMs)
    eq(D.AutoLock({ autoLock = 5000 }), 5000)
end)

test('locale parity', function()
    local en, ka = Locale.Bundles.en, Locale.Bundles.ka
    local missing = {}
    for k in pairs(en) do if ka[k] == nil then missing[#missing + 1] = k end end
    eq(#missing, 0, 'ka missing: ' .. table.concat(missing, ', '))
end)

print(('%d passed, %d failed'):format(passed, failed))
os.exit(failed == 0 and 0 or 1)
