# Changelog

## 3.0.0 — 2026-09-17

Rebuilt on the LXRCore v3 native API (repository renamed from lxr-doorlock). Nothing of the earlier multi-framework build remains; the door registry hashes and positions were kept as data.

* Server-owned lock states replicated through `GlobalState['door:<id>']`, persisted in `lxr_doors`
* Access by job + grade, job type (from the core registry), gang, or key items (`key_house`, `key_cell`, `key_ring`)
* Options on the lxr-interact card: unlock / lock / pick / knock; knock speaks through lxr-me
* Lockpick hook with server re-validation, relock timer and `lxr:doors:picked` for dispatch
* `AddDoor` at runtime, `DoorsForJob`, events `lxr:doors:changed` / `lxr:doors:knocked`
* Locales EN / KA, offline tests
