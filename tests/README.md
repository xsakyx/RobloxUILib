# Tests

Run the static release guard from the repository root:

```powershell
powershell -ExecutionPolicy Bypass -File tests/Validate-RenLib.ps1
```

It protects the V7 architecture invariants, verifies that all distribution variants are byte-identical, and confirms the public showcase covers each framework control family.

Static checks cannot reproduce Roblox input, rendering, or viewport behavior. Complete `docs/QA-CHECKLIST.md` in Roblox before tagging a public release.
