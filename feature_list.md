<!-- filepath: vscode-copilot-file://7ab5ee83-f83e-41fb-9eaa-65188fa7d97b/feature_list.md/feature_list.md -->
# Hello Fresh + Yuka — Unified Mobile App Feature List

## Overview
Concise, merged feature list combining Hello Fresh meal-kit, ordering, and personalization with Yuka-style product analysis, scanning, and recommendation capabilities. Goal: one app that supports meal planning, grocery management, product health insights, and commerce.

## Core Meal & Commerce Features
- Meal Discovery
  - Browse curated menus, seasonal highlights, trending meals, and retailer product listings.
- Personalized Recommendations
  - Meal and product suggestions based on preferences, order history, dietary goals, and health scores.
- Meal Plan Builder
  - Create, edit, and save weekly meal plans with customizable servings; apply automated healthier swaps.
- Recipe Details
  - Ingredient lists, step-by-step instructions, cooking time, difficulty, per-serving nutrition, and health score impact.
- Grocery & Shopping Lists
  - Auto-generated shopping lists, add/remove items, add scanned products, sync with carts or partner retailers.

## Product Analysis & Scanning (Yuka-style)
- Barcode-first UX & Packaged-Product Database
  - Primary scan entry to look up packaged products; return product details, images, brand, nutrition facts, and compatibility with meals.
- Unified Health Score (0–100)
  - Single health score per product/ingredient shown as a badge; score components (nutrition, additives, processing) visible in details.
- Ingredient-level Analysis & Additive/Contaminant Detection
  - Highlight risky additives, preservatives, contaminants with plain-language explanations and source links; per-ingredient contributions to the health score.
- Healthier Alternatives & Swap Suggestions
  - Suggest healthier product or ingredient swaps ranked by health score, dietary match, price, and pantry availability; one-tap replace/update actions.
- Scan History, Bookmarks & Product Favorites
  - Maintain a searchable scan history, product bookmarks, and per-product favorites separate from meal favorites.
- Transparent Scoring & Sourcing Details
  - Publish scoring methodology summary in-app; show per-ingredient scoring rationale and sourcing/origin metadata when available.
- In-App Retail Recommendations & Compare/Buy
  - Surface retail alternatives with price/availability and direct links or partner checkout integrations; compare products side-by-side.

## Personalization & Dietary Support
- Dietary Preferences & Filters
  - Filter by vegetarian, vegan, pescatarian, gluten-free, dairy-free, low-sugar, low-salt, etc.
- Allergen Alerts & Risk Warnings
  - Flag common allergens and flagged additives/contaminants on meals and scanned products.
- Nutrition & Diet Impact Tracking
  - Per-meal calories and macronutrients plus cumulative daily/weekly diet impact tracking and progress toward goals.
- Favorites & Reorder
  - Mark favorite meals and products; quick reorder and replace with healthier alternatives.

## Engagement & Retention
- Push Notifications
  - Delivery reminders, new menu alerts, scanned-product updates, and personalized health alerts.
- Promotions, Coupons & Premium Tiers
  - Apply discounts, referral rewards, premium analysis features (deeper breakdowns, family sync, ad-free).
- Ratings, Reviews & Crowdsourced Data
  - Rate meals/products, submit corrections to product DB, and optionally contribute product entries (moderated).

## Utility, Search & Offline Capability
- Smart Search
  - Search by ingredient, meal name, cuisine, dietary tag, barcode, or product health score.
- Offline Access
  - Cache recipes, saved meal plans, scanned-product info, and recent search results for offline viewing.
- Image & Brand Matching
  - Use product images to improve matches, support crowdsourced corrections and periodic DB sync.

## Accessibility, Internationalization & Privacy
- Multi-language Support & Local Units
  - Localized UI, units, region-specific products and menus.
- Accessibility Features
  - VoiceOver/TalkBack support, high-contrast mode, scalable text.
- Secure Authentication & Data Controls
  - Email/password, social sign-in, biometric login; manage marketing preferences and data-sharing consent.
- Compliance
  - GDPR, CCPA and applicable regional regulations.

## Support, Feedback & Help
- In-App Help Center & Methodology Docs
  - FAQs, troubleshooting, delivery policies, and an accessible explanation of the health-scoring methodology.
- Live Chat & Support Tickets
  - Contact support, submit issues, track status.
- Feedback Collection
  - In-app surveys, product reports, and moderation queue for crowdsourced entries.

## Admin & Operational Features (Internal)
- Menu & Product DB Management
  - Admin UI for adding/editing meals and products, tagging dietary info, scheduling menus, and moderating crowdsourced product edits.
- Inventory, Logistics & Partner Integrations
  - Sync delivery slots, inventory forecasts, courier tracking, and retailer/partner commerce integration.
- Analytics & Monitoring
  - User engagement, conversion funnels, health-feature usage, retention tracking, and product DB coverage metrics.

## Detailed Feature Specifications — For Cloning & Implementation

Below are implementation-oriented specifications for the unified Hello Fresh + Yuka app. Each feature includes user stories, acceptance criteria, UI components, data/API notes, priority, and key metrics. Use these as sprint-ready tickets and implementation guides.

1) Barcode-first Product Lookup & Packaged-Product DB  
   - User stories: As a user I can scan a barcode to see product details, health score, and meal compatibility. As an admin I can import/curate product data.  
   - Acceptance criteria: Scan returns a product match within 3s or shows “no match” with an easy add flow; displays image, brand, nutrition, ingredients, allergens, score breakdown.  
   - UI components: Scan camera view, scan result card, product detail page, “Report a problem / Suggest edit” CTA.  
   - Data / APIs: Product record (gtin, name, brand, images[], nutrition facts, ingredients[], allergens[], sourcing[], retail links[]); endpoints: GET /products?gtin=, POST /products, PATCH /products/{id}. Background job to sync provider DBs and nightly dedupe.  
   - Priority: Must-have.  
   - Metrics: scan success rate, average lookup latency, DB coverage % (countries), user-reported mismatch rate.

2) Unified Health Score (0–100) & Component Breakdown  
   - User stories: As a user I want a single health score plus component scores (nutrition, additives, processing) so I can compare quickly.  
   - Acceptance criteria: Every product and meal has a score and visible breakdown; score algorithm version displayed; score updates when ingredients change.  
   - UI components: Score badge, breakdown bar chart, "How this score is calculated" modal.  
   - Data / APIs: Score object {score, components: {nutrition, additives, processing}, algorithm_version, last_calculated_at}; endpoint GET /products/{id}/score. Score computation service runs in isolated microservice with explainable logs.  
   - Priority: Must-have (basic).  
   - Metrics: percent of items with score, user trust (feedback up/down), change requests.

3) Ingredient-level Analysis & Additive/Contaminant Detection  
   - User stories: As a user I want to see which ingredients contribute negatively and why.  
   - Acceptance criteria: Ingredient list annotates flagged ingredients/additives with severity and short explanation; links to sources.  
   - UI components: Ingredient list with inline flags and details popover, “Risks & Additives” section.  
   - Data / APIs: Ingredient registry with risk tags, hazard_metadata, evidence_urls; endpoint GET /ingredients/{id}. Automated text-extraction pipeline to map ingredient synonyms.  
   - Priority: High.  
   - Metrics: flagged-ingredient count, user click-through to details, false-positive rate.

4) Healthier Alternatives & One-tap Swaps  
   - User stories: As a user I can replace an ingredient/product in a recipe or shopping list with a healthier alternative with one tap.  
   - Acceptance criteria: Swap suggestions are relevant to dietary filters and pantry contents; swap updates shopping list and meal plan immediately.  
   - UI components: "Suggested alternatives" carousel on product/recipe pages, swap confirmation sheet.  
   - Data / APIs: Recommendation engine input {user_profile, pantry, dietary_filters, price_pref}; endpoint POST /recommendations/swaps. Sync with shopping list service to update items.  
   - Priority: High.  
   - Metrics: swap acceptance rate, avg. time-to-swap, impact on health-score delta.

5) Meal Discovery, Recipes & Meal-Score Integration  
   - User stories: As a user I can browse meals with per-serving nutrition and an aggregated meal health score; I can filter by score/diet.  
   - Acceptance criteria: Meal pages show nutrition, prep steps, cook time, ingredients with product links and meal score; filters for score threshold work.  
   - UI components: Meal card with score badge, recipe view with "Replace ingredient" actions.
   - Data / APIs: Meal object includes ingredients[] each linked to product/ingredient ids, aggregated_score; endpoints GET /meals, GET /meals/{id}.  
   - Priority: Must-have.  
   - Metrics: conversion from discovery to add-to-plan, effect of score on selection.

6) Grocery & Shopping Lists + Retail Integrations (Compare & Buy)  
   - User stories: As a user I can add scanned products or recipe ingredients to a shopping list and optionally compare prices or purchase via partners.  
   - Acceptance criteria: Shopping list syncs across devices; “compare prices” shows partner pricing; deep-link or API-based add-to-cart works for partners.  
   - UI components: Shopping list with product cards, price-compare modal, partner checkout link.  
   - Data / APIs: Shopping-list service, partner integration layer (adapter pattern) supporting GET /partners/{id}/price?gtin=. OAuth storefront connectors for checkout flows.  
   - Priority: High.  
   - Metrics: add-to-cart via partner rate, average basket value, partner conversion.

7) Personalization & Nutrition Impact Tracking  
   - User stories: Users set diet goals and see cumulative impact (daily/weekly) of meals and scanned products.  
   - Acceptance criteria: Dashboard shows calories/macros per day, progress to goals, and aggregated health-score trends.  
   - UI components: Nutrition dashboard, goal setup wizard, timeline of health-score changes.  
   - Data / APIs: User nutrition log (consumed_items[], timestamps), goals API; endpoint GET /users/{id}/nutrition-summary.  
   - Priority: High.  
   - Metrics: DAU for dashboard, retention lift from personalization.

8) Scan History, Favorites, Crowdsourced Corrections & Moderation  
   - User stories: Keep a history of scans, allow bookmarking, and let users submit corrections (with moderation).  
   - Acceptance criteria: Users can access past scans, submit edits, and see moderation status. Admins can review and publish changes.  
   - UI components: Scan history list, report/edit form, moderation queue UI for admins.  
   - Data / APIs: scan_records table, change_requests table with state machine; endpoints: POST /product_edits, GET /moderation/queue.  
   - Priority: Medium.  
   - Metrics: edit submission volume, accuracy improvements post moderation, moderation SLA.

9) Trust, Transparency & Help (Methodology Docs)  
    - User stories: Users can understand how scores are computed and where data comes from.  
    - Acceptance criteria: Accessible methodology page that documents scoring logic, algorithm versions, and data sources. In-app changelog when scoring algorithm updates.  
    - UI components: Methodology docs page, in-product "why this score" links, version banner when algorithms change.  
    - Priority: Must-have (for credibility). 
    - Metrics: doc views, support tickets related to scoring.

10) Security, Privacy, Compliance & Logging  
    - Requirements: Biometric login, secure tokens (OAuth2 / JWT), encrypted PII, data retention policies, consent UI, audit logs for product edits.  
    - Acceptance criteria: Pen-test pass, GDPR/CCPA consent flows implemented, audit logs available in admin.  
    - Priority: Must-have.  
    - Metrics: security incidents, consent opt-in %, data access audit counts.

11) Admin, Analytics & Operational Tooling  
    - Needs: Admin UI for menu/product edits, moderation, DB health, analytics dashboard for product DB coverage, user engagement, feature adoption.  
    - Acceptance criteria: Admins can publish/unpublish products/meals, view moderation queue, run DB syncs, and view analytics KPIs.  
    - Priority: Must-have for ops.  
    - Metrics: time-to-publish, DB mismatch rate, admin actions per week.

Implementation notes / recommended architecture:
- Microservices: products, scores, meals, recommendations, orders, shopping-list, auth, moderation. Use message bus for async updates (score recalculation, DB sync).  
- Data pipeline: ingestion -> canonicalization -> dedupe -> enrichment (images, nutrition parsed) -> scoring. Keep provenance metadata for transparency.  
- Mobile: cross-platform React Native / Flutter; native modules for barcode scanning and camera. Local cache & offline-first sync for recipes and recent scans.  
- ML / Rules: Hybrid scoring — deterministic rules for known additives + ML model for nutrition weighting, with explainability layer.  
- Privacy: store minimal PII on device, allow export/delete, and keep consent logs.

Roadmap & phasing (suggested):
- Phase 1 (MVP, 3–6 months): Barcode scan, product DB basic, unified health score, meal discovery, shopping list, subscription & delivery core, authentication, methodology docs.  
- Phase 2 (6–12 months): Ingredient-level analysis, swap suggestions, retail partner integrations, personalized nutrition tracking, scan history & favorites.  
- Phase 3 (12+ months): Full crowdsourced DB workflows, advanced premium analytics, cosmetics scoring extension, family sync, global retailer integrations.

Use these specs to create implementation tickets, API contracts, and UI wireframes. If you want, I can convert any of the items above into GitHub issue templates, API contracts (OpenAPI), or example DB schemas next.