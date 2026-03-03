--[[
    ██╗     ██╗  ██╗██████╗        ██████╗ ██████╗ ██████╗ ███████╗
    ██║     ╚██╗██╔╝██╔══██╗      ██╔════╝██╔═══██╗██╔══██╗██╔════╝
    ██║      ╚███╔╝ ██████╔╝█████╗██║     ██║   ██║██████╔╝█████╗  
    ██║      ██╔██╗ ██╔══██╗╚════╝██║     ██║   ██║██╔══██╗██╔══╝  
    ███████╗██╔╝ ██╗██║  ██║      ╚██████╗╚██████╔╝██║  ██║███████╗
    ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝       ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝

    🐺 LXR Door Lock System — Locale: Spanish (es)

    ═══════════════════════════════════════════════════════════════════════════════
    Server:    The Land of Wolves 🐺 | Developer: iBoss21 / The Lux Empire
    Website:   https://www.wolves.land | Discord: https://discord.gg/CrKcWdfd3A
    Store:     https://theluxempire.tebex.io
    © 2026 iBoss21 / The Lux Empire | wolves.land | All Rights Reserved
    ═══════════════════════════════════════════════════════════════════════════════
]]

local Translations = {
    error = {
        nokey = "No tienes una llave!",
    },
    success = { 
        
    },
    info = {
        unlocked = "Abierto",
        unlocking = "Abriendo",
        locking = "Cerrando",
    }
}

Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})
