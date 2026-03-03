--[[
    ██╗     ██╗  ██╗██████╗        ██████╗ ██████╗ ██████╗ ███████╗
    ██║     ╚██╗██╔╝██╔══██╗      ██╔════╝██╔═══██╗██╔══██╗██╔════╝
    ██║      ╚███╔╝ ██████╔╝█████╗██║     ██║   ██║██████╔╝█████╗  
    ██║      ██╔██╗ ██╔══██╗╚════╝██║     ██║   ██║██╔══██╗██╔══╝  
    ███████╗██╔╝ ██╗██║  ██║      ╚██████╗╚██████╔╝██║  ██║███████╗
    ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝       ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝

    🐺 LXR Door Lock System — Server

    ═══════════════════════════════════════════════════════════════════════════════
    SERVER INFORMATION
    ═══════════════════════════════════════════════════════════════════════════════

    Server:      The Land of Wolves 🐺
    Developer:   iBoss21 / The Lux Empire
    Website:     https://www.wolves.land
    Discord:     https://discord.gg/CrKcWdfd3A
    Store:       https://theluxempire.tebex.io

    ═══════════════════════════════════════════════════════════════════════════════

    © 2026 iBoss21 / The Lux Empire | wolves.land | All Rights Reserved
]]

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🐺 FRAMEWORK BRIDGE — Runtime detection (LXR → RSG → VORP → Standalone)
-- ═══════════════════════════════════════════════════════════════════════════════

local Framework = nil
local FrameworkName = 'standalone'

local function InitFramework()
    local fw = (Config.Framework or 'auto'):lower()

    if fw == 'auto' or fw == 'lxr-core' then
        if GetResourceState('lxr-core') == 'started' then
            Framework = exports['lxr-core']
            FrameworkName = 'lxr-core'
            return
        end
    end
    if fw == 'auto' or fw == 'rsg-core' then
        if GetResourceState('rsg-core') == 'started' then
            Framework = exports['rsg-core']
            FrameworkName = 'rsg-core'
            return
        end
    end
    if fw == 'auto' or fw == 'vorp_core' then
        if GetResourceState('vorp_core') == 'started' then
            Framework = exports['vorp_core']
            FrameworkName = 'vorp_core'
            return
        end
    end

    -- Fallback — standalone (no framework)
    FrameworkName = 'standalone'
    print(string.format('[lxr-doorlock] ⚠️  No supported framework detected. Running in standalone mode.'))
end

local function GetPlayer(src)
    if FrameworkName == 'lxr-core' then
        return Framework:GetPlayer(src)
    elseif FrameworkName == 'rsg-core' then
        return Framework:GetPlayer(src)
    elseif FrameworkName == 'vorp_core' then
        local character = exports.vorp_core:getUserCharacter(src)
        if character then
            return { PlayerData = { job = { name = character.job or '' } } }
        end
    end
    return { PlayerData = { job = { name = '' } } }
end

local function SendNotification(src, message)
    TriggerClientEvent('lxr-doorlock:notify', src, message)
end

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        InitFramework()
        print(string.format('[lxr-doorlock] 🐺 Started — Framework: %s', FrameworkName))
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- LOCAL STATE
-- ═══════════════════════════════════════════════════════════════════════════════

local DoorInfo = {}

-- ═══════════════════════════════════════════════════════════════════════════════
-- HELPERS
-- ═══════════════════════════════════════════════════════════════════════════════

local function IsAuthorized(jobName, doorEntry)
    for _, job in pairs(doorEntry.authorizedJobs) do
        if job == jobName then
            return true
        end
    end
    return false
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- NET EVENTS
-- ═══════════════════════════════════════════════════════════════════════════════

RegisterNetEvent('lxr-doorlock:updatedoorsv', function(doorID, state)
    local src = source
    local Player = GetPlayer(src)
    if not IsAuthorized(Player.PlayerData.job.name, Config.DoorList[doorID]) then
        return SendNotification(src, Lang:t('error.nokey'))
    end
    TriggerClientEvent('lxr-doorlock:changedoor', src, doorID, state)
end)

RegisterNetEvent('lxr-doorlock:updateState', function(doorID, state)
    local src = source
    local Player = GetPlayer(src)
    if type(doorID) ~= 'number' then return end
    if not IsAuthorized(Player.PlayerData.job.name, Config.DoorList[doorID]) then
        return
    end
    DoorInfo[doorID] = {}
    TriggerClientEvent('lxr-doorlock:setState', -1, doorID, state)
end)
