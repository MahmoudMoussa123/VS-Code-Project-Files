# Development Plan (AI-Powered Meal Planner & Product Analysis App)

Target Platforms: Android (primary), iOS (later)
Architecture: Feature-first modules, MVVM (Riverpod), Clean layering (UI → ViewModel → Repository → Services → Data)
Data: Remote APIs + Hive local cache
AI: Cloud APIs for explanations, substitutions
Scanning: Barcode plugin (mobile_scanner)
Models: freezed + json_serializable

## 0. Assumptions
- Team: 1 Mobile Lead, 1 Backend, 1 AI Engineer, 1 Designer, 1 QA
- Sprint length: 2 weeks
- Phase 1 target: 14 weeks (7 sprints)
- Phases can overlap with hardening

## 1. High-Level Milestones
1. Foundation & Tooling (Sprint 1)
2. Core Domain Models & Auth (Sprint 2)
3. Product Scanning + Health Scoring MVP (Sprint 3)
4. Meal Discovery & Recipe/Meal Score Integration (Sprint 4)
5. Meal Planning, Shopping List, Alternatives Engine (Sprint 5)
6. Nutrition Tracking & Transparency / Methodology (Sprint 6)
7. Crowdsourcing, Admin Hooks, Hardening & Release Prep (Sprint 7)
8. Phase 2 Extensions (Post-MVP): Retail Integrations, Advanced AI, Premium Tier
9. Phase 3 Extensions: Crowdsourcing Scaling, Globalization, Advanced Personalization

## 2. Sprint Breakdown (Phase 1 MVP)

### Sprint 1: Foundation & Infrastructure
Deliverables:
- Flutter project initialized (flavors: dev, staging, prod)
- Core folders + codegen pipeline + analysis_options
- Riverpod global providers, environment loader
- CI (analyze, test, build, coverage)
- Hive initialization & secure key storage
Tasks:
1. Project bootstrap (flavors, app_bootstrap.dart)
2. Add packages: riverpod, hooks_riverpod, dio, freezed, json_serializable, hive, hive_flutter, mobile_scanner
3. Configure build_runner scripts & watch
4. Set up analysis_options.yaml + lint gating
5. Implement Environment provider (API_BASE_URL via --dart-define)
6. Add logging & exception base classes (AppException)
7. Initialize Hive boxes (preferences, products, scans)
8. CI GitHub Actions workflows
Acceptance Criteria:
- `flutter analyze` clean
- CI green on PR
- Build flavors run with distinct base URLs

### Sprint 2: Auth & Core Models
Deliverables:
- Auth flow (email/password stub service or mock)
- Domain models: Product, Nutrition, Score, Meal (Freezed)
- DTO & mapping patterns established
- Secure token storage
Tasks:
1. AuthApi (mock endpoints) + AuthRepository
2. AuthViewModel + login screen (basic UI)
3. Product / Nutrition / Score models + tests
4. Hive adapters/entities for Product (minimal), Scan history entry
5. Error mapper for auth/network
6. Basic navigation (Router) scaffold
Acceptance Criteria:
- Login flow navigates to placeholder home
- Models serialize/deserialize (unit tests)
- Token persisted/retrieved securely

### Sprint 3: Product Scan & Health Score MVP
Deliverables:
- Barcode scan screen
- ProductApi integration (mock JSON fixtures)
- ProductScanRepository (stale-while-revalidate)
- ScoringService (initial deterministic algorithm)
- ScanViewModel + UI states (idle/loading/success/error)
- Score badge component
Tasks:
1. Integrate mobile_scanner; debounce barcode
2. Product DTO + mapping logic
3. Implement ScoringService (nutrition + placeholder additive penalty)
4. Cache product + score in Hive
5. Scan history list (local)
6. Unit tests: repository, scoring
Acceptance Criteria:
- Scanning returns product + score within latency budget (<3s w/ mock)
- Offline re-open shows cached product
- Test coverage for scoring path >80%

### Sprint 4: Meal Discovery & Recipe Integration
Deliverables:
- Meal list UI + filtering (dietary flags stubbed)
- MealApi (mock)
- MealRepository, MealScore aggregator
- Recipe detail view (ingredients referencing products)
- Replace ingredient (non-persisted stub)
Tasks:
1. Meal DTO/model creation
2. Meal list ViewModel (pagination optional)
3. Meal detail screen with ingredient list + open product sheet
4. Aggregated meal score (average or weighted of ingredients)
5. Dietary filter parameter in repository (local filter first)
Acceptance Criteria:
- Meal list loads & detail shows ingredient-linked health score
- Replacing ingredient updates displayed meal score (UI only)
- Unit tests for meal score aggregation

### Sprint 5: Meal Plan Builder, Shopping List, Alternatives Engine (Deterministic)
Deliverables:
- Meal Plan builder screen (weekly grid)
- Shopping list generation from plan
- SubstitutionEngine (deterministic: category & improved score)
- Alternatives UI (carousel on product/meal)
Tasks:
1. MealPlan model & local persistence (Hive)
2. MealPlanViewModel (add/remove meal)
3. ShoppingListRepository (derive from plan + manual add)
4. SubstitutionEngine service + tests
5. AlternativesViewModel (fetch deterministic suggestions)
Acceptance Criteria:
- Add meals to plan & generate shopping list
- Alternatives appear with improved score validation
- Shopping list persists across app restart

### Sprint 6: Nutrition Tracking & Transparency
Deliverables:
- Nutrition log (consume meal/product)
- Daily summary dashboard
- Methodology / “How Score Works” screen
- AI Explanation Service (stubbed with static JSON or simple call)
Tasks:
1. NutritionEntry model + Hive box
2. NutritionAggregator service
3. NutritionTrackingViewModel + dashboard UI
4. Methodology static content page (version tag)
5. Hook AI explanation placeholder (interface only)
Acceptance Criteria:
- Consuming a meal updates daily summary
- Explanation modal shows components & rationale
- All new logic unit tested

### Sprint 7: Crowdsourcing (Basic), Hardening & Release Prep
Deliverables:
- Crowd edit submission form (local queue)
- Basic Moderation model (client placeholder)
- Performance & memory profiling pass
- Crash & analytics hooks (Sentry/Firebase)
- Pre-release checklist
Tasks:
1. EditSubmission model + queued sync job (offline aware)
2. SubmissionViewModel + UI (per product)
3. Add analytics events (scan_completed, substitution_applied)
4. Optimize rebuilds (const widgets, provider scoping)
5. Instrument performance logs
6. Release build smoke tests
Acceptance Criteria:
- Edits persist offline & mark “pending”
- On network available (mock), sync transitions state to “submitted”
- Performance scroll test stable (no dropped frames in sample list)

## 3. Post-MVP (Phase 2+ Snapshot)
- Retail price comparison integration (adapter pattern)
- AI substitution (fallback when deterministic insufficient)
- Personalized recommendation engine (health score + prefs + history)
- Premium tier gating & subscription UI (feature flags)
- Advanced crowdsourcing moderation states (approved/rejected history)

## 4. Detailed Workstreams

### A. AI Integration (Progressive)
Phase 1: Interface + stub responses
Phase 2: Live endpoints (explanations, swaps)
Phase 3: Personalized meal suggestions (contextual prompt bundling)
Tasks:
- ai_client.dart (configurable model, timeout)
- ai_substitution_service.dart
- ai_explanation_service.dart (score component summary)
Quality:
- Timeout handling, circuit breaker, local cache keyed by hash(prompt+inputs)

### B. Health Scoring Evolution
v1: Nutrition-based + additive risk penalty
v2: Processing factor + negative outlier scaling
v3: Personalized adjustments (user goals)
Each version increments algorithm_version → triggers recompute job.

### C. Persistence Strategy
Boxes:
- products_box (minimal)
- meals_box (cached)
- plan_box
- nutrition_log_box
- scan_history_box
- edits_queue_box
Routine:
- Startup warms indexes (async)
- Background sync throttled (TaskRunner)

### D. Error & Logging
- AppException standardized
- Global Riverpod error observer → Sentry
- Network logging disabled in prod build

## 5. Backlog (Not in initial Phase 1)
- Push notifications (meal reminders)
- Image recognition (non-barcode product detection)
- Multi-language localization assets
- Offline search indexing beyond cached items
- Premium feature gating & paywall UI
- Cosmetic/personal care product scoring extension

## 6. Risk Register (Key)
| Risk | Mitigation |
|------|------------|
| Barcode latency | Preload scanner, debounce frames, local cache first |
| AI cost overruns | Cache responses, batch prompts, usage metrics |
| Score trust issues | Transparent methodology page + version changelog |
| Cache growth | LRU eviction for products & images |
| Async race conditions | TaskRunner + guarded state transitions |
| Model drift | Versioned scoring & regression tests |

## 7. Quality Gates
- Coverage ≥ 80% services/repositories
- Lints zero warnings
- Performance: scanning flow < 3s (mock), list frame build < 8ms (profile)
- Security: no plaintext tokens; encryption enforced for sensitive boxes
- Accessibility: basic semantics on top-level screens

## 8. Testing Plan
Unit:
- ScoringService
- SubstitutionEngine
- NutritionAggregator
Widget:
- ScanPage states
- MealPlan builder interactions
Integration:
- Mock server scenarios (success, 404, timeout)
Golden:
- Score badge variations
Regression:
- Score algorithm snapshots (fixture inputs → expected outputs)

## 9. Release Checklist (Phase 1)
- [ ] All sprints’ acceptance criteria met
- [ ] Score algorithm v1 documented
- [ ] Crash & analytics validated
- [ ] Offline reopen test (airplane mode)
- [ ] Accessibility pass (TalkBack basic)
- [ ] Performance profile clean (no major jank)
- [ ] License audit (3rd party dependencies)
- [ ] Security review (token storage, PII scope)

## 10. Task Matrix (Condensed Examples)

| Sprint | Task ID | Title | Owner | Est (D) | Dep |
|--------|---------|-------|-------|---------|-----|
| 1 | FND-01 | Project Bootstrap | Mobile | 1 | - |
| 1 | FND-02 | CI Setup | DevOps | 1 | FND-01 |
| 2 | AUTH-01 | AuthApi + Repo | Backend | 2 | FND |
| 3 | SCAN-01 | Barcode Scanner UI | Mobile | 2 | AUTH |
| 3 | SCORE-01 | ScoringService v1 | AI/Backend | 2 | MODELS |
| 4 | MEAL-01 | Meal Repository | Backend | 2 | SCORE |
| 5 | PLAN-01 | MealPlan ViewModel | Mobile | 2 | MEAL |
| 5 | ALT-01 | SubstitutionEngine | AI | 2 | SCORE |
| 6 | NUTR-01 | Nutrition Log & Aggregator | Backend | 2 | PLAN |
| 7 | CROWD-01 | Edit Submission Queue | Mobile | 2 | SCAN |

(Adjust as needed.)

## 11. Environment & Config
--dart-define:
- API_BASE_URL
- AI_API_BASE
- BUILD_ENV
- FEATURE_FLAGS (JSON: { "premium": false })
- SCORE_ALGO_VERSION

## 12. Documentation Artifacts
- /docs/architecture.md (current)
- /docs/scoring_v1.md (algorithm details)
- /docs/api_contracts/*.yaml (OpenAPI)
- /docs/adrs/ (architectural decisions)

## 13. Incremental Delivery Strategy
- Merge behind feature flags (scan, meals, plan)
- Dark-launch scoring updates (dual-run old/new → compare)
- Collect anonymized metrics early for tuning (swap acceptance)

## 14. Exit Criteria for MVP
- Core flows: Scan → Product → Score; Browse Meal → Add to Plan → Shopping List; Log Meal → Nutrition Summary
- Alternatives functioning (deterministic)
- Transparent methodology available
- Stable offline for last 50 scans + current meal plan

## 15. Next Actions (Immediately)
1. Execute Sprint 1 tasks (bootstrap, CI, lint, Hive init)
2. Draft scoring_v1.md
3. Prepare mock JSON fixtures (products, meals)
4. Create initial OpenAPI skeleton for product & meal endpoints
5. Set up performance baseline profiling script