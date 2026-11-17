PRAGMA foreign_keys = ON;

-- One shared database for four cabinet configurations and all supplier offers.
CREATE TABLE IF NOT EXISTS cabinets (
    cabinet_id       INTEGER PRIMARY KEY,
    cabinet_code     TEXT NOT NULL UNIQUE,
    cabinet_name     TEXT NOT NULL,
    description      TEXT,
    active           INTEGER NOT NULL DEFAULT 1 CHECK (active IN (0, 1))
);

CREATE TABLE IF NOT EXISTS components (
    component_id     INTEGER PRIMARY KEY,
    component_code   TEXT UNIQUE,
    name             TEXT NOT NULL,
    manufacturer     TEXT,
    article          TEXT,
    normalized_key   TEXT UNIQUE,
    unit             TEXT NOT NULL DEFAULT 'шт',
    notes            TEXT
);

-- A component can occur in multiple cabinet types; quantity is per cabinet.
CREATE TABLE IF NOT EXISTS cabinet_components (
    cabinet_id       INTEGER NOT NULL REFERENCES cabinets(cabinet_id) ON DELETE CASCADE,
    component_id     INTEGER NOT NULL REFERENCES components(component_id) ON DELETE RESTRICT,
    quantity         REAL NOT NULL DEFAULT 1 CHECK (quantity > 0),
    PRIMARY KEY (cabinet_id, component_id)
);

CREATE TABLE IF NOT EXISTS suppliers (
    supplier_id      INTEGER PRIMARY KEY,
    supplier_code    TEXT NOT NULL UNIQUE,
    supplier_name    TEXT NOT NULL,
    base_url         TEXT NOT NULL,
    enabled          INTEGER NOT NULL DEFAULT 1 CHECK (enabled IN (0, 1))
);

-- Product records belong to a supplier. Their URLs and article numbers are
-- source-specific; matching to an internal component is stored separately.
CREATE TABLE IF NOT EXISTS supplier_products (
    product_id       INTEGER PRIMARY KEY,
    supplier_id      INTEGER NOT NULL REFERENCES suppliers(supplier_id) ON DELETE CASCADE,
    source_product_id TEXT,
    product_url      TEXT NOT NULL,
    title            TEXT NOT NULL,
    manufacturer     TEXT,
    article          TEXT,
    currency         TEXT NOT NULL DEFAULT 'RUB',
    active           INTEGER NOT NULL DEFAULT 1 CHECK (active IN (0, 1)),
    UNIQUE (supplier_id, product_url),
    UNIQUE (supplier_id, source_product_id)
);

-- Explicit mapping supports different vendor article formats and aliases.
CREATE TABLE IF NOT EXISTS component_product_matches (
    component_id     INTEGER NOT NULL REFERENCES components(component_id) ON DELETE CASCADE,
    product_id       INTEGER NOT NULL REFERENCES supplier_products(product_id) ON DELETE CASCADE,
    match_method     TEXT NOT NULL DEFAULT 'manual',
    confidence       REAL CHECK (confidence IS NULL OR (confidence >= 0 AND confidence <= 1)),
    verified         INTEGER NOT NULL DEFAULT 0 CHECK (verified IN (0, 1)),
    PRIMARY KEY (component_id, product_id)
);

-- Append-only daily observations make price changes auditable.
CREATE TABLE IF NOT EXISTS price_snapshots (
    snapshot_id      INTEGER PRIMARY KEY,
    product_id       INTEGER NOT NULL REFERENCES supplier_products(product_id) ON DELETE CASCADE,
    captured_at      TEXT NOT NULL,
    price            REAL CHECK (price IS NULL OR price >= 0),
    availability     TEXT NOT NULL DEFAULT 'unknown',
    stock_quantity   REAL CHECK (stock_quantity IS NULL OR stock_quantity >= 0),
    UNIQUE (product_id, captured_at)
);

CREATE INDEX IF NOT EXISTS idx_cabinet_components_component
    ON cabinet_components(component_id);
CREATE INDEX IF NOT EXISTS idx_component_matches_product
    ON component_product_matches(product_id);
CREATE INDEX IF NOT EXISTS idx_products_supplier_article
    ON supplier_products(supplier_id, article);
CREATE INDEX IF NOT EXISTS idx_snapshots_product_captured
    ON price_snapshots(product_id, captured_at DESC);

-- Seed the two supplier slots. Replace base_url values with the confirmed URLs.
INSERT OR IGNORE INTO suppliers (supplier_code, supplier_name, base_url)
VALUES ('rs24', 'RS24', 'https://rs24.ru'),
       ('supplier_2', 'Второй магазин', '');
