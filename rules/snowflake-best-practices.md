# Snowflake Rules - Always Follow

## Naming
- Always use fully qualified names: `DATABASE.SCHEMA.TABLE`
- Tables/Views: `UPPERCASE_WITH_UNDERSCORES`
- Base tables: `TABLE_NAME_BASE` (with timestamp columns)
- Views: `TABLE_NAME` (for apps, no timestamps)

## Safety
- SELECT * Prohibited in production, specify columns
- UPDATE/DELETE WHERE clause required, verify with SELECT first
- TRUNCATE/DROP Always confirm, check backup
- Production operations Execute /prod-check

## Performance
- LIMIT Always use in development
- Clustering keys For tables with 1M+ rows
- SHOW TABLES/VIEWS Verify object existence

## Security
- No hardcoded credentials
- Principle of least privilege
- PII Dynamic Data Masking/Row Access Policy
