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
-- LXRCore crosses the export as a copy: its PlayerData would stay what it was at load. The core broadcasts every
-- change (money, job, metadata) — keep ours current.
RegisterNetEvent('lxr:client:data', function(d) if type(d) == 'table' then LXRCore.PlayerData = d end end)
RegisterNetEvent('lxr:client:unloaded', function() LXRCore.PlayerData = {} end)
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
    local function work(lock)
        keyHand()
        local ok, res = LXR.RPC.Server('lxr-doors:toggle', door.id, lock)
        if not ok then toast('error.' .. tostring(res), 'error') end
    end
    I:AddPoint('lxr-doors:' .. door.id, door.coords, { label = door.label, distance = door.distance or Config.Doors.distance, options = {
        { label = Lang:t('ui.unlock'), key = 'J', canInteract = function() return locked(door.id) and D.MayWork(door, ctx(), me().items) end, onSelect = function() work(false) end },
        { label = Lang:t('ui.lock'), key = 'J', canInteract = function() return not locked(door.id) and D.MayWork(door, ctx(), me().items) end, onSelect = function() work(true) end },
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

-- the key in the hand before the bolt moves
local turning = false
function keyHand()
    local A = Config.KeyAnim
    if not A or not A.on or turning then return end
    turning = true
    local ped = PlayerPedId()
    RequestAnimDict(A.dict)
    local t = GetGameTimer() + 1500
    while not HasAnimDictLoaded(A.dict) and GetGameTimer() < t do Wait(10) end
    local prop
    if A.prop then
        local hash = joaat(A.prop)
        RequestModel(hash)
        local t2 = GetGameTimer() + 1500
        while not HasModelLoaded(hash) and GetGameTimer() < t2 do Wait(10) end
        if HasModelLoaded(hash) then
            local c = GetEntityCoords(ped)
            prop = CreateObject(hash, c.x, c.y, c.z, true, true, false)
            AttachEntityToEntity(prop, ped, GetEntityBoneIndexByName(ped, 'SKEL_R_Finger00'), 0.02, 0.012, -0.0085, 0.024, -160.0, 200.0, true, true, false, true, 1, true)
            SetModelAsNoLongerNeeded(hash)
        end
    end
    if HasAnimDictLoaded(A.dict) then TaskPlayAnim(ped, A.dict, A.clip, 8.0, -8.0, A.ms or 1800, 31, 0.0, false, false, false) end
    Wait(A.ms or 1800)
    if prop then DeleteEntity(prop) end
    if HasAnimDictLoaded(A.dict) then RemoveAnimDict(A.dict) end
    turning = false
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
