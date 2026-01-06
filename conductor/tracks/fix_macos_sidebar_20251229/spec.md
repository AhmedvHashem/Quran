# Specification: Fix macOS App Sidebar Not Opening

## 1. Background
The macOS application's sidebar is currently not opening or visible as expected. This prevents users from navigating between chapters (Surahs) effectively, which is a core feature of the application.

## 2. Objective
Restore the functionality of the sidebar in the macOS application so that it is visible by default or can be easily toggled by the user, allowing for navigation through the list of chapters.

## 3. Scope
- **In Scope:**
    - `QuranMac/Sources/QuranMac/Views/ContentView.swift`
    - `QuranMac/Sources/QuranMac/Views/SidebarView.swift`
    - Any relevant navigation state management in `ContentViewModel`.
- **Out of Scope:**
    - Windows application fixes.
    - Audio player functionality (unless directly blocking UI).

## 4. Root Cause Analysis (Hypotheses)
- **H1:** Incorrect use of `NavigationView` or `NavigationSplitView` for macOS.
- **H2:** State variable controlling visibility is not initialized or toggled correctly.
- **H3:** Layout constraints or frame sizes are hiding the view.

## 5. Proposed Solution
- Investigate the `ContentView` to ensure the sidebar is correctly placed within a `NavigationView` (or `NavigationSplitView` for newer macOS versions).
- Verify the `listStyle` is set to `SidebarListStyle`.
- Ensure the primary view is clearly defined.

## 6. Verification Plan
- **Manual Verification:**
    - Launch the macOS app.
    - Verify the sidebar is visible on launch.
    - Verify clicking a chapter in the sidebar updates the main detail view.
    - (If applicable) Verify the sidebar can be collapsed and expanded.
