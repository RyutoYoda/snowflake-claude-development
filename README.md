# Snowflake AI-Driven Development with Claude Code

Production-ready Claude Code Skills for Snowflake development. Accelerate your Snowflake, Streamlit, and data engineering workflows with AI assistance.

## Overview

This repository contains specialized Skills for Claude Code that enable AI-driven development for Snowflake projects. These Skills provide structured workflows, best practices, and automated patterns for common Snowflake development tasks.

## What's Included

### Skills (`.claude/skills/`)

- **snowflake-mcp** - Direct Snowflake database operations via MCP
- **streamlit-deploy** - Streamlit app deployment and configuration
- **notebook-ops** - Jupyter notebook patterns for data analysis

### Documentation

- **HOW_TO_CREATE_SKILLS.md** - Comprehensive guide to creating custom Skills for any tech stack

## Quick Start

### 1. Install Claude Code

```bash
# Install Claude Code CLI
npm install -g @anthropic/claude-code

# Or visit https://claude.ai/download
```

### 2. Copy Skills to Your Project

**Option A: Project-specific (Recommended)**

```bash
# Copy to your Snowflake project
cp -r .claude your-snowflake-project/
```

**Option B: Global (All projects)**

```bash
# Copy to home directory
cp -r .claude ~/.claude/
```

### 3. Configure Snowflake MCP (Required)

The Snowflake MCP Skill requires a configured MCP server. See [MCP Setup](#mcp-setup) below.

### 4. Start Using Claude Code

```bash
cd your-snowflake-project
claude

# Try asking:
# - "Deploy my Streamlit app"
# - "Query the user table in Snowflake"
# - "Create a view-based architecture for my tables"
```

## Skills Documentation

### Snowflake MCP Skill

Execute Snowflake operations directly using Model Context Protocol.

**Use when:**
- Running SQL queries
- Creating/modifying tables and views
- Loading data
- Inspecting database schema

**Key Features:**
- Test Snowflake connections
- Execute any SQL operation
- View-based architecture patterns
- Proper NULL handling and date formatting
- SQL injection prevention

**Example:**
```
User: "Create a new table called USERS with ID and EMAIL columns"
Claude: Uses Snowflake MCP Skill to create the table with proper SQL
```

### Streamlit Deploy Skill

Deploy and manage Streamlit applications on Snowflake.

**Use when:**
- Deploying new Streamlit apps
- Updating existing apps
- Troubleshooting deployment errors
- Validating configuration files

**Key Features:**
- Validates `snowflake.yml` and `environment.yml`
- Handles common deployment errors
- Provides deployment best practices
- Post-deployment verification

**Common Issues Solved:**
- Python version wildcards (`python=3.11.*`)
- Package trailing equals (`pandas=`)
- `pages_dir` configuration errors

### Notebook Operations Skill

Jupyter notebook patterns for Snowflake data analysis.

**Use when:**
- Analyzing Snowflake data
- Creating data visualizations
- Performing exploratory data analysis
- Writing results back to Snowflake

**Key Features:**
- Snowpark connection patterns
- Data querying and transformation
- Pandas integration
- Visualization examples

## MCP Setup

### Snowflake MCP Server

The Snowflake MCP Skill requires the `snowflake-simple` MCP server.

#### Configuration

Add to your `~/.claude.json` (or project `.claude/settings.json`):

```json
{
  "mcpServers": {
    "snowflake-simple": {
      "type": "stdio",
      "command": "path/to/snowflake-mcp-server",
      "env": {
        "SNOWFLAKE_ACCOUNT": "your-account",
        "SNOWFLAKE_USER": "your-username",
        "SNOWFLAKE_PASSWORD": "your-password",
        "SNOWFLAKE_WAREHOUSE": "your-warehouse",
        "SNOWFLAKE_DATABASE": "your-database",
        "SNOWFLAKE_SCHEMA": "your-schema"
      }
    }
  }
}
```

#### Using Docker

```bash
claude mcp add snowflake-simple -s project -- docker run -i --rm your-snowflake-mcp-image
```

#### Environment Variables

Alternatively, set environment variables:

```bash
export SNOWFLAKE_ACCOUNT=your-account
export SNOWFLAKE_USER=your-username
export SNOWFLAKE_PASSWORD=your-password
export SNOWFLAKE_WAREHOUSE=your-warehouse
export SNOWFLAKE_DATABASE=your-database
export SNOWFLAKE_SCHEMA=your-schema
```

## Project Structure

```
your-snowflake-project/
├── .claude/
│   ├── skills/
│   │   ├── snowflake-mcp/
│   │   │   └── SKILL.md
│   │   ├── streamlit-deploy/
│   │   │   └── SKILL.md
│   │   └── notebook-ops/
│   │       └── SKILL.md
│   └── settings.json (optional - for project-specific MCP config)
├── Streamlit/
│   └── your-app/
│       ├── streamlit_app.py
│       ├── snowflake.yml
│       └── environment.yml
├── notebooks/
│   └── analysis.ipynb
└── README.md
```

## Best Practices

### Database Operations

1. **Use Qualified Names**
   ```sql
   -- Good
   SELECT * FROM DATABASE.SCHEMA.TABLE

   -- Avoid
   SELECT * FROM TABLE
   ```

2. **View-Based Architecture**
   ```sql
   -- Base table with metadata
   CREATE TABLE SCHEMA.DATA_BASE (
     ID VARCHAR(50),
     NAME VARCHAR(100),
     CREATED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
   );

   -- Application view (clean interface)
   CREATE VIEW SCHEMA.DATA AS
   SELECT ID, NAME FROM SCHEMA.DATA_BASE;
   ```

3. **Escape String Values**
   ```python
   # Always escape single quotes
   safe_value = user_input.replace("'", "''")
   query = f"INSERT INTO TABLE (COL) VALUES ('{safe_value}')"
   ```

### Streamlit Deployment

1. **Python Version**
   ```yaml
   # Always use wildcard
   dependencies:
     - python=3.11.*
   ```

2. **Package Format**
   ```yaml
   # Always end with =
   dependencies:
     - pandas=
     - streamlit=
   ```

3. **Avoid Common Errors**
   - Remove `pages_dir: null` from `snowflake.yml`
   - Use only Snowflake conda channel packages
   - Test locally before deploying

## Examples

### Example 1: Create and Query Table

```
User: Create a table called CUSTOMERS with ID, NAME, and EMAIL columns,
      then insert 3 sample records and query them.

Claude:
1. Uses Snowflake MCP to create table
2. Inserts sample data
3. Queries and displays results
```

### Example 2: Deploy Streamlit App

```
User: Deploy my Streamlit app to Snowflake

Claude:
1. Validates snowflake.yml and environment.yml
2. Checks for common configuration errors
3. Executes deployment with snow CLI
4. Provides app URL
```

### Example 3: Data Analysis

```
User: Analyze the sales data from the last 30 days and create a visualization

Claude:
1. Queries Snowflake for sales data
2. Performs aggregation and analysis
3. Creates visualization with pandas/matplotlib
4. Optionally saves results back to Snowflake
```

## Customization

### Adding Your Own Skills

1. Create a new directory in `.claude/skills/`
2. Add a `SKILL.md` file with your workflow
3. Follow the format in existing Skills

See [HOW_TO_CREATE_SKILLS.md](./HOW_TO_CREATE_SKILLS.md) for detailed instructions.

### Project-Specific Configuration

Create `.claude/CLAUDE.md` in your project:

```markdown
# Your Project Name

Project description and context for Claude

## Database Information

- Database: YOUR_DATABASE
- Schema: YOUR_SCHEMA
- Key Tables: LIST_YOUR_TABLES

## Project-Specific Rules

- Use specific naming conventions
- Follow company security policies
- etc.
```

## Performance Tips

### Context Window Management

- Enable only necessary MCP servers (10 or fewer per project)
- Too many MCPs shrink context from 200k to ~70k tokens
- Use project-specific MCP configuration

### Recommended MCP Setup

**Snowflake Projects:**
- snowflake-simple (required)
- dbt (if using dbt)
- github (optional, for git operations)

**Avoid:**
- Disable unused MCP servers
- Remove irrelevant Skills from large projects

## Troubleshooting

### Snowflake MCP Connection Issues

```bash
# Test connection
mcp__snowflake-simple__test_connection()

# Check environment variables
echo $SNOWFLAKE_ACCOUNT
echo $SNOWFLAKE_USER
```

### Streamlit Deployment Errors

Common fixes:
1. Python version: Change to `python=3.11.*`
2. Packages: Add trailing `=` (e.g., `pandas=`)
3. Remove `pages_dir` from snowflake.yml
4. Verify connection: `snow connection list`

### Claude Not Using Skills

1. Verify Skills are in `.claude/skills/` directory
2. Check file name is `SKILL.md`
3. Restart Claude Code
4. Try explicitly mentioning the task (e.g., "Deploy Streamlit app")

## Contributing

Contributions welcome! Please:

1. Follow existing Skill format
2. Test Skills before submitting
3. Remove any company-specific or sensitive information
4. Update README with new Skills

## Resources

- [Claude Code Documentation](https://docs.anthropic.com/claude/docs/claude-code)
- [Snowflake CLI Documentation](https://docs.snowflake.com/en/developer-guide/snowflake-cli-v2/index)
- [Streamlit on Snowflake](https://docs.snowflake.com/en/developer-guide/streamlit/about-streamlit)
- [MCP Protocol](https://modelcontextprotocol.io/)

## License

MIT License - Feel free to use and modify for your projects.

## Acknowledgments

Inspired by [everything-claude-code](https://github.com/affaan-m/everything-claude-code) - Anthropic Hackathon Winner

---

**Happy AI-driven Snowflake development!**
