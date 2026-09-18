--[[ ═══════════════════════════════════════════════════════════════════════════
     LXR-DOORS — Client: the game's doors follow the server's state
     ═══════════════════════════════════════════════════════════════════════════
     Registers every door with the game, mirrors GlobalState['door:<id>']
     into the door system, and offers the options through lxr-interact.
     No loops: state bag handlers and interact points do the work.
     ═══════════════════════════════════════════════════════════════════════════
     © 2026 iBoss21 / LXRCore — All Rights Reserved
     ═══════════════════════════════════════════════════════════════════════════ ]]

local LXRCore = exports['lxr-core']:GetCoreObject()
local LXR = exports['lxr-core']:GetLXR()
local D = LXRDoors
local N = Citizen.InvokeNative
local registered = {}   -- id → true once the game knows the hashes

local function me() return LXRCore.PlayerData or {} end
local function ctx()
    local job = me().job or {}
    local def = LXRShared.Jobs and LXRShared.Jobs[job.name]
    return { job = { name = job.name, grade = job.grade, type = def and def.type }, gang = me().gang }
end
local function locked(id) return GlobalState['door:' .. id] == true end
local function toast(key, kind, vars) LXRCore.Notify(Lang:t(key, vars), kind or 'info') end

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🚪 GAME DOORS
-- ═══════════════════════════════════════════════════════════════════════════════
local function apply(door)
    local st = D.GameState(locked(door.id))
    for _, hash in ipairs(door.hashes) do
        if not IsDoorRegisteredWithSystem(hash) then N(0xD99229FE93B46286, hash, 1, 1, 0, 0, 0, 0) end
        DoorSystemSetDoorState(hash, st)
    end
end

local function register(door)
    if registered[door.id] then return end
    registered[door.id] = true
    apply(door)
    AddStateBagChangeHandler('door:' .. door.id, 'global', function() apply(door) end)
    local I = exports['lxr-interact']
    I:AddPoint('lxr-doors:' .. door.id, door.coords, { label = door.label, distance = door.distance or Config.Doors.distance, options = {
        { label = Lang:t('ui.unlock'), key = 'J', canInteract = function() return locked(door.id) and D.MayWork(door, ctx(), me().items) end,
          onSelect = function() local ok, res = LXR.RPC.Server('lxr-doors:toggle', door.id, false) if not ok then toast('error.' .. tostring(res), 'error') end end },
        { label = Lang:t('ui.lock'), key = 'J', canInteract = function() return not locked(door.id) and D.MayWork(door, ctx(), me().items) end,
          onSelect = function() local ok, res = LXR.RPC.Server('lxr-doors:toggle', door.id, true) if not ok then toast('error.' .. tostring(res), 'error') end end },
        { label = Lang:t('ui.pick'), key = 'G',
          canInteract = function() return Config.Pick.enabled and door.pickable and locked(door.id) and D.PickIn(me().items) ~= nil and not D.MayWork(door, ctx(), me().items) and GetResourceState('lxr-lockpick') == 'started' end,
          onSelect = function()
              local ok, res = LXR.RPC.Server('lxr-doors:canPick', door.id)
              if not ok then return toast('error.' .. tostring(res), 'error') end
              TriggerEvent(Config.Pick.event, { door = door.id, label = door.label, report = 'lxr-doors:server:picked' })
          end },
        { label = Lang:t('ui.knock'), key = 'E', canInteract = function() return Config.Doors.knock and locked(door.id) and not D.MayWork(door, ctx(), me().items) end,
          onSelect = function() TriggerServerEvent('lxr-doors:server:knock', door.id) end },
        { label = Lang:t('ui.try'), key = 'E', canInteract = function() return locked(door.id) and not Config.Doors.knock and not D.MayWork(door, ctx(), me().items) end,
          onSelect = function() PlaySoundFrontend(Config.Doors.lockedSound, 'Doors_Sounds', true, 0) toast('info.locked_door', 'info', { label = door.label }) end },
    }})
end

local function boot()
    if GetResourceState('lxr-interact') ~= 'started' then
        print('^1[lxr-doors]^7 lxr-interact is not running — doors have no interaction')
    end
    for _, door in ipairs(Config.List) do register(door) end
end

RegisterNetEvent('lxr-doors:client:added', function(def)
    for i, d in ipairs(Config.List) do if d.id == def.id then table.remove(Config.List, i) end end
    Config.List[#Config.List + 1] = def
    D.Refresh()
    registered[def.id] = nil
    exports['lxr-interact']:Remove('lxr-doors:' .. def.id)
    register(def)
end)

RegisterNetEvent('lxr:client:loaded', boot)
AddEventHandler('onResourceStart', function(res)
    if res == GetCurrentResourceName() and LocalPlayer.state.isLoggedIn then boot() end
end)
AddEventHandler('onResourceStop', function(res)
    if res ~= GetCurrentResourceName() then return end
    for _, door in ipairs(Config.List) do for _, hash in ipairs(door.hashes) do if IsDoorRegisteredWithSystem(hash) then DoorSystemSetDoorState(hash, 0) end end end
end)

exports('IsLocked', locked)
exports('Nearest', function()
    local pos = GetEntityCoords(PlayerPedId())
    local best, bd
    for _, d in ipairs(Config.List) do local dist = #(pos - d.coords) if not bd or dist < bd then best, bd = d, dist end end
    return best, bd
end)
