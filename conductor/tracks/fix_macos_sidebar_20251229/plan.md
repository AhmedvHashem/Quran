# Plan: Fix macOS App Sidebar Not Opening

## Phase 1: Diagnosis & Reproduction
- [ ] Task: Analyze `ContentView.swift` and `SidebarView.swift` structure
    - [ ] Subtask: Read `QuranMac/Sources/QuranMac/Views/ContentView.swift`
    - [ ] Subtask: Read `QuranMac/Sources/QuranMac/Views/SidebarView.swift`
    - [ ] Subtask: Identify the navigation structure (NavigationView vs NavigationSplitView)
- [ ] Task: Conductor - User Manual Verification 'Diagnosis & Reproduction' (Protocol in workflow.md)

## Phase 2: Implementation (Fix)
- [ ] Task: Correct the Navigation Structure
    - [ ] Subtask: Write Tests (Create a UI test or unit test if possible to verify navigation hierarchy - *Note: SwiftUI testing can be limited, focus on view inspection if applicable*)
    - [ ] Subtask: Implement Feature (Refactor `ContentView` to use `NavigationView` with `doubleColumn` style or `NavigationSplitView` correctly)
- [ ] Task: Conductor - User Manual Verification 'Implementation (Fix)' (Protocol in workflow.md)

## Phase 3: Verification
- [ ] Task: Verify Sidebar Functionality
    - [ ] Subtask: Write Tests (Ensure selection state updates correctly)
    - [ ] Subtask: Implement Feature (Run manual verification steps)
- [ ] Task: Conductor - User Manual Verification 'Verification' (Protocol in workflow.md)
