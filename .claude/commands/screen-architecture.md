# Screen Architecture Skill

When this skill is invoked, scaffold a new feature screen using the coordinator pattern defined in `CLAUDE.md`.

## Steps

1. Ask the user: **what feature/screen are you building?** (e.g. "Profile", "Settings", "Checkout")
2. Use the feature name to derive all type and file names (e.g. "Profile" → `ProfileCoordinator`, `ProfileViewModel`, `ProfileView`, `ProfileAction`, `ProfileDestination`)
3. Generate the three files below, substituting `{Feature}` with the chosen name
4. Follow all rules in the **Rules** and **Common Mistakes to Avoid** sections of `CLAUDE.md`

## Files to Create

- `{Feature}/{Feature}Coordinator.swift` — Coordinator struct, Action enum, Destination enum
- `{Feature}/{Feature}ViewModel.swift` — `@Observable` class with service and dispatcher
- `{Feature}/{Feature}View.swift` — SwiftUI struct with `NavigationStack` and stream subscription

Use the templates in `CLAUDE.md` verbatim, replacing `{Feature}` throughout. Leave `// TODO:` comments where domain-specific logic is needed.

## After Generating

- Confirm the three files were created
- Remind the user to add any new `// TODO:` cases (actions, destinations, row rendering)
- Do not modify `Core.swift` or any existing coordinator
