--[[
    ██╗     ██╗  ██╗██████╗        ██████╗ ██████╗ ██████╗ ███████╗
    ██║     ╚██╗██╔╝██╔══██╗      ██╔════╝██╔═══██╗██╔══██╗██╔════╝
    ██║      ╚███╔╝ ██████╔╝█████╗██║     ██║   ██║██████╔╝█████╗  
    ██║      ██╔██╗ ██╔══██╗╚════╝██║     ██║   ██║██╔══██╗██╔══╝  
    ███████╗██╔╝ ██╗██║  ██║      ╚██████╗╚██████╔╝██║  ██║███████╗
    ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝       ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝

    🐺 LXR Core - Door Lock System

    Job-based door lock system for RedM servers. Configure which jobs can
    access which doors, set lock states, and customize interaction distances.
    Supports double-door groups and single doors with per-door coordinates.

    ═══════════════════════════════════════════════════════════════════════════════
    SERVER INFORMATION
    ═══════════════════════════════════════════════════════════════════════════════

    Server:      The Land of Wolves 🐺
    Developer:   iBoss21 / The Lux Empire
    Website:     https://www.wolves.land
    Discord:     https://discord.gg/CrKcWdfd3A
    Store:       https://theluxempire.tebex.io

    ═══════════════════════════════════════════════════════════════════════════════

    Version: 1.3.0

    Framework Support:
    - LXR Core (Primary)
    - RSG Core (Compatible)
    - VORP Core (Compatible)
    - RedEM:RP (Compatible)
    - QBR Core (Compatible)
    - QR Core (Compatible)
    - Standalone (Compatible)

    ═══════════════════════════════════════════════════════════════════════════════

    © 2026 iBoss21 / The Lux Empire | wolves.land | All Rights Reserved
]]

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🐺 RESOURCE NAME PROTECTION - RUNTIME CHECK
-- ═══════════════════════════════════════════════════════════════════════════════

local REQUIRED_RESOURCE_NAME = 'lxr-doorlock'
local currentResourceName = GetCurrentResourceName()

if currentResourceName ~= REQUIRED_RESOURCE_NAME then
    error(string.format([[

        ═══════════════════════════════════════════════════════════════════════════════
        ❌ CRITICAL ERROR: RESOURCE NAME MISMATCH ❌
        ═══════════════════════════════════════════════════════════════════════════════

        Expected: %s
        Got:      %s

        This resource is branded and must maintain the correct name.
        Rename the folder to "%s" to continue.

        🐺 wolves.land - The Land of Wolves

        ═══════════════════════════════════════════════════════════════════════════════

    ]], REQUIRED_RESOURCE_NAME, currentResourceName, REQUIRED_RESOURCE_NAME))
end

Config = {}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ SERVER BRANDING & INFO ████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

Config.ServerInfo = {
    name      = 'The Land of Wolves 🐺',
    developer = 'iBoss21 / The Lux Empire',
    website   = 'https://www.wolves.land',
    discord   = 'https://discord.gg/CrKcWdfd3A',
    store     = 'https://theluxempire.tebex.io',
    github    = 'https://github.com/iBoss21',
}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ FRAMEWORK CONFIGURATION ███████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

--[[
    Framework Priority (in order):
    1. LXR-Core  (Primary)
    2. RSG-Core  (Primary)
    3. VORP Core (Supported)
    4. RedEM:RP  (Optional — if detected)
    5. QBR-Core  (Optional — if detected)
    6. QR-Core   (Optional — if detected)
    7. Standalone (Fallback)
]]

Config.Framework = 'auto' -- 'auto' | 'lxr-core' | 'rsg-core' | 'vorp_core' | 'redem_roleplay' | 'qbr-core' | 'qr-core' | 'standalone'

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ GENERAL SETTINGS ██████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

Config.KeyPress = 0xCEFD9220  -- Key hash for door interaction (default: G)

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ DOOR LIST ████████████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████

--[[
    Door Entry Fields:
    ─────────────────────────────────────────────────────────────────────────────
    authorizedJobs  (table)    Job names that can interact with this door
    doorid          (number)   RDR3 door hash / entity identifier
    objCoords       (vector3)  World position of the door object
    textCoords      (vector3)  World position of the interaction text prompt
    objYaw          (number)   Locked heading/rotation of the door (degrees)
    locked          (boolean)  Default lock state on resource start
    distance        (number)   Interaction distance from textCoords (default 1.25)

    For double-door groups, omit doorid/objCoords/objYaw at the top level and
    instead supply a `doors` table containing individual door definitions.
    ─────────────────────────────────────────────────────────────────────────────
]]

Config.DoorList = {
    -- ──────────────────────────────────────────────────────────────────────────
    -- Valentine Sheriff Office
    -- ──────────────────────────────────────────────────────────────────────────
    {
        authorizedJobs = { 'police' }, doorid = 1988748538,
        objCoords = vector3(-276.04, 802.73, 118.41), textCoords = vector3(-275.02, 802.84, 119.43),
        objYaw = 10.0, locked = true, distance = 3.0
    },
    {
        authorizedJobs = { 'police' }, doorid = 395506985,
        objCoords = vector3(-275.85, 812.02, 118.41), textCoords = vector3(-277.06, 811.83, 119.38),
        objYaw = -170.0, locked = true, distance = 3.0
    },
    {
        authorizedJobs = { 'police' }, doorid = 1508776842,
        objCoords = vector3(-270.77, 810.02, 118.39), textCoords = vector3(-270.77, 810.02, 118.39),
        objYaw = -80.0, locked = true, distance = 1.5
    },
    {
        authorizedJobs = { 'police' }, doorid = 535323366,
        objCoords = vector3(-275.03, 809.27, 118.36), textCoords = vector3(-274.89, 808.03, 119.39),
        objYaw = -80.0, locked = true, distance = 2.0
    },
    {
        authorizedJobs = { 'police' }, doorid = 295355979,
        objCoords = vector3(-273.47, 809.96, 118.36), textCoords = vector3(-272.23, 810.1, 119.39),
        objYaw = 10.0, locked = true, distance = 1.5
    },
    {
        authorizedJobs = { 'police' }, doorid = 193903155,
        objCoords = vector3(-272.06, 808.25, 118.36), textCoords = vector3(-273.3, 808.12, 119.39),
        objYaw = -170.0, locked = true, distance = 1.5
    },

    -- ──────────────────────────────────────────────────────────────────────────
    -- Valentine Bank
    -- ──────────────────────────────────────────────────────────────────────────
    {
        textCoords = vector3(-308.11, 779.91, 118.96),
        authorizedJobs = { 'police' }, locked = false, distance = 2.5,
        doors = {
            { doorid = 3886827663, objCoords = vector3(-306.89, 780.11, 117.72), objYaw = -170.0 },
            { doorid = 2642457609, objCoords = vector3(-309.06, 779.73, 117.72), objYaw = 10.05 }
        }
    },
    {
        authorizedJobs = { 'police' }, doorid = 2343746133,
        objCoords = vector3(-301.94, 771.75, 117.72), textCoords = vector3(-303.02, 771.60, 118.47),
        objYaw = -170.0, locked = true, distance = 3.0
    },
    {
        authorizedJobs = { 'police' }, doorid = 1340831050,
        objCoords = vector3(-311.75, 774.67, 117.72), textCoords = vector3(-310.48, 774.92, 118.70),
        objYaw = 10.05, locked = true, distance = 3.0
    },
    {
        authorizedJobs = { 'police' }, doorid = 3718620420,
        objCoords = vector3(-311.06, 770.12, 117.7), textCoords = vector3(-309.97, 770.20, 118.70),
        objYaw = 10.36, locked = true, distance = 3.0
    },
    {
        authorizedJobs = { 'police' }, doorid = 334467483,
        objCoords = vector3(-302.93, 767.6, 117.69), textCoords = vector3(-302.97, 768.61, 118.70),
        objYaw = 100.0, locked = true, distance = 3.0
    },
    {
        authorizedJobs = { 'police' }, doorid = 576950805,
        objCoords = vector3(-307.76, 766.34, 117.7), textCoords = vector3(-306.60, 766.65, 118.70),
        objYaw = -170.0, locked = true, distance = 3.0
    },
    {
        authorizedJobs = { 'police' }, doorid = 2307914732,
        objCoords = vector3(-301.51, 762.98, 117.73), textCoords = vector3(-300.59, 763.20, 118.70),
        objYaw = 10.0, locked = true, distance = 3.0
    },

    -- ──────────────────────────────────────────────────────────────────────────
    -- Sisika Prison
    -- ──────────────────────────────────────────────────────────────────────────
    {
        authorizedJobs = { 'police' }, doorid = 1692000954,
        objCoords = vector3(3331.85, -700.07, 43.09), textCoords = vector3(3331.85, -700.07, 43.09),
        objYaw = -47.99, locked = true, distance = 3.0
    },
    {
        authorizedJobs = { 'police' }, doorid = -1819721708,
        objCoords = vector3(3333.60, -702.02, 43.09), textCoords = vector3(3333.60, -702.02, 43.09),
        objYaw = -47.99, locked = true, distance = 3.0
    },
    {
        authorizedJobs = { 'police' }, doorid = 559643844,
        objCoords = vector3(3350.70, -648.00, 44.40), textCoords = vector3(3350.70, -648.00, 44.40),
        objYaw = 14.99, locked = true, distance = 1.5
    },
    {
        authorizedJobs = { 'police' }, doorid = 559643844,
        objCoords = vector3(3349.96, -645.28, 44.41), textCoords = vector3(3349.96, -645.28, 44.41),
        objYaw = 14.99, locked = true, distance = 1.5
    },
    {
        authorizedJobs = { 'police' }, doorid = 4249790129,
        objCoords = vector3(3384.61, -639.47, 45.47), textCoords = vector3(3384.61, -639.47, 45.47),
        objYaw = -29.77, locked = true, distance = 1.5
    },
    {
        authorizedJobs = { 'police' }, doorid = 559643844,
        objCoords = vector3(3366.45, -680.12, 45.49), textCoords = vector3(3366.45, -680.12, 45.49),
        objYaw = -85.0, locked = true, distance = 1.5
    },
    {
        authorizedJobs = { 'police' }, doorid = 559643844,
        objCoords = vector3(3369.56, -723.59, 44.31), textCoords = vector3(3369.56, -723.59, 44.31),
        objYaw = -179.43, locked = true, distance = 1.5
    },
    {
        authorizedJobs = { 'police' }, doorid = 559643844,
        objCoords = vector3(3407.31, -677.72, 45.50), textCoords = vector3(3407.31, -677.72, 45.50),
        objYaw = -99.40, locked = true, distance = 1.5
    },
    {
        authorizedJobs = { 'police' }, doorid = -1694920053,
        objCoords = vector3(3318.45, -658.00, 44.85), textCoords = vector3(3318.45, -658.00, 44.85),
        objYaw = 60.0, locked = true, distance = 1.5
    },

    -- ──────────────────────────────────────────────────────────────────────────
    -- Rhodes Sheriff Office
    -- ──────────────────────────────────────────────────────────────────────────
    {
        authorizedJobs = { 'police' }, doorid = 349074475,
        objCoords = vector3(1359.71, -1305.97, 76.76), textCoords = vector3(1358.42, -1305.71, 77.72),
        objYaw = 160.0, locked = false, distance = 3.0
    },
    {
        authorizedJobs = { 'police' }, doorid = 1614494720,
        objCoords = vector3(1359.12, -1297.56, 76.78), textCoords = vector3(1358.51, -1298.95, 77.78),
        objYaw = -110.0, locked = true, distance = 3.0
    },

    -- ──────────────────────────────────────────────────────────────────────────
    -- Blackwater Sheriff Office
    -- ──────────────────────────────────────────────────────────────────────────
    {
        textCoords = vector3(-757.27, -1269.34, 44.04),
        authorizedJobs = { 'police' }, locked = false, distance = 2.5,
        doors = {
            { objYaw = 90.0, doorid = 3410720590, objCoords = vector3(-757.05, -1268.49, 43.06) },
            { objYaw = 90.0, doorid = 3821185084, objCoords = vector3(-757.05, -1269.93, 43.06) }
        }
    }
}
