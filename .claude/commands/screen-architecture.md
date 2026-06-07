Scaffold a new feature screen using the coordinator pattern defined in `CLAUDE.md`.

1. Ask: **what feature/screen are you building?** (e.g. "Profile", "Settings", "Checkout")
2. Derive all type and file names from the feature name (e.g. "Profile" → `ProfileCoordinator`, `ProfileViewModel`, `ProfileView`, `ProfileAction`, `ProfileDestination`)
3. Create four files using the templates in `CLAUDE.md`, substituting `{Feature}` throughout:
   - `{Feature}/{Feature}Coordinator.swift` — includes `{Feature}Coordinating` protocol
   - `{Feature}/{Feature}ViewModel.swift` — includes `{Feature}ViewModeling` protocol
   - `{Feature}/{Feature}View.swift`
   - Add `Mock{Feature}ViewModel` and `Mock{Feature}Coordinator` to `movieTests/Mocks.swift`
4. Leave `// TODO:` comments where domain-specific logic is needed
5. Do not modify `Core.swift` or any existing coordinator
