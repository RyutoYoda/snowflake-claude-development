# /prod-check - Production Operation Guard

## Critical Operations Requiring Confirmation

### 1. DROP TABLE/VIEW
```sql
DROP TABLE IF EXISTS PRODUCTION.SCHEMA.TABLE;
```
**Confirm**: Table name, environment, backup status

### 2. TRUNCATE
```sql
TRUNCATE TABLE PRODUCTION.SCHEMA.TABLE;
```
**Confirm**: Irreversible, consider DELETE instead

### 3. UPDATE/DELETE (No WHERE clause)
```sql
DELETE FROM TABLE;  -- Dangerous
UPDATE TABLE SET ...; -- Dangerous
```
**Confirm**: WHERE clause required, verify impact with SELECT first

### 4. GRANT ALL
```sql
GRANT ALL ON SCHEMA TO ROLE;
```
**Confirm**: Principle of least privilege

## Checklist

- [ ] Production environment operation?
- [ ] Backup completed?
- [ ] WHERE clause correct? (UPDATE/DELETE)
- [ ] Impact scope verified?
- [ ] Rollback method ready?
