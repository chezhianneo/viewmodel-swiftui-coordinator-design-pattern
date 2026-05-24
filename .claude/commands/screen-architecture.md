Scaffold a new feature screen using the coordinator pattern defined in `CLAUDE.md`.

1. Ask: **what feature/screen are you building?** (e.g. "Profile", "Settings", "Checkout")
2. Derive all type and file names from the feature name (e.g. "Profile" → `ProfileCoordinator`, `ProfileViewModel`, `ProfileView`, `ProfileAction`, `ProfileDestination`)
3. Create three files using the templates in `CLAUDE.md`, substituting `{Feature}` throughout:
   - `{Feature}/{Feature}Coordinator.swift`
   - `{Feature}/{Feature}ViewModel.swift`
   - `{Feature}/{Feature}View.swift`
4. Leave `// TODO:` comments where domain-specific logic is needed
5. Do not modify `Core.swift` or any existing coordinator
