# Hooks Scripts

Event-driven automation scripts for Snowflake development.

## streamlit-deploy.sh

Deploy Streamlit app with safety checks.

**Usage:**
```bash
./hooks/streamlit-deploy.sh [app-directory] [connection-name]

# Deploy from current directory
./hooks/streamlit-deploy.sh

# Deploy specific app
./hooks/streamlit-deploy.sh ./Streamlit/my-app

# Deploy with connection
./hooks/streamlit-deploy.sh ./Streamlit/my-app my_connection
```

**Safety Checks:**
- Verifies streamlit_app.py exists
- Verifies snowflake.yml exists
- Checks query_warehouse configuration
- Confirms before deployment (--replace flag)
- Displays app URL after deployment

## Other Scripts

Other .sh scripts are specific automation hooks.
See individual script headers for usage.
