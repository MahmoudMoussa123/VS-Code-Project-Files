# AI-Powered Meal Planner & Product Analysis App Architecture (Flutter + Riverpod + MVVM)

## 1. Goals
- Merge meal planning, recipe management, nutrition tracking, product scanning, health scoring, and substitutions.
- Scalable feature-first modular codebase enabling parallel team work.
- Deterministic core logic + AI augmentation (suggestions, explanations, substitutes).
- Offline-first for key flows (recent meals, scans, favorites).
- High test coverage and automated quality gates.

## 2. Core Principles
- Feature-first modules (isolate unrelated code).
- Clean layering: UI → ViewModel → Repository → Service → Data (Local/Remote).
- Uni-directional flow and immutable domain models.
- Riverpod for dependency graph + state; no direct singleton usage.
- Avoid business logic in widgets.
- Freezed + json_serializable for models.
- Background execution for heavy parsing/scoring.
- Strict error and cancellation handling for async tasks.

## 3. Tech Stack
- Flutter (stable channel), Dart >= 3.x
- State: Riverpod (hooks_riverpod for widgets)
- Codegen: build_runner, freezed, json_serializable
- Local DB: Hive (+ encrypted box for sensitive tokens)
- Secure storage: flutter_secure_storage
- Networking: dio + retrofit-like generator (optional) + interceptors
- AI: REST / gRPC clients (e.g., OpenAI/Azure/Open-source gateway)
- Barcode: mobile_scanner (or MLKit plugin)
- DI: Riverpod providers (no manual service locator)
- Analytics/Crash: Firebase Analytics / Sentry
- Testing: flutter_test, mocktail, golden_toolkit

## 4. Layer Definitions
- UI (Widgets, Routes, Theming, Localization)
- ViewModel (StateNotifiers & AsyncNotifiers, orchestrate use cases)
- Repository (Aggregate data sources; return domain models)
- Services (Atomic responsibilities: scoring, AI suggestions, swap engine)
- Data Sources (Remote APIs, Local persistence)
- Models (Domain, DTO, Persistence Entities)
- Shared (Core utilities: either separate core/ folder or shared package)

## 5. Feature Modules (Examples)
Each folder = self-contained (except shared core):
- feature_meal_discovery
- feature_meal_plan_builder
- feature_recipe_details
- feature_nutrition_tracking
- feature_product_scan
- feature_health_scoring
- feature_alternatives
- feature_shopping_list
- feature_auth
- feature_user_profile
- feature_preferences
- feature_retail_integration
- feature_crowdsourcing
- feature_admin_tools (optional in separate app)
- feature_notifications
- feature_search
- feature_offline_cache

## 6. Directory Layout (Example)
````text
lib/
  app/
    app_bootstrap.dart
    app_widget.dart
    routing/
      app_router.dart
  core/
    config/
      environment.dart
    error/
      app_exception.dart
      error_mapper.dart
    network/
      dio_client.dart
      interceptors/
    utils/
      debounce.dart
      task_runner.dart
    logging/logger.dart
    constants/
    ai/
      ai_client.dart
      ai_models.dart
  shared/
    models/
    services/
      time_service.dart
      uuid_service.dart
  feature_product_scan/
    ui/
      scan_page.dart
      widgets/
    viewmodel/
      scan_viewmodel.dart
      scan_state.dart
    repository/
      product_scan_repository.dart
    services/
      barcode_scanner_service.dart
      product_match_service.dart
    data/
      remote/
        product_api.dart
        dto/
          product_dto.dart
      local/
        product_cache.dart
    models/
      product.dart
  feature_meal_plan_builder/
    ui/...
    viewmodel/...
    repository/...
    services/
      meal_score_service.dart
    data/
      remote/
      local/
    models/
  feature_health_scoring/
    services/
      scoring_service.dart
      additive_risk_service.dart
    models/
      score.dart
  feature_alternatives/
    services/
      substitution_engine.dart
      ai_substitution_service.dart
    repository/
      alternatives_repository.dart
  feature_nutrition_tracking/
    ui/
    viewmodel/
    repository/
    services/
      nutrition_aggregator.dart
    data/
      local/
        nutrition_log_box.dart
    models/
      nutrition_entry.dart
  feature_auth/
    ui/
    viewmodel/
    repository/
    services/
      auth_service.dart
    data/
      remote/
        auth_api.dart
    models/
  feature_search/
  feature_notifications/
  main.dart
````

## 7. Data Flow
1. UI Widget triggers an intent (button tap, scan event, route enter).
2. ViewModel method executes (pure orchestration, no platform code).
3. Repository aggregates local (Hive cache) + remote (API) sources.
4. Services apply domain logic (scoring, AI augmentation, substitutions).
5. Repository returns domain models (immutable Freezed objects).
6. ViewModel updates Riverpod StateNotifier / AsyncNotifier state.
7. UI rebuilds via Consumer / HookConsumerWidget.
8. Side-effects (logging, analytics) dispatched after successful state transition.

Sequence (scan example):
UI → ScanViewModel.scan(barcode) → ProductScanRepository.lookupBarcode(gtin)
→ ProductApi.fetchByBarcode → ScoringService.ensureScore → ViewModel state = success(product)

## 8. Models
Principles:
- Domain models: Freezed + json_serializable.
- Separate DTOs (API) vs Persistence Entities (Hive) when field shape differs.
- Mapping only in repository/service layer (single responsibility).

Conventions:
- Domain: product.dart, meal.dart (Freezed)
- DTO: product_dto.dart with toDomain()
- Entity: product_entity.dart with toDomain() / fromDomain()

## 9. Riverpod Patterns
Provider types:
- Provider<T>: stateless dependencies (e.g., config)
- FutureProvider / StreamProvider: passive async queries
- StateNotifierProvider: interactive view state with events
- AutoDispose variants for short-lived flows (search, ephemeral forms)

Example wiring:
````dart
final dioProvider = Provider<Dio>((ref) {
  final env = ref.watch(environmentProvider);
  return Dio(BaseOptions(baseUrl: env.apiBaseUrl));
});

final productApiProvider = Provider<ProductApi>((ref) {
  return ProductApi(ref.watch(dioProvider));
});

final scoringServiceProvider = Provider<ScoringService>((ref) {
  final additive = ref.watch(additiveRiskServiceProvider);
  return ScoringService(additiveRiskService: additive);
});

final scanViewModelProvider =
    StateNotifierProvider<ScanViewModel, ScanState>((ref) {
  return ScanViewModel(
    repo: ref.watch(productScanRepositoryProvider),
    scoringService: ref.watch(scoringServiceProvider),
  );
});

10. ViewModel Guidelines
No direct platform calls.
Wrap async logic with cancellation awareness (check mounted).
Emit loading → data / error states atomically.
Avoid mutable collections; replace lists with new instances.
11. State Modeling
Use sum types (Freezed unions): idle | loading | success(T) | error(message). Add pagination / filtering fields for list states.

12. Repositories
Responsibilities:

Data fetch & merge
Caching strategy (stale-while-revalidate)
Error normalization (convert network/parsing errors to AppException)
Pattern:

class MealRepository {
  MealRepository({required this.remote, required this.cache});
  final MealApi remote;
  final MealCache cache;

  Future<List<Meal>> list({bool force = false}) async {
    final cached = await cache.getAll();
    if (cached.isNotEmpty && !force) _revalidateInBackground();
    if (cached.isNotEmpty && !force) return cached;
    final dtos = await remote.fetchMeals();
    final meals = dtos.map((d) => d.toDomain()).toList();
    await cache.putAll(meals);
    return meals;
  }

  void _revalidateInBackground() {
    // fire-and-forget with error guard
  }
}

13. Services
Focused logic units:

ScoringService: nutrition + additive risk → Score
AdditiveRiskService: maps ingredient tokens → hazard metadata
SubstitutionEngine: deterministic filtering
AiSubstitutionService: AI fallback suggestions
NutritionAggregator: daily summaries
TaskRunner: controlled concurrency
AiExplanationService: health score explanation text
14. AI Integration
Patterns:

Each AI call behind interface (e.g., AiClient.generateExplanation()).
Apply:
Timeout
Retry (non 4xx)
Circuit breaker (open after N failures)
Cache stable prompts (hash prompt+inputs) with TTL to reduce cost.
Redact PII: pass only hashed user_id, high-level dietary prefs.
15. Barcode & Nutrition APIs
Flow:

mobile_scanner triggers onDetection(barcode)
Debounce duplicate frames
ViewModel validates format (EAN-13/UPC)
Repository fetch or cache-hit
Nutrition enrichment service fetches missing macro fields from external API; persists.
16. Persistence (Hive)
Boxes:

products_box: minimal product snapshot
scores_box: Score objects keyed by productId+algorithmVersion
nutrition_log_box: daily entries
scan_history_box
preferences_box Encryption:
Derive encryption key stored in secure storage. Migration:
Box version tracked; on bump run migration handlers.
17. Async & Background
Use:

compute / isolates for bulk scoring recalculation.
TaskRunner for queueing: maxConcurrent = 3 to avoid UI jank.
Periodic sync (WorkManager / background_fetch) for refreshing popular products & scores.
18. Error Handling
AppException taxonomy:

NetworkException(code, retriable)
NotFoundException(resource)
ValidationException(field, message)
AiTimeoutException
CacheMissException Mapping: Data layer throws raw -> Repository catches -> wraps into AppException.
19. Caching Strategy
Policy:

Product: TTL 7 days or until ingredient list changes hash.
Score: recompute if algorithm_version increments.
Additive metadata: TTL 30 days (rarely changes).
Use ETag / If-None-Match where supported.
20. Networking
Dio interceptors:

AuthInterceptor: attaches bearer token / handles 401 refresh queue
RetryInterceptor: exponential backoff (GET only)
LoggingInterceptor (debug)
AnalyticsInterceptor: event on latency > threshold
21. Authentication
Flow:

Email/password or OAuth social
Tokens persisted securely
Refresh token rotation; replay protection Providers:
authStateProvider (AsyncValue<AuthUser?>) Route Guards:
Wrap router with provider listener; redirect unauthenticated to login.
22. Security & Privacy
Minimally store user dietary preferences (enum flags)
Hash user IDs when sending to AI
Pseudonymize analytics events
Provide data export/delete function (GDPR)
23. Theming & Localization
Theme provider (light/dark/system)
ARB localization with build_runner
Feature modules avoid hard-coded strings: use context.l10n
24. Search & Indexing
Hybrid search:

Local index (Isar optional) for last N products/meals
Remote query for global search; merge & rank Ranking factors:
Text relevance
Health score (boost)
User favorites (boost)
Availability
25. Health Scoring Pipeline
Steps:

Normalize nutrition per 100g / per serving.
Calculate macro ratios vs recommended thresholds.
Add additive penalties (severity-weighted).
Processing factor penalty.
Composite = clamp(0–100). Explainability:
Keep component vector {nutritionScore, additivePenalty, processingPenalty}.
Provide top 3 positive and negative contributing factors.
26. Alternatives & Substitution Engine
Deterministic filter criteria:

Same category
Score improvement ≥ delta (default 5)
Dietary constraints satisfied
Price within user tolerance If < MIN_SUGGESTIONS → AI fallback:
Provide JSON schema prompt to ensure parseable output. Merge + de-duplicate then rank.
27. Nutrition Tracking
NutritionAggregator:

Incremental add: DailySummary += entry
Remove: recalc diff only DailySummary fields:
calories, protein, fat, carbs, fiber, sugar, sodium, avgScore ViewModel surfaces AsyncValue<DailySummary>.
28. Notifications
Types:

Local: meal prep reminders, goal progress
Push: subscription updates, score algorithm changes Implementation:
NotificationService schedules local alarms
Remote config toggles frequency caps
29. Crowdsourcing & Moderation
Submission pipeline:

User submits edit (ingredient correction)
Stored offline if no network
Sync job POSTs batched Moderation states: pending → reviewing → approved/rejected Admin tool manages queue.
30. Offline Strategy
Cache tiers:

Critical: meals, recipes, favorites, last 50 scans
Opportunistic: product images (LRU) Conflict resolution:
Maintain updatedAt; keep newer
If schema mismatch, migration strategy triggered
31. Testing Strategy
Unit: 90% coverage on services/repositories
Widget: golden tests for key states
Integration: using mock server (e.g., shelf + dio override)
Performance: frame build budget under 8ms for lists (profile mode)
Contract: snapshot JSON fixtures vs DTO decode
32. CI/CD
GitHub Actions:

jobs: analyze, test, coverage-report, build-android, build-ios Caching:
Pub cache
build_runner generated code (hash lockfile) Artifacts:
Upload coverage & APK/AAB/IPAs for QA
33. Metrics & Observability
Analytics events:

scan_completed(barcode_type, latency_ms)
substitution_applied(delta_score)
meal_planned(count)
nutrition_goal_met(goalType) Performance tracing around:
scoring_service
ai_substitution_service Sentry tags: feature, version, user_tier
34. Example Provider Wiring (Barrel)

// feature_health_scoring/providers.dart
final additiveRiskServiceProvider = Provider<AdditiveRiskService>((ref) {
  final repo = ref.watch(additiveMetadataRepositoryProvider);
  return AdditiveRiskService(repo: repo);
});

final scoringServiceProvider = Provider<ScoringService>((ref) {
  return ScoringService(additiveRiskService: ref.watch(additiveRiskServiceProvider));
});

35. Generated Code Commands35. Generated Code Commands

dart run build_runner build --delete-conflicting-outputs
dart run build_runner watch --delete-conflicting-outputs

36. Linting & Style
analysis_options.yaml (excerpt):

include: package:flutter_lints/flutter.yaml
analyzer:
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
linter:
  rules:
    - prefer_const_constructors
    - avoid_print
    - public_member_api_docs
    - always_declare_return_types
    - exhaustive_cases
    - unnecessary_lambdas

    37. Performance
Optimizations:

Use const widgets
Split large list items into smaller sub-widgets
Cache score badge color computations
Debounce search (300ms)
Pre-warm isolate for heavy scoring batch
38. Progressive Roadmap (Architecture Lens)
Phase 1: Scanning, basic meals, scoring skeleton, local cache, auth Phase 2: Alternatives engine, nutrition tracking, AI explanations Phase 3: Crowdsourcing, retail integration, premium tier, advanced personalization

39. Deployment Environments
--dart-define flags:

API_BASE_URL
AI_API_BASE
BUILD_ENV (dev|staging|prod)
SENTRY_DSN EnvironmentProvider exposes config to DI graph.
40. Build Flavors & Entry Points
Entry files:

main_dev.dart
main_staging.dart
main_prod.dart Command:

flutter run --flavor staging -t lib/main_staging.dart

41. Quality Gates
Analyzer: 0 warnings
Coverage ≥ 80% (fail build if lower)
No TODO / FIXME in production flavor
Dependency audit (licensing) on CI
Performance smoke test (scroll list, scan flow) < threshold latency