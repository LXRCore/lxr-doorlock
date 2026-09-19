--[[
    ██╗     ██╗  ██╗██████╗       ██████╗  ██████╗  ██████╗ ██████╗ ███████╗
    ██║     ╚██╗██╔╝██╔══██╗      ██╔══██╗██╔═══██╗██╔═══██╗██╔══██╗██╔════╝
    ██║      ╚███╔╝ ██████╔╝█████╗██║  ██║██║   ██║██║   ██║██████╔╝███████╗
    ██║      ██╔██╗ ██╔══██╗╚════╝██║  ██║██║   ██║██║   ██║██╔══██╗╚════██║
    ███████╗██╔╝ ██╗██║  ██║      ██████╔╝╚██████╔╝╚██████╔╝██║  ██║███████║
    ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝      ╚═════╝  ╚═════╝  ╚═════╝ ╚═╝  ╚═╝╚══════╝

    LXR Core - Doors

    Every lockable door in the world, who may work it, and what state it is
    in. The server owns the state (persisted, replicated through global
    state bags); the client only registers doors with the game and offers
    the options through lxr-interact. Keys are items, lockpicking is a hook.

    Brand:       LXRCore — Lux Empire eXperience RedM Core
    Product:     wolves.land / The Land of Wolves
    Developer:   iBoss21 / LXRCore
    Website:     https://www.lxrcore.com
    Discord:     https://discord.gg/GAhk8cgXe9
    GitHub:      https://github.com/LXRCore

    Version: 3.0.0
    Performance Target: 0.00 ms idle (no loops: state bag handlers + lxr-interact points)

    © 2026 iBoss21 / LXRCore | lxrcore.com | All Rights Reserved
]]

Config = Config or {}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ LANGUAGE ██████████████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████
Config.Lang = 'en'

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ BEHAVIOUR ═════════════════════════════════════════════
-- ████████████████████████████████████████████████████████████████████████████████
Config.Doors = {
    persist = true,             -- remember lock states across restarts (lxr_doors table)
    autoLockMs = 0,             -- 0 never; >0 doors relock this long after being unlocked (per door `autoLock` overrides)
    breakable = false,          -- locked doors can be shot / kicked open by the game (DOORSTATE_LOCKED_BREAKABLE)
    lockedSound = 'Door_Locked', -- feedback when a locked door is tried
    distance = 2.0,             -- default reach of the interaction point
    knock = true,               -- offer "Knock" on locked doors the player may not open
}

-- lockpicking: the hook lxr-lockpick (or any minigame) calls back into
Config.Pick = {
    enabled = true,
    items = { 'lockpick', 'lockpick_fine' },
    relockMs = 120000,          -- a picked door relocks itself after this
    alertLaw = true,            -- emit lxr:doors:picked for dispatch
    event = 'lxr-lockpick:client:start', -- client event that runs the minigame; it reports back with lxr-doors:server:picked
}

-- key items from the core catalog and how each one matches a door
Config.Keys = {
    key_house  = function(info, door) return info and info.id == door.id end,
    key_cell   = function(info, door) return info and door.town and info.town == door.town and door.cell end,
    key_ring   = function(info, door) if not info or type(info.keys) ~= 'table' then return false end for _, k in ipairs(info.keys) do if k == door.id then return true end end return false end,
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ THE DOORS ═════════════════════════════════════════════
-- ████████████████████████████████████████████████████████████████████████████████
-- id        unique; used by keys (info.id), exports and events
-- hashes    the game's door registry hashes (one for a single door, two for a pair)
-- coords    the interaction point (roughly the middle of the frame)
-- locked    state on first start (persisted afterwards when Config.Doors.persist)
-- who       { jobs = { vallaw = 0 }, jobTypes = { 'leo' }, gangs = { ... }, anyone = false }
-- town      for cell keys; cell = true marks a cell door
-- pickable  lockpicks work here; autoLock overrides the global relock time
local LAW = { jobTypes = { 'leo', 'federal' } }

Config.List = {
    -- ═══ Valentine Sheriff's Office ═══
    { id = 'val_sheriff_front', label = "Sheriff's Office", town = 'valentine', hashes = { 1988748538 }, coords = vector3(-275.02, 802.84, 119.43), locked = true, who = LAW, pickable = true, distance = 3.0 },
    { id = 'val_sheriff_back',  label = "Sheriff's Office (back)", town = 'valentine', hashes = { 395506985 }, coords = vector3(-277.06, 811.83, 119.38), locked = true, who = LAW, pickable = true, distance = 3.0 },
    { id = 'val_cell_1', label = 'Cell 1', town = 'valentine', cell = true, hashes = { 1508776842 }, coords = vector3(-270.77, 810.02, 118.39), locked = true, who = LAW, distance = 1.5 },
    { id = 'val_cell_2', label = 'Cell 2', town = 'valentine', cell = true, hashes = { 535323366 },  coords = vector3(-274.89, 808.03, 119.39), locked = true, who = LAW, distance = 2.0 },
    { id = 'val_cell_3', label = 'Cell 3', town = 'valentine', cell = true, hashes = { 295355979 },  coords = vector3(-272.23, 810.10, 119.39), locked = true, who = LAW, distance = 1.5 },
    { id = 'val_cell_4', label = 'Cell 4', town = 'valentine', cell = true, hashes = { 193903155 },  coords = vector3(-273.30, 808.12, 119.39), locked = true, who = LAW, distance = 1.5 },

    -- ═══ Valentine Bank ═══
    { id = 'val_bank_front', label = 'Bank', town = 'valentine', hashes = { 3886827663, 2642457609 }, coords = vector3(-308.11, 779.91, 118.96), locked = false, who = { jobs = { bank = 0 }, jobTypes = { 'leo' } }, distance = 2.5 },
    { id = 'val_bank_office', label = "Manager's Office", town = 'valentine', hashes = { 2343746133 }, coords = vector3(-303.02, 771.60, 118.47), locked = true, who = { jobs = { bank = 1 }, jobTypes = { 'leo' } }, pickable = true, distance = 3.0 },
    { id = 'val_bank_counter', label = 'Counter Gate', town = 'valentine', hashes = { 1340831050 }, coords = vector3(-310.48, 774.92, 118.70), locked = true, who = { jobs = { bank = 0 }, jobTypes = { 'leo' } }, distance = 3.0 },
    { id = 'val_bank_vault_hall', label = 'Vault Hall', town = 'valentine', hashes = { 3718620420 }, coords = vector3(-309.97, 770.20, 118.70), locked = true, who = { jobs = { bank = 1 }, jobTypes = { 'leo' } }, pickable = true, distance = 3.0 },
    { id = 'val_bank_side', label = 'Side Door', town = 'valentine', hashes = { 334467483 }, coords = vector3(-302.97, 768.61, 118.70), locked = true, who = { jobs = { bank = 0 }, jobTypes = { 'leo' } }, pickable = true, distance = 3.0 },
    { id = 'val_bank_vault', label = 'Vault', town = 'valentine', hashes = { 576950805 }, coords = vector3(-306.60, 766.65, 118.70), locked = true, who = { jobs = { bank = 2 } }, distance = 3.0 },
    { id = 'val_bank_back', label = 'Back Door', town = 'valentine', hashes = { 2307914732 }, coords = vector3(-300.59, 763.20, 118.70), locked = true, who = { jobs = { bank = 0 }, jobTypes = { 'leo' } }, pickable = true, distance = 3.0 },

    -- ═══ Rhodes Sheriff's Office ═══
    { id = 'rho_sheriff_front', label = "Sheriff's Office", town = 'rhodes', hashes = { 349074475 },  coords = vector3(1358.42, -1305.71, 77.72), locked = false, who = LAW, pickable = true, distance = 3.0 },
    { id = 'rho_sheriff_cells', label = 'Cells', town = 'rhodes', cell = true, hashes = { 1614494720 }, coords = vector3(1358.51, -1298.95, 77.78), locked = true, who = LAW, distance = 3.0 },

    -- ═══ Blackwater Marshal's Office ═══
    { id = 'blk_marshal_front', label = "Marshal's Office", town = 'blackwater', hashes = { 3410720590, 3821185084 }, coords = vector3(-757.27, -1269.34, 44.04), locked = false, who = LAW, pickable = true, distance = 2.5 },

    -- ═══ Sisika Penitentiary (gate + yard doors carrying unique registry hashes) ═══
    { id = 'sisika_gate', label = 'Prison Gate', town = 'sisika', hashes = { 1692000954 }, coords = vector3(3331.85, -700.07, 43.09), locked = true, who = { jobs = { prison = 0 }, jobTypes = { 'leo', 'federal' } }, distance = 3.0 },
    { id = 'sisika_block', label = 'Cell Block', town = 'sisika', cell = true, hashes = { 4249790129 }, coords = vector3(3384.61, -639.47, 45.47), locked = true, who = { jobs = { prison = 0 }, jobTypes = { 'leo', 'federal' } }, distance = 1.5 },
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ SECURITY ══════════════════════════════════════════════
-- ████████████████████████████████████████████████████████████████████████████████
Config.Security = {
    rateLimit = { windowMs = 2000, burst = 8 },
    maxDistance = 4.0,          -- the server refuses toggles further than this from the door
    adminAce = 'lxrcore.admin', -- may lock / unlock anything
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ DEBUG ═════════════════════════════════════════════════
-- ████████████████████████████████████████████████████████████████████████████████
Config.Debug = { printBanner = true, log = false }
