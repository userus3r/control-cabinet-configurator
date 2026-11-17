SQLite database from three source files.
{
  "cabinets": 4,
  "components": 79,
  "cabinet_components": 44,
  "categories": 6,
  "source_records": 155
}

Tables are normalized: cabinets, components, categories; many-to-many relationships use cabinet_components and component_categories. Original source rows and notes are retained in source_records. Sources are in source_files.
Unknown quantities are NULL: package quantities in descriptions were not treated as cabinet requirements. Accessory compatibility with cabinets was not invented. Exact trimmed articles are used for deduplication; uncertain compound articles are preserved literally. Names without article are matched only by identical normalized name.
Different source descriptions are preserved; canonical name is the first encountered. Sources have no prices.
Queries:
SELECT * FROM v_cabinet_composition;
SELECT * FROM v_accessories;
SELECT * FROM source_records WHERE notes <> '';

Integrity check: ok; foreign key check: no violations.
