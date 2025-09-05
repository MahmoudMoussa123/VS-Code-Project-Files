# Software Requirements Specification (SRS)  
AI-Powered Meal Planner & Product Analysis App (Hello Fresh + Yuka Unified)

## 1. Introduction
### 1.1 Purpose
Define functional and non-functional requirements for a mobile application combining meal planning, nutrition tracking, product barcode scanning, health scoring, and substitution intelligence.

### 1.2 Scope
Platforms: Android (initial), iOS (later).  
Users: Consumers (meal planning, scanning), Admins (content & moderation), (future) Premium users.  
Exclusions (Phase 1): Retail checkout, premium tiers, advanced crowdsourcing workflow, push notifications.

### 1.3 References
- feature_list.md (functional scope)
- architecture.md (technical architecture)
- development_plan.md (phased roadmap)
- scoring_v1.md (to be authored)
- OpenAPI contracts (to be authored)

### 1.4 Definitions & Acronyms
- Health Score: Composite 0–100 product/meal score.
- SWR: Stale-While-Revalidate caching pattern.
- DTO: Data Transfer Object.
- MVVM: Model–View–ViewModel.
- AI Explanation: Generated rationale for score or substitution.
- Deterministic Alternatives: Non-AI substitution suggestions.
- Crowd Edit: User-submitted correction to product data.

## 2. Overall Description
### 2.1 Product Perspective
Hybrid of meal-kit planner and product analysis scanner. Offline-first subsets (recent scans, meal plan, last 50 products). AI augments but does not replace deterministic logic.

### 2.2 User Classes
| User Type | Description | Key Features |
|-----------|-------------|--------------|
| Guest (future) | Limited browsing | View meals (public) |
| Authenticated User | Core persona | Scan, plan, nutrition, alternatives |
| Premium User (future) | Paid tier | Advanced analytics, deeper AI |
| Admin (external tool) | Internal ops | Moderation, catalog mgmt |
| QA / Support | Diagnosis | Logs, score version |

### 2.3 Operating Environment
- Flutter app (Dart ≥ 3.x)
- Android 8+ (API 26+), iOS 15+ (later)
- Network: 3G+ / Wi-Fi; partial offline support
- Backend microservices (cloud)

### 2.4 Constraints
- Response for scan ≤ 3s (mock baseline)
- Health score transparency required
- AI cost budget (enforce caching)
- GDPR/CCPA compliance
- Local storage encryption for sensitive artifacts

### 2.5 Assumptions & Dependencies
- External nutrition & product data sources available
- Barcode scanning plugin compatible with target devices
- AI provider SLA (≥ 99%) or fallback path active
- User base initial region: single locale (EN) expanding later

## 3. System Features (Functional Requirements)
Each feature includes: ID, Description, Priority (M = Must, H = High, O = Optional Phase 2+), Acceptance Summary.

### F-001 Barcode Product Scan (M)
Scan EAN/UPC, resolve product, show detail + score.  
Acceptance: Correct match or “No match” + add/edit option; latency ≤ 3s (mock).  
Errors: Network fail → cached result or retry prompt.

### F-002 Product Detail & Health Score (M)
Displays product name, brand, ingredients, nutrition, score breakdown (nutrition/additives/processing).  
Acceptance: Score version visible; missing component triggers “Recalculating” state.

### F-003 Ingredient-Level Risk Flags (H)
Flag additives/contaminants with severity + explanation.  
Acceptance: Tooltip or expandable row; link to source URL.

### F-004 Healthier Alternatives (H)
Deterministic substitutions (better score, dietary fit).  
Acceptance: List ranked by score delta; selecting updates current context (plan or list).

### F-005 AI-Based Alternatives (O Phase 2)
If deterministic < threshold suggestions, fallback to AI with structured JSON.  
Acceptance: AI results validated (schema, uniqueness); flagged if confidence < threshold.

### F-006 Meal Discovery (M)
Browse meal catalog; filter by dietary tags, score threshold.  
Acceptance: Filters combine (AND logic); pagination or lazy load.

### F-007 Recipe Detail & Ingredient Linking (M)
Show steps, per-serving nutrition, aggregated meal score. Ingredient click opens product sheet.  
Acceptance: Score recalculates after substitution (UI-level).

### F-008 Meal Plan Builder (H)
Weekly calendar; add/remove meals; persist locally.  
Acceptance: Adding meal updates aggregated shopping list.

### F-009 Shopping List Generation (H)
Derive ingredients from plan; manual adjustments; mark acquired.  
Acceptance: Items deduplicated (quantity aggregated).

### F-010 Nutrition Tracking (H)
Log consumed meals/products; daily/weekly summary dashboard.  
Acceptance: Adds entry updates summary without full recompute (incremental).

### F-011 Unified Health Score Algorithm (M)
Composite 0–100 with transparent components; versioned.  
Acceptance: Algorithm version stored; change triggers recomputation job (future).

### F-012 Score Explanation (O Phase 2 AI)
Plain-language explanation for score factors.  
Acceptance: Fallback to deterministic template if AI unavailable.

### F-013 Scan History & Favorites (H)
Local list of recent scans (≥ 50), favorites separate from meals.  
Acceptance: History persists offline; clear-all operation.

### F-014 Crowdsourced Edit Submission (H)
User proposes correction; queued offline; sync later.  
Acceptance: Status states: pending → submitted.

### F-015 Methodology / Transparency Page (M)
Explains scoring approach, last updated timestamp.  
Acceptance: Version matches algorithm_version in score data.

### F-016 Authentication (M)
Login via email/password (social later); token refresh handling.  
Acceptance: Secure storage; auto-refresh before expiry.

### F-017 Preferences & Dietary Filters (M)
Store user dietary constraints; applied to recommendations and filtering.  
Acceptance: Persisted across sessions; invalid combos rejected (e.g., vegan + pescatarian conflict warning).

### F-018 Alternatives Integration with Plan & List (H)
Accepted alternative updates both meal (if relevant) and shopping list quantities.  
Acceptance: Health delta displayed before confirm.

### F-019 Local Offline Caching (M)
Cache last 50 scans, current meal plan, favorites, recent meals.  
Acceptance: Airplane mode test passes (open app → data visible).

### F-020 Admin Moderation (Future External) (O)
Out-of-scope for in-app user; reserved for backend console.

### F-021 Analytics & Event Logging (M)
Track scan_completed, substitution_applied, meal_planned, nutrition_goal_progress.  
Acceptance: Events batched, retries on failure.

### F-022 Error Handling & Messaging (M)
Standardized user-facing messages, internal codes.  
Acceptance: No raw exception strings displayed.

### F-023 Security & Privacy Controls (M)
Consent flags, data export/delete (future iteration).  
Acceptance: Consent stored; telemetry obeys opt-out.

### F-024 Localization Framework (O Phase 2)
Infrastructure ready though only EN content initially.  
Acceptance: Strings externalized (no hard-coded constants).

### F-025 Performance Metrics (M)
Time to scan result & score calculation logged.  
Acceptance: 95th percentile performance thresholds monitored.

## 4. External Interface Requirements
### 4.1 User Interface
- Mobile screens: Scan, Product Detail, Meal List, Meal Detail, Plan, Shopping List, Nutrition Dashboard, Methodology, Login, Settings.
- Accessibility: Screen reader labels on actionable elements; sufficient contrast.

### 4.2 API Interfaces (Abstract)
| Endpoint | Method | Purpose |
|----------|--------|---------|
| /auth/login | POST | Token issuance |
| /products?gtin= | GET | Product lookup |
| /products/{id}/score | GET | Score retrieval |
| /meals | GET | Meal listing |
| /meals/{id} | GET | Meal detail |
| /recommendations/swaps | POST | Deterministic/AI alternatives |
| /edits | POST | Crowd edit submission |
| /nutrition/summary | GET | Aggregated nutrition stats |

### 4.3 Hardware Interfaces
- Camera for barcode scanning
- Biometric (fingerprint/face) optional

### 4.4 Software Interfaces
- AI provider API (REST)
- Nutrition/source data provider
- Push notification service (Phase 2)
- Secure storage (KeyStore / KeyChain abstraction)

## 5. Data Requirements
### 5.1 Core Entities (Domain)
- Product { id, gtin, name, brand, ingredients[], nutrition, score?, updatedAt }
- Score { value, components { nutrition, additives, processing }, algorithmVersion, calculatedAt }
- Meal { id, title, ingredients[], steps[], aggregatedScore }
- MealPlan { weekId, slots: Map<DaySlot, MealRef> }
- NutritionEntry { id, timestamp, referenceId (meal|product), nutrients, score }
- ScanRecord { id, gtin, timestamp }
- EditSubmission { id, productId, payloadChanges, status }

### 5.2 Persistence
- Hive boxes + encryption where necessary
- TTL & SWR policies (Product 7d; Score invalidated on algorithm version change)

### 5.3 Data Integrity Rules
- Ingredient tokens normalized (lowercase, trimmed)
- Score must reference existing algorithmVersion in metadata
- Meal aggregated score recalculated if ingredient list changes

## 6. Non-Functional Requirements
### 6.1 Performance
| Item | Target |
|------|--------|
| Scan result latency | ≤ 3s (mock Phase 1) |
| Cold start | ≤ 4s on mid-tier device |
| Frame build (list screens) | < 16ms average |
| Score compute single item | < 120ms local |

### 6.2 Scalability
- Modular feature packages
- AI requests rate-limited with exponential fallback
- Caching to reduce repeated external calls

### 6.3 Reliability & Availability
- Offline fallback for critical cached data
- Retry strategy for idempotent GETs
- Crash-free sessions > 99% target

### 6.4 Security
- Encrypted tokens & sensitive boxes
- No PII in logs
- Transport security: HTTPS only
- Token rotation & refresh concurrency lock

### 6.5 Privacy
- Minimal personal data (email, preferences)
- AI calls stripped of direct identifiers
- Consent tracking (marketing, analytics)

### 6.6 Maintainability
- Code generation for models
- Lint rules enforced CI
- Feature isolation reduces cross-module coupling

### 6.7 Testability
- Deterministic services (pure scoring) unit tested
- AI integration abstracted behind interface for mocking
- >80% coverage (services + repositories)

### 6.8 Usability
- Clear visual score badge
- Ingredient flags concise (≤ 2 lines each)
- Swipe interactions minimized for accessibility

### 6.9 Localization (Future)
- Resource bundles structured; fallback chain defined

### 6.10 Observability
- Structured analytics events
- Error & performance tracing (Sentry tags: feature, version)

## 7. AI-Specific Requirements
| Aspect | Requirement |
|--------|-------------|
| Fallback | Deterministic path used if AI timeout > configured (e.g., 2.5s) |
| Caching | Prompt+input hash; TTL configurable |
| Explainability | Provide non-AI fallback explanation template |
| Cost Control | Request budget metrics reported daily |
| Safety | Disallow AI modifying core numeric scores (read-only augmentation) |

## 8. Risk Management (Selected)
| Risk | Impact | Mitigation |
|------|--------|-----------|
| AI latency spikes | UX degradation | Timeout + fallback deterministic |
| Product DB mismatch | Incorrect scores | Hash & revalidation; crowd edit |
| Algorithm mistrust | User churn | Transparent methodology page |
| Cache bloat | Storage pressure | LRU eviction & size quotas |
| Sync conflicts | Data inconsistency | updatedAt precedence rule |

## 9. Constraints
- Must use Riverpod (no manual service locators)
- Must adopt Freezed/json_serializable
- No blocking UI thread for heavy operations
- Single codebase (no platform divergence Phase 1)

## 10. Logging & Analytics
- Event schema versioned
- PII excluded
- Error correlation IDs injected per session
- Performance spans: scan_flow, score_compute, alt_generation

## 11. Security Requirements
- OWASP Mobile Top 10 considerations
- Input validation (GTIN length, numeric)
- Rate limiting on auth endpoints (server-side)
- Biometric unlock optional for re-entry (future)

## 12. Compliance Requirements
- GDPR basic: data export/delete (Phase 2)
- CCPA: “Do not sell” flag (future)
- Privacy policy link accessible in settings

## 13. Acceptance Criteria Summary (Primary)
| Feature | Key Acceptance |
|---------|----------------|
| Scan | Latency ≤ target; match or no-match path |
| Score | Visible breakdown + version |
| Alternatives | Guaranteed improvement or explained absence |
| Meal Plan | Persistence & integrity after restart |
| Nutrition Dashboard | Real-time incremental updates |
| Crowd Edit | Offline queueing functioning |
| Methodology | Version sync with algorithmVersion |
| Offline Mode | Cached essentials accessible |

## 14. Traceability Matrix (Abbrev.)
| Req ID | Sprint (Plan) | Feature Ref |
|--------|---------------|-------------|
| F-001 | 3 | Barcode-first UX |
| F-002 | 3 | Health Score |
| F-003 | 6 (Phase 2 if deferred) | Ingredient-level Analysis |
| F-004 | 5 | Alternatives deterministic |
| F-005 | Post-MVP | AI alternatives |
| F-006 | 4 | Meal Discovery |
| F-007 | 4 | Recipe Details |
| F-008 | 5 | Meal Plan Builder |
| F-009 | 5 | Shopping List |
| F-010 | 6 | Nutrition Tracking |
| F-011 | 3 | Score Algorithm |
| F-012 | Post-MVP | AI Explanation |
| F-013 | 3 (history), 6 (expansion) | Scan History |
| F-014 | 7 | Crowdsourced Edits |
| F-015 | 6 | Methodology Docs |
| F-016 | 2 | Authentication |
| F-017 | 2/5 | Dietary Filters |
| F-018 | 5 | Alternatives Integration |
| F-019 | 3–6 rolling | Offline Cache |
| F-021 | 7 | Analytics |
| F-022 | All | Error Handling |
| F-023 | 2/7 | Privacy & Security |
| F-025 | 3 | Perf Metrics |

## 15. Open Issues
| ID | Description | Target Resolution |
|----|-------------|------------------|
| OI-01 | Exact nutrition API provider selection | Before Sprint 3 |
| OI-02 | AI provider/model choice | Before Phase 2 |
| OI-03 | Premium feature scope | Post-MVP planning |
| OI-04 | Push notification timing | Phase 2 design |
| OI-05 | Data export workflow | Phase 2 security review |

## 16. Approval Criteria
SRS accepted when:
- All Must-have features mapped to sprints
- Non-functional targets defined
- Risk mitigations documented
- Traceability matrix complete

## 17. Appendices
### 17.1 Non-Functional SLA Targets (Initial)
- Uptime (backend): 99% (internal)
- AI fallback success: ≥ 95% of AI attempts have deterministic fallback
- Crash free sessions: ≥ 99%

### 17.2 Future Enhancements (Not in Scope)
- Image (non-barcode) product recognition
- Premium analytics (macro periodization)
- Family/shared meal planning
- Retail cart push integration
- Cosmetics/personal