# Snowflake Development with Claude Code

This repository provides Claude Code skills for Snowflake development using the `snow` CLI.

## Quick Start

### 1. Install Snowflake CLI

```bash
# Using Homebrew (macOS)
brew install snowflake-cli

# Using pip
pip install snowflake-cli-labs

# Verify installation
snow --version
```

### 2. Configure Connection

Create `~/.snowflake/config.toml`:

```toml
[connections.your_connection_name]
account = "YOUR_ACCOUNT_IDENTIFIER"
user = "YOUR_USERNAME"
authenticator = "externalbrowser"
role = "YOUR_ROLE"
warehouse = "YOUR_WAREHOUSE"
database = "YOUR_DATABASE"
schema = "YOUR_SCHEMA"
```

Test connection:
```bash
snow connection test --connection your_connection_name
```

## Development Workflow

### Data Transformation
Use dbt for data modeling and transformation. Snowflake is for application layer only.

### Application Development

1. **Streamlit apps** - UI/BI applications
2. **Python UDFs** - Business logic in Python
3. **Tasks** - Scheduled automation
4. **Analysis** - Ad-hoc notebooks

### Project Structure
```
snowflake-claude-development/
├── skills/      # Claude workflows
├── commands/    # Safety guardrails
├── agents/      # Specialized reviewers
├── rules/       # Best practices
└── hooks/       # Automations
```

## Available Skills

Claude Code automatically activates these skills when needed:

### 1. `streamlit-deploy`
Deploy and manage Streamlit apps on Snowflake.

**Usage:**
- "Deploy this Streamlit app"
- "Get the URL for my app"

### 2. `snowflake-cli-operations`
Execute SQL, create tables/views, manage database objects using `snow` CLI.

**Usage:**
- "Run this SQL query"
- "Create a table for user data"
- "Show tables in this schema"

### 3. `notebook-ops`
Jupyter notebook patterns for data analysis with Snowpark.

**Usage:**
- "Create a notebook to analyze this data"
- "Query Snowflake data in a notebook"

## Development Tips

- Always use qualified table names: `DATABASE.SCHEMA.TABLE`
- Follow naming conventions: `UPPERCASE_WITH_UNDERSCORES` for database objects
- Test queries with `LIMIT` before running on full datasets
- Use views to decouple applications from table structures
- Keep resource folders independent and self-contained

## Getting Help

For detailed documentation on each skill, see:
- `skills/streamlit-deploy/SKILL.md`
- `skills/snowflake-cli-operations/SKILL.md`
- `skills/notebook-ops/SKILL.md`
