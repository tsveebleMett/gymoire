# AGENTS.md

Gymoire is a Flutter gym and body weight tracker with a strongman bear mascot (Bench Mark); data is stored locally.

- Architecture, data model and known limits: [PROJECT_OVERVIEW.md](PROJECT_OVERVIEW.md)
- Setup and run: [README.md](README.md)
- Before handing over a change, run `flutter analyze` and `flutter test`.
- Keep `lib/domain/` free of Flutter imports.
- Import `package:material_ui/material_ui.dart`, not the deprecated `package:flutter/material.dart`.
- Never change the ids in `lib/domain/exercise_catalog.dart`; logged sets refer to them.
- Changes to the persisted JSON must stay readable for existing files or bump `version` with a migration.
