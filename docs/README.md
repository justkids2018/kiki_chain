# Shared Documentation

This directory collects information both the Rust backend (`kiki_server`) and the Flutter frontend (`kiki_web`) rely on.

- `api/`: API contracts such as OpenAPI specs, protocol buffers, and related change logs.
- `sql/`: Database schema exports, migration summaries, and data-access notes.
- `framework/`: Shared framework decisions, cross-cutting technical guidelines, reusable components.
- `business/`: Business workflows, domain rules, user journeys, and cross-system processes.
- `prompt/`: Prompt collections, automation recipes, and guidance for AI-assisted workflows.

Service-specific details should continue to live under each project's own `doc/` folder, with links back here where needed.
