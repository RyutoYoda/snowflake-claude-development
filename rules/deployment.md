# Deployment Rules - Critical Checks

## Streamlit Deploy
- snowflake.yml query_warehouse required
- streamlit_app.py Must exist in current directory
- --replace Overwrites existing app, confirm required

## UDF/Stored Procedure Deploy
- snowflake.yml stage, handler configuration check
- Test Always run in dev environment before production

## Task Deploy
- Schedule Verify timezone (UTC recommended)
- Dependencies Confirm DAG order
- Initial execution Create in SUSPEND state, RESUME after verification

## Rollback Plan
- Always keep previous version
- Verify rollback procedure in advance
