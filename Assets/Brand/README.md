# RenHub brand icon

`icon.txt` is the live brand-icon manifest fetched by RenLib at startup.

Replace the first line with a Roblox image/decal asset ID. Plain numeric IDs and full
`rbxassetid://...` values are supported. The optional second line, `tint=Accent`,
themes monochrome icons; remove that line for a full-color custom logo. RenLib keeps a built-in palette icon as a
safe fallback when GitHub or HTTP access is unavailable, so the logo never becomes
an invisible `</>` text mark again.

The GitHub path is intentionally stable:

`https://raw.githubusercontent.com/xsakyx/RobloxUILib/main/Assets/Brand/icon.txt`

After changing this file on `main`, new RenLib sessions pick up the new icon without
requiring a source-code edit.
