# RenLib regression checklist

Run this checklist before publishing a RenLib release.

## Navigation and search

- Click every user tab, Overview, and Settings in both directions.
- Search for a control on the active tab and on another tab.
- Press Enter repeatedly and confirm results cycle without exposing multiple pages.
- Clear search with Backspace and with `Window:ClearSearch()`.
- Confirm tab, section, and control visibility is unchanged after clearing.

## Responsive layout

- Test desktop, narrow window, tablet, and phone widths.
- Rotate or resize while each tab is active.
- Toggle Dynamic, Expanded, and Compact sidebar modes.
- Minimize and restore at each width.
- Preview 100%, 125%, and 150% UI scale and let one preview time out.

## Components

- Expand and collapse groups containing normal and data controls.
- Open dropdowns and color pickers near the bottom of a scrolling page.
- Toggle loading on buttons and controls, then unload while loading.
- Test tooltips with hover and touch-and-hold.
- Add, select, remove, and clear list/table rows.
- Join/leave with a player list open.
- Fill and clear a log console beyond its maximum line count.

## Persistence and lifecycle

- Save, load, rename, delete, and autoload a config.
- Reload RenLib and confirm the previous session is removed.
- Start, stop, and unregister an addon.
- Rebind and reset shortcuts in the keybind manager.
- Unload with dialogs, prompts, notifications, and dropdowns open.
