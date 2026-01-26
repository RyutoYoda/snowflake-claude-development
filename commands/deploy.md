# /deploy - Streamlit Deploy Safety Checks

## Critical Checks Before Deploy

1. **Connection verification** - Production environment?
2. **snowflake.yml validation** - query_warehouse, default_streamlit required
3. **--replace warning** - Overwrites existing app

## Common Failures

- `streamlit_app.py` missing → Check current directory
- `snowflake.yml` invalid → query_warehouse required
- Permission error → CREATE STREAMLIT privilege needed

## Deploy Command

```bash
cd APP_DIR
snow streamlit deploy --replace --connection CONNECTION
```

## Post-Deploy

Verify with `snow streamlit get-url APP_NAME`
