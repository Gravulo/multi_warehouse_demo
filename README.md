# DBT Multi-Warehouse Demo

This is a complete dbt project demonstrating:

- Multi-warehouse support (Snowflake, Databricks, Redshift)
- Sources → Staging → Marts data flow
- Incremental models with optional time windows
- SCD2 snapshots
- Built-in dbt tests
- Cross-database macros

## Setup

1. **Install dbt and adapters:**
```bash
python -m venv .venv && source .venv/bin/activate
pip install dbt-core dbt-snowflake dbt-databricks dbt-redshift
```

2. **Configure profiles:**
```bash
# Copy the example profiles to your dbt directory
cp profiles_example.yml ~/.dbt/profiles.yml

# Set up environment variables
cp .env.example .env
# Edit .env with your actual credentials
source .env
```

3. **Test connection:**
```bash
dbt debug --target snowflake
```

## Usage

1. **Load seed data:**
```bash
dbt seed --target snowflake
```

2. **Build all models:**
```bash
dbt build --target snowflake
```

3. **Run incremental models with time windows:**
```bash
dbt run --target snowflake -s stg_orders fct_orders_daily \
  --vars 'run_start: 2024-03-01, run_end: 2024-03-31'
```

4. **Run snapshots:**
```bash
dbt snapshot --target snowflake
```

5. **Switch to different warehouse:**
```bash
dbt build --target databricks
# or
dbt build --target redshift
```

## Project Structure

- `models/sources/` - Source definitions
- `models/staging/` - Cleaned and typed raw data
- `models/marts/` - Business logic and dimensional models
- `snapshots/` - SCD2 implementation
- `seeds/` - Sample CSV data
- `macros/` - Reusable SQL functions
