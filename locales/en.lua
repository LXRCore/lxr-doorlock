--[[
    ██╗     ██╗  ██╗██████╗        ██████╗ ██████╗ ██████╗ ███████╗
    ██║     ╚██╗██╔╝██╔══██╗      ██╔════╝██╔═══██╗██╔══██╗██╔════╝
    ██║      ╚███╔╝ ██████╔╝█████╗██║     ██║   ██║██████╔╝█████╗  
    ██║      ██╔██╗ ██╔══██╗╚════╝██║     ██║   ██║██╔══██╗██╔══╝  
    ███████╗██╔╝ ██╗██║  ██║      ╚██████╗╚██████╔╝██║  ██║███████╗
    ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝       ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝

    🐺 LXR Door Lock System — Locale: English (en)

    ═══════════════════════════════════════════════════════════════════════════════
    Server:    The Land of Wolves 🐺 | Developer: iBoss21 / The Lux Empire
    Website:   https://www.wolves.land | Discord: https://discord.gg/CrKcWdfd3A
    Store:     https://theluxempire.tebex.io
    © 2026 iBoss21 / The Lux Empire | wolves.land | All Rights Reserved
    ═══════════════════════════════════════════════════════════════════════════════
]]

local Translations = {
    error = {
        nokey = "You do not have a key!",
    },
    success = { 
        
    },
    info = {
        unlocked = "unlocked",
        unlocking = "Unlocking",
        locking = "Locking",
    }
}

Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})
