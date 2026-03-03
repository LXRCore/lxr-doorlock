# 🐺 LXR Door Lock System

```
██╗     ██╗  ██╗██████╗        ██████╗ ██████╗ ██████╗ ███████╗
██║     ╚██╗██╔╝██╔══██╗      ██╔════╝██╔═══██╗██╔══██╗██╔════╝
██║      ╚███╔╝ ██████╔╝█████╗██║     ██║   ██║██████╔╝█████╗  
██║      ██╔██╗ ██╔══██╗╚════╝██║     ██║   ██║██╔══██╗██╔══╝  
███████╗██╔╝ ██╗██║  ██║      ╚██████╗╚██████╔╝██║  ██║███████╗
╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝       ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝
```

**Job-based door lock system for RedM — The Land of Wolves**

[![wolves.land](https://img.shields.io/badge/Server-wolves.land-blue)](https://www.wolves.land)
[![Discord](https://img.shields.io/badge/Discord-Join-7289da)](https://discord.gg/CrKcWdfd3A)
[![Store](https://img.shields.io/badge/Store-Tebex-green)](https://theluxempire.tebex.io)

---

## ═══ SERVER INFORMATION ═══

| | |
|---|---|
| **Server** | The Land of Wolves 🐺 |
| **Developer** | iBoss21 / The Lux Empire |
| **Website** | https://www.wolves.land |
| **Discord** | https://discord.gg/CrKcWdfd3A |
| **Store** | https://theluxempire.tebex.io |
| **GitHub** | https://github.com/iBoss21 |

---

## ═══ DESCRIPTION ═══

`lxr-doorlock` is a multi-framework door lock system for RedM servers. It allows
server administrators to define job-restricted doors across the world with
configurable lock states, interaction distances, and support for single doors
as well as double-door groups. When an authorized player interacts with a locked
door, a key animation plays and the door state is synced to all clients.

---

## ═══ FRAMEWORK SUPPORT ═══

| Priority | Framework | Status |
|----------|-----------|--------|
| 1 | LXR Core (`lxr-core`) | ✅ Primary |
| 2 | RSG Core (`rsg-core`) | ✅ Primary |
| 3 | VORP Core (`vorp_core`) | ✅ Supported |
| 4 | RedEM:RP (`redem_roleplay`) | 🔶 Optional |
| 5 | QBR Core (`qbr-core`) | 🔶 Optional |
| 6 | QR Core (`qr-core`) | 🔶 Optional |
| 7 | Standalone | ✅ Fallback |

Framework detection is **automatic** by default. Set `Config.Framework` in
`config.lua` to a specific framework name to force a particular bridge.

---

## ═══ INSTALLATION ═══

1. Download or clone this resource into your server's `resources` folder.
2. Rename the folder to **`lxr-doorlock`** (the resource name is enforced at
   runtime and must match exactly).
3. Add `ensure lxr-doorlock` to your `server.cfg`.
4. Configure doors in `config.lua` — see the inline documentation for all
   available fields.
5. (Optional) Set `Config.Framework` to your framework name, or leave it as
   `'auto'` for automatic detection.

---

## ═══ CONFIGURATION ═══

All configuration lives in `config.lua`. Key settings:

```lua
Config.Framework = 'auto'       -- 'auto' | 'lxr-core' | 'rsg-core' | 'vorp_core' | ...
Config.KeyPress  = 0xCEFD9220   -- Interaction key hash (default: G)

Config.DoorList = {
    -- Single door example
    {
        authorizedJobs = { 'police' },
        doorid     = 1988748538,
        objCoords  = vector3(-276.04, 802.73, 118.41),
        textCoords = vector3(-275.02, 802.84, 119.43),
        objYaw     = 10.0,
        locked     = true,
        distance   = 3.0
    },

    -- Double-door group example
    {
        authorizedJobs = { 'police' },
        textCoords = vector3(-308.11, 779.91, 118.96),
        locked     = false,
        distance   = 2.5,
        doors = {
            { doorid = 3886827663, objCoords = vector3(-306.89, 780.11, 117.72), objYaw = -170.0 },
            { doorid = 2642457609, objCoords = vector3(-309.06, 779.73, 117.72), objYaw =   10.05 }
        }
    },
}
```

Pre-configured locations include:
- Valentine Sheriff Office
- Valentine Bank
- Sisika Prison
- Rhodes Sheriff Office
- Blackwater Sheriff Office

---

## ═══ LOCALES ═══

Locale files are in the `locales/` directory. English (`en.lua`) and
Spanish (`es.lua`) are included. To add a new language, copy `en.lua`,
translate the strings, and update `fxmanifest.lua` to include the new file.

---

## ═══ LICENSE ═══

© 2026 iBoss21 / The Lux Empire | [wolves.land](https://www.wolves.land) | All Rights Reserved

This resource is intended for use on The Land of Wolves RedM server and is
distributed through [The Lux Empire Tebex store](https://theluxempire.tebex.io).
Redistribution without permission is prohibited.
