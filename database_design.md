# Database Design (Logical & Physical Schema)
Meal Planner + Product Analysis (Hello Fresh + Yuka Unified)

## 1. Design Principles
- Normalize core catalog (Products, Ingredients, Meals)
- Versioned immutable scoring (score_algorithms + product_scores)
- Bounded contexts → logical schemas
- Soft deletes via deleted_at where needed
- Append-only logs (nutrition tracking, scan history, audit)
- Crowdsourced edits as JSON diffs with workflow
- Selective denormalization (aggregated meal score)
- PostgreSQL primary; Redis cache; Object storage for images
- Mobile offline mirror (Hive) with subset data

## 2. Bounded Contexts / Schemas
auth: users, user_preferences  
catalog: products, ingredients, product_ingredients, meals, meal_ingredients  
scoring: score_algorithms, product_scores  
nutrition: nutrition_logs, daily_nutrition_summaries  
crowdsourcing: product_edits  
activity: scan_history, favorites, meal_plan_weeks, meal_plan_slots, shopping_list_items  
reference: additives, additive_risks  
audit: events  

## 3. High-Level ER (Textual)
User (1)—(N) ScanHistory → Product  
User (1)—(N) NutritionLog (ref meal|product)  
User (1)—(N) Favorites (meal|product)  
User (1)—(N) MealPlanWeek (1)—(N) MealPlanSlot → Meal  
Meal (N)—(N) Ingredient via MealIngredient  
Product (N)—(N) Ingredient via ProductIngredient  
Product (1)—(N) ProductScore ← ScoreAlgorithm  
Product (1)—(N) ProductEdit (crowdsourced)  
Ingredient (0..1) → Additive (optional via additive_id)  
Additive (1)—(N) AdditiveRisk (region)  

## 4. Enumerations (PostgreSQL ENUMs)
score_component_type (nutrition, additives, processing)  
edit_status (pending, reviewing, approved, rejected)  
nutrition_ref_type (meal, product)  
favorite_type (meal, product)  
dietary_tag (vegan, vegetarian, pescatarian, gluten_free, dairy_free, low_sugar, low_salt, keto, paleo)  

## 5. Physical Schema (PostgreSQL DDL)
```sql
-- AUTH
CREATE TABLE auth.users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email CITEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  display_name TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  last_login_at TIMESTAMPTZ,
  deleted_at TIMESTAMPTZ
);

CREATE TABLE auth.user_preferences (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  dietary_tags dietary_tag[] DEFAULT '{}',
  locale TEXT DEFAULT 'en',
  timezone TEXT,
  marketing_opt_in BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  CONSTRAINT dietary_tags_unique CHECK (
    array_length(dietary_tags,1) IS NULL
    OR cardinality(dietary_tags) = (SELECT COUNT(DISTINCT unnest(dietary_tags)))
  )
);

-- CATALOG
CREATE TABLE catalog.ingredients (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  normalized_name TEXT GENERATED ALWAYS AS (lower(name)) STORED,
  additive_id UUID NULL,
  created_at TIMESTAMPTZ DEFAULT now()
);
CREATE INDEX idx_ingredients_norm_name ON catalog.ingredients(normalized_name);

CREATE TABLE catalog.products (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  gtin TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  brand TEXT,
  serving_size_grams NUMERIC(8,2),
  calories NUMERIC(8,2),
  protein_g NUMERIC(8,2),
  fat_g NUMERIC(8,2),
  carbs_g NUMERIC(8,2),
  fiber_g NUMERIC(8,2),
  sugar_g NUMERIC(8,2),
  sodium_mg NUMERIC(10,2),
  image_url TEXT,
  country_code CHAR(2),
  ingredients_text TEXT,
  updated_at TIMESTAMPTZ DEFAULT now(),
  created_at TIMESTAMPTZ DEFAULT now(),
  deleted_at TIMESTAMPTZ
);
CREATE INDEX idx_products_brand ON catalog.products(brand);
CREATE INDEX idx_products_country ON catalog.products(country_code);

CREATE TABLE catalog.product_ingredients (
  product_id UUID REFERENCES catalog.products(id) ON DELETE CASCADE,
  ingredient_id UUID REFERENCES catalog.ingredients(id) ON DELETE RESTRICT,
  position INT NOT NULL,
  quantity_text TEXT,
  PRIMARY KEY (product_id, ingredient_id)
);
CREATE INDEX idx_product_ingredients_position ON catalog.product_ingredients(product_id, position);

CREATE TABLE catalog.meals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT,
  prep_minutes INT,
  cook_minutes INT,
  servings INT,
  aggregated_score NUMERIC(5,2),
  image_url TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  deleted_at TIMESTAMPTZ
);

CREATE TABLE catalog.meal_ingredients (
  meal_id UUID REFERENCES catalog.meals(id) ON DELETE CASCADE,
  ingredient_id UUID REFERENCES catalog.ingredients(id) ON DELETE RESTRICT,
  quantity_text TEXT,
  position INT,
  PRIMARY KEY (meal_id, ingredient_id)
);

-- SCORING
CREATE TABLE scoring.score_algorithms (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  version INT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  description TEXT,
  released_at TIMESTAMPTZ DEFAULT now(),
  deprecated_at TIMESTAMPTZ
);

CREATE TABLE scoring.product_scores (
  product_id UUID REFERENCES catalog.products(id) ON DELETE CASCADE,
  algorithm_id UUID REFERENCES scoring.score_algorithms(id) ON DELETE CASCADE,
  total_score NUMERIC(5,2) CHECK (total_score BETWEEN 0 AND 100),
  nutrition_score NUMERIC(5,2),
  additive_penalty NUMERIC(5,2),
  processing_penalty NUMERIC(5,2),
  calculated_at TIMESTAMPTZ DEFAULT now(),
  PRIMARY KEY (product_id, algorithm_id)
);
CREATE INDEX idx_product_scores_total ON scoring.product_scores(total_score);

-- REFERENCE
CREATE TABLE reference.additives (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  category TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE reference.additive_risks (
  additive_id UUID REFERENCES reference.additives(id) ON DELETE CASCADE,
  region_code TEXT,
  severity INT CHECK (severity BETWEEN 0 AND 5),
  description TEXT,
  source_url TEXT,
  updated_at TIMESTAMPTZ DEFAULT now(),
  PRIMARY KEY (additive_id, region_code)
);

-- ACTIVITY
CREATE TABLE activity.scan_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  product_id UUID REFERENCES catalog.products(id) ON DELETE CASCADE,
  scanned_at TIMESTAMPTZ DEFAULT now()
);
CREATE INDEX idx_scan_history_user_time ON activity.scan_history(user_id, scanned_at DESC);

CREATE TABLE activity.favorites (
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  favorite_type favorite_type NOT NULL,
  ref_id UUID NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now(),
  PRIMARY KEY (user_id, favorite_type, ref_id)
);
CREATE INDEX idx_favorites_products ON activity.favorites(ref_id) WHERE favorite_type='product';

CREATE TABLE activity.meal_plan_weeks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  iso_week INT NOT NULL,
  iso_year INT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE (user_id, iso_year, iso_week)
);

CREATE TABLE activity.meal_plan_slots (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  meal_plan_week_id UUID REFERENCES activity.meal_plan_weeks(id) ON DELETE CASCADE,
  day_of_week INT CHECK (day_of_week BETWEEN 1 AND 7),
  meal_time TEXT CHECK (meal_time IN ('breakfast','lunch','dinner','snack')),
  meal_id UUID REFERENCES catalog.meals(id) ON DELETE SET NULL,
  position INT DEFAULT 0
);
CREATE INDEX idx_meal_plan_slots_week ON activity.meal_plan_slots(meal_plan_week_id);

CREATE TABLE activity.shopping_list_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  product_id UUID REFERENCES catalog.products(id),
  ingredient_id UUID REFERENCES catalog.ingredients(id),
  source_meal_id UUID REFERENCES catalog.meals(id),
  description TEXT,
  quantity_text TEXT,
  acquired BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT now(),
  CHECK ((product_id IS NOT NULL)::int + (ingredient_id IS NOT NULL)::int = 1)
);
CREATE INDEX idx_shopping_list_user ON activity.shopping_list_items(user_id, acquired);

-- NUTRITION
CREATE TABLE nutrition.nutrition_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  ref_type nutrition_ref_type NOT NULL,
  ref_id UUID NOT NULL,
  consumed_at TIMESTAMPTZ DEFAULT now(),
  calories NUMERIC(8,2),
  protein_g NUMERIC(8,2),
  fat_g NUMERIC(8,2),
  carbs_g NUMERIC(8,2),
  fiber_g NUMERIC(8,2),
  sugar_g NUMERIC(8,2),
  sodium_mg NUMERIC(10,2),
  score_value NUMERIC(5,2)
);
CREATE INDEX idx_nutrition_logs_user_time ON nutrition.nutrition_logs(user_id, consumed_at DESC);

CREATE TABLE nutrition.daily_nutrition_summaries (
  user_id UUID,
  date DATE,
  calories NUMERIC(10,2),
  protein_g NUMERIC(10,2),
  fat_g NUMERIC(10,2),
  carbs_g NUMERIC(10,2),
  fiber_g NUMERIC(10,2),
  sugar_g NUMERIC(10,2),
  sodium_mg NUMERIC(10,2),
  avg_score NUMERIC(5,2),
  PRIMARY KEY (user_id, date)
);

-- CROWDSOURCING
CREATE TABLE crowdsourcing.product_edits (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id UUID REFERENCES catalog.products(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  status edit_status DEFAULT 'pending',
  proposed_changes JSONB NOT NULL,
  reviewer_id UUID REFERENCES auth.users(id),
  reviewed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);
CREATE INDEX idx_product_edits_product ON crowdsourcing.product_edits(product_id);
CREATE INDEX idx_product_edits_status ON crowdsourcing.product_edits(status);

-- AUDIT
CREATE TABLE audit.events (
  id BIGSERIAL PRIMARY KEY,
  occurred_at TIMESTAMPTZ DEFAULT now(),
  actor_user_id UUID,
  entity_type TEXT,
  entity_id UUID,
  action TEXT,
  metadata JSONB
);

-- DATA INTEGRITY
ALTER TABLE catalog.product_ingredients
  ADD CONSTRAINT product_ingredients_position_positive CHECK (position >= 0);
ALTER TABLE catalog.meal_ingredients
  ADD CONSTRAINT meal_ingredients_position_positive CHECK (position >= 0);

-- FULL TEXT SEARCH
ALTER TABLE catalog.products ADD COLUMN search_vector tsvector;
CREATE INDEX idx_products_fts ON catalog.products USING GIN(search_vector);
CREATE FUNCTION catalog.products_fts_trigger() RETURNS trigger AS $$
BEGIN
  NEW.search_vector :=
    setweight(to_tsvector('simple', coalesce(NEW.name,'')), 'A') ||
    setweight(to_tsvector('simple', coalesce(NEW.brand,'')), 'B');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER trg_products_fts BEFORE INSERT OR UPDATE
  ON catalog.products FOR EACH ROW EXECUTE PROCEDURE catalog.products_fts_trigger();
```

## 6. Indexing Strategy
- GTIN lookup (unique) for scan
- product_scores(total_score) for ranking
- scan_history(user_id, scanned_at DESC) recent queries
- nutrition_logs(user_id, consumed_at DESC) summaries
- product_edits(status) moderation queue
- FTS GIN on products.name/brand

## 7. Caching & Denormalization
Redis keys:
- product:{gtin}, score:{product_id}:{algo_version}, meal:agg:{meal_id}
Denormalized:
- meals.aggregated_score updated async after ingredient/product score changes
Materialized:
- daily_nutrition_summaries refreshed incrementally

## 8. Data Retention
| Table | Retention |
|-------|-----------|
| scan_history | 12 months (archive) |
| nutrition_logs | 24 months |
| product_edits | Permanent |
| audit.events | 18 months |

## 9. Mobile Hive Subset
| Box | Fields |
|-----|--------|
| products_box | id, gtin, name, macros, score, updated_at |
| scan_history_box | product_id, scanned_at |
| meal_plan_box | week, slots[] |
| nutrition_log_box | entry_id, date, nutrients |
| favorites_box | ref_type, ref_id |
| algorithm_meta_box | version, released_at |

Refresh rules: product older than 7d or score algorithm version mismatch triggers fetch.

## 10. Referential & Business Rules
- One product_score per (product, algorithm)
- New algorithm → insert row (no mutation)
- Ingredient deletion blocked if referenced
- product_edits.proposed_changes validated server-side (allowed keys)
- nutrition_logs polymorphic ref validated by app logic + periodic integrity job

## 11. Key Queries
```sql
-- Scan lookup
SELECT p.id, p.gtin, p.name, ps.total_score
FROM catalog.products p
JOIN scoring.product_scores ps ON ps.product_id = p.id
JOIN scoring.score_algorithms a ON a.id = ps.algorithm_id
WHERE p.gtin = $1 AND a.version = $2;

-- Daily nutrition summary (ad-hoc)
SELECT date_trunc('day', consumed_at) AS day,
       SUM(calories) calories,
       AVG(score_value) avg_score
FROM nutrition.nutrition_logs
WHERE user_id = $1
GROUP BY day
ORDER BY day DESC
LIMIT 30;
```

## 12. Migration & Versioning
- Timestamped SQL migrations per schema
- Score algorithm change = new version row + batch job
- Backfill progress logged in audit.events (action='backfill_score')

## 13. Security
- Separate DB roles (rw, ro, analytics)
- Optional RLS on activity.* (user_id = current_user)
- Audit sensitive writes
- No PII in FTS vector

## 14. Scaling
- Partition large append tables (scan_history, nutrition_logs) by month when >50M rows
- Read replicas for analytics
- Partial indexes for active moderation (status IN ('pending','reviewing'))

## 15. Future Extensions
- product_images table (multiple)
- price_offers (retailer integration)
- personalized_score_adjustments (user-specific deltas)
- trigger-based incremental meal score recalculator with diff detection

## 16. ER Diagram (Text Outline)
[User]──<scan_history>──[Product]──<product_scores>──[ScoreAlgorithm]  
[Product]──<product_ingredients>──[Ingredient]──(opt)→[Additive]──<additive_risks>  
[Meal]──<meal_ingredients>──[Ingredient]  
[User]──<meal_plan_weeks>──<meal_plan_slots>→[Meal]  
[User]──<nutrition_logs>(meal|product)  
[User]──<favorites>(meal|product)  
[Product]──<product_edits>(User)  
