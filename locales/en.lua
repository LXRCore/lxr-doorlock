--[[ ═══════════════════════════════════════════════════════════════════════════
     LXR-DOORS — Locale: English (canonical)
     Developer   : iBoss21 | Brand : LXRCore | https://www.lxrcore.com
     © 2026 iBoss21 / LXRCore — All Rights Reserved
     ═══════════════════════════════════════════════════════════════════════════ ]]

Locale.Register('en', {
    ui = { unlock = 'Unlock', lock = 'Lock', pick = 'Pick the lock', knock = 'Knock', try = 'Try the door' },
    error = { rate = 'Slow down.', invalid = 'That door is not known.', too_far = 'Step up to the door.', no_key = 'You have no key to this door.', no_pick = 'You need a lockpick.', open = 'It is already open.' },
    info = { picked = 'The lock on %{label} gives.', locked_door = '%{label} is locked.' },
    me = { knock = 'knocks on %{label}' },
})
