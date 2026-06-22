# RenLib V7 API map

## Window

- `CreateTab`, `CreateTabCategory`, `CreateDashboard`
- `SelectTab`, `OnTabChanged`
- `SetSearch`, `ClearSearch`, `FocusSearchResult`
- `Dialog`, `Prompt`, `ShowKeybindManager`
- `SetProfile`, `SetSidebarMode`, `SetMaximized`
- `Minimize`, `Restore`, `Toggle`, `Close`

## Section controls

Core controls:

- `CreateButton`, `CreateToggle`, `CreateSlider`
- `CreateDropdown`, `CreateMultiDropdown`
- `CreateInput`, `CreateLabel`, `CreateParagraph`, `CreateDivider`
- `CreateMetric`, `CreateKeyPicker`, `CreateColorPicker`, `CreateImage`
- `CreateWarningBox`, `CreateDependencyBox`, `CreateTabbox`

Framework controls:

- `CreateGroup`
- `CreateList`
- `CreateTable`
- `CreatePlayerList`
- `CreateLogConsole`
- `CreateSkeleton`

## Shared controller methods

- `SetVisible(boolean)`
- `SetLocked(boolean)`, `Lock()`, `Unlock()`
- `SetLoading(boolean, message?)`
- `SetTooltip(text)`
- `AddNested(controller)`, `SetNestedVisible(boolean)`
- `Destroy()`

## Library services

- Themes and material: `ApplyThemePreset`, `SetTheme`, `SetMaterialMode`, `SetMaterialIntensity`
- Scale and motion: `SetDPIScale`, `PreviewDPIScale`, `SetReducedMotion`, `SetMotionScale`
- Configs: `SaveConfig`, `LoadConfig`, `RenameConfig`, `DeleteConfig`, `SetAutoloadConfig`
- Icons: `Icons`, `RegisterIcon`, `GetIcon`
- Addons: `RegisterAddon`, `GetAddon`, `EnableAddon`, `DisableAddon`, `UnregisterAddon`
- Keybinds: `KeybindManager:Show()`, `KeybindManager:Hide()`
- Lifecycle: `Unload`

See `Showcase.lua` for working examples of each family.
