# KK Web Flutter Simplified DDD Architecture (Project-Owned)

## 1. Scope and Positioning

This document defines the project-owned architecture baseline for `kiki_web`.
It is inspired by external references but is not copied from other projects.

It is kiki_web-first and should evolve from this repository's own constraints and goals.

External reference policy:

1. External projects can be referenced for ideas only.
2. Do not make external project alignment the default decision rule.
3. Prefer small, compatible adjustments on top of current repo structure.

Goals:

1. Keep the main engineering path easy to reason about.
2. Keep business modules independent and replaceable.
3. Keep feature delivery template-driven and low-risk.

## 2. Primary Chain (Single Mental Model)

All business features should follow this chain:

UI(Page/Widget)
-> Controller(GetX)
-> Domain Service/UseCase
-> Repository (domain abstraction)
-> RepositoryImpl (data implementation)
-> RemoteDataSource/LocalDataSource
-> Network Client / Storage
-> Backend/Local source

Rules:

1. UI must not call network/storage directly.
2. Controller must not depend on concrete network classes.
3. Domain must depend on abstractions only.
4. Data must return domain-friendly models (not UI state models).

## 3. Current Layer Mapping for This Repo

Current `kiki_web/lib` layout:

1. `presentation/`: pages, controllers, widgets, user interactions.
2. `domain/`: entities, repository abstractions, business rules.
3. `data/`: DTOs, data sources, repository implementations.
4. `core/`: infrastructure (network, logging, exceptions, base utilities).
5. `services/`: cross-feature technical services that are not business modules.
6. `utils/`: helper utilities with no business coupling.

## 4. Dependency Constraints (Mandatory)

Allowed:

1. `presentation -> domain`
2. `presentation -> core/services/utils` (infrastructure usage only)
3. `data -> domain`
4. `data -> core/services/utils`

Forbidden:

1. `domain -> presentation`
2. `domain -> data`
3. Cross-feature direct dependency in presentation/data layer.
4. Feature A controller importing Feature B controller.

## 5. Independence Rules for Future Code Generation

For every newly generated feature/module:

1. Generate as an independent unit with its own domain/data/presentation slice.
2. Do not reuse another feature's controller/state class.
3. Reuse only `core`, `services`, `utils`, and shared UI primitives.
4. If shared business capability emerges, extract to a neutral shared domain contract.

## 6. Controller Responsibilities (GetX)

Controller should:

1. Hold reactive view state.
2. Trigger use-case/service actions.
3. Coordinate UI lifecycle and events.

Controller should not:

1. Build request DTO mappings with heavy logic.
2. Embed large business rules.
3. Contain direct Dio/http/sql details.

Page-layer widget convention:

1. Prefer `StatelessWidget` or `StatefulWidget` for pages.
2. Do not use `GetView<T>` as the default page base class in this project.
3. Resolve page controller explicitly (for example via route binding + `Get.find<T>()`) to keep page wiring visible and consistent.

## 7. Repository and DataSource Contracts

1. Repository abstraction lives in `domain/`.
2. Repository implementation lives in `data/`.
3. RemoteDataSource handles transport protocol and endpoint mapping.
4. Mapping strategy must be explicit: DTO <-> Domain Entity.

## 8. Error and Logging Baseline

1. Infrastructure exceptions are normalized in `core/`.
2. Domain returns deterministic failure shapes to controller layer.
3. Key user journeys must have success and failure logs.

## 9. Architecture Quality Gates

A feature change is considered architecture-compliant only when:

1. It keeps one-way dependency directions.
2. It does not introduce cross-feature coupling.
3. It passes static checks (`flutter analyze`).
4. It preserves independent module generation constraints.

## 10. Non-Negotiable Rules

1. External architecture docs are references, not templates to copy verbatim.
2. `kiki_web` architecture must be generated and maintained as project-owned specs.
3. Any deviation must be documented in `docs/architecture/` before merge.
4. For normal iteration, follow kiki_web-owned incremental changes instead of architecture rewrites.
