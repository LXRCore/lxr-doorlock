<img src="https://raw.githubusercontent.com/LXRCore/.github/main/profile/lxrcore-logo.png" alt="LXRCore" width="72" align="left" style="margin-right:12px">

# lxr-doors — Locks, keys and who holds them, for LXRCore

Every lockable door in the world and its state. The server owns the lock,
persists it, and replicates it through one global state bag per door; the
client registers the door with the game and offers the options through
lxr-interact. Access is a role (a job with a grade, a job type such as the
law, a gang) or a key item from the core catalog. Lockpicking is a hook for
a minigame resource; a picked door relocks itself and tells the law.

![The door card](docs/img/door.png)

## What it does

* **State on the server** — `GlobalState['door:<id>']` is the truth; clients
  mirror it into the game's door system on every change. Persisted in
  `lxr_doors` when `Config.Doors.persist` is on.
* **Access** — `who = { jobs = { bank = 2 }, jobTypes = { 'leo', 'federal' },
  gangs = { … }, anyone = false }`. Job types come from the core's job registry,
  so every sheriff's office opens for every law job without listing them.
* **Keys** — `key_house` (info.id), `key_cell` (info.town, cell doors only),
  `key_ring` (info.keys) — the rules are in `Config.Keys`, one function per item.
* **Card** — Unlock / Lock for those who may, Pick the lock for those with a
  lockpick while lxr-lockpick runs, Knock (a /me through lxr-me) for everyone else.
* **Picking** — the minigame reports `lxr-doors:server:picked (id, broke)`;
  the server re-checks the door, the pick and the distance, opens for
  `Config.Pick.relockMs` and emits `lxr:doors:picked` for dispatch.
* **Relock** — `Config.Doors.autoLockMs` or per-door `autoLock`.
* **Runtime doors** — `AddDoor(def)` from any resource (a robbery, a property).
* **Cost** — no loops on the client; one 1 s relock tick on the server.

## Install

```cfg
ensure lxr-core
ensure lxr-interact
ensure lxr-doors
```

`lxr_doors` is created by the core's migration runner on first start.

## Configuration

`config.lua` — `Config.Lang`, `Config.Doors` (persist, relock, breakable,
knock), `Config.Pick` (items, relock, alert, minigame event), `Config.Keys`,
`Config.List` (the doors), `Config.Security`.

## API

| Name | Side | Purpose |
|---|---|---|
| `IsLocked(id)` · `SetLocked(id, locked, reason)` · `GetState()` | server | read or force a lock |
| `GetDoor(id)` · `AddDoor(def)` · `DoorsForJob(job)` | server | the registry |
| `lxr:doors:changed` (id, locked, src, reason) · `lxr:doors:picked` (id, src, coords, town) · `lxr:doors:knocked` (id, src) | server | events |
| `lxr-doors:server:picked` (id, broke) | server | the minigame's report |
| `IsLocked(id)` · `Nearest()` | client | local mirror |

## Licence

© 2026 iBoss21 / LXRCore — All Rights Reserved. See `LICENSE`.
