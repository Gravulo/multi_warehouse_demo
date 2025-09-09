# DBT for Software Architects: A Complete Guide

## Table of Contents
1. [What is DBT and Why Does it Matter?](#what-is-dbt-and-why-does-it-matter)
2. [Core Concepts for Software Architects](#core-concepts-for-software-architects)
3. [Project Architecture Overview](#project-architecture-overview)
4. [Hands-On Demo Walkthrough](#hands-on-demo-walkthrough)
5. [Command Reference and Outputs](#command-reference-and-outputs)
6. [Best Practices and Patterns](#best-practices-and-patterns)
7. [Integration with Modern Data Stack](#integration-with-modern-data-stack)

---

## What is DBT and Why Does it Matter?

**DBT (Data Build Tool)** is fundamentally a **transformation layer** that sits between raw data and business intelligence tools. Think of it as the "application layer" for your data warehouse.

### For Software Architects: The Analogy

If you think of your data warehouse as a database, then:
- **Raw data** = Your source tables (like microservice databases)
- **DBT models** = Your application logic and API layer
- **BI Tools** = Your frontend/client applications

### Key Value Propositions

1. **Version Control for Data Logic**: All transformations are code, stored in Git
2. **Testing & Quality Assurance**: Built-in testing framework for data quality
3. **Documentation**: Auto-generated lineage and documentation
4. **Modularity**: Reusable components and clear separation of concerns
5. **CI/CD Ready**: Fits naturally into software engineering workflows

### The Problem DBT Solves

**Before DBT**: Data transformations scattered across:
- Stored procedures in databases
- ETL tools with GUI-based logic
- Jupyter notebooks
- Ad-hoc SQL scripts

**With DBT**: All transformation logic in version-controlled, testable, documentable SQL files.

---

## Core Concepts for Software Architects

### 1. Models = Functions/Classes
Each DBT model is like a function that takes inputs (other models or raw tables) and produces an output (a table/view).

```sql
-- This is like a function: dim_customers(stg_users, stg_orders) -> dim_customers_table
select
  u.user_id,
  u.email,
  count(o.order_id) as total_orders
from {{ ref('stg_users') }} u  -- Input dependency
left join {{ ref('stg_orders') }} o on u.user_id = o.user_id
group by u.user_id, u.email
```

### 2. Materialization = Deployment Strategy
- **View**: Like a computed property (recalculated each time)
- **Table**: Like cached data (materialized once)
- **Incremental**: Like event sourcing (append new records only)

### 3. Tests = Unit Tests + Integration Tests
```yaml
models:
  - name: dim_customers
    columns:
      - name: user_id
        tests: [unique, not_null]  # Unit tests
      - name: total_orders
        tests:
          - relationships:          # Integration test
              to: ref('stg_orders')
              field: user_id
```

### 4. Sources = External API Dependencies
```yaml
sources:
  - name: raw_data
    tables:
      - name: users
        description: "User data from our application database"
```

### 5. Macros = Utility Functions/Libraries
```sql
{% macro calculate_days_between(start_date, end_date) %}
  datediff('day', {{ start_date }}, {{ end_date }})
{% endmacro %}
```

---

## Project Architecture Overview

### Directory Structure (Similar to MVC Pattern)

```
dbt-multi-warehouse-demo/
├── dbt_project.yml           # Package.json equivalent
├── models/
│   ├── sources/              # External API definitions
│   │   └── sources.yml
│   ├── staging/              # Data Access Layer (DAL)
│   │   ├── stg_users.sql
│   │   ├── stg_orders.sql
│   │   └── staging.yml
│   └── marts/                # Business Logic Layer (BLL)
│       ├── dim_customers.sql
│       ├── fct_orders.sql
│       └── marts.yml
├── macros/                   # Shared utilities
│   └── date.sql
├── snapshots/                # Event sourcing / audit logs
│   └── customers_scd2.sql
└── seeds/                    # Test fixtures / reference data
    ├── raw_users.csv
    └── raw_orders.csv
```

### Data Flow Architecture

```
Raw Data Sources   →  Staging Layer   →   Business Logic Layer →  Analytics/BI
     (APIs)            (Clean/Type)       (Transform/Aggregate)    (Consume)
        ↓                 ↓                    ↓                  ↓
   raw_users.csv   →  stg_users.sql   →    dim_customers.sql  →  Tableau/PowerBI
   raw_orders.csv  →  stg_orders.sql  →    fct_orders.sql     →  Dashboards
```

### Layered Architecture Pattern

1. **Sources Layer**: External system interfaces
2. **Staging Layer**: Data cleansing and standardization
3. **Marts Layer**: Business logic and aggregations
4. **Consumption Layer**: BI tools and applications

---

## Hands-On Demo Walkthrough

This demo project simulates a typical e-commerce data pipeline with:
- **User management system** (users, profile changes)
- **Order management system** (orders, line items)
- **Analytics requirements** (customer dimensions, order facts, daily aggregates)

### Business Requirements Translated to DBT

1. **Customer 360 View**: `dim_customers.sql`
2. **Order Analytics**: `fct_orders.sql`
3. **Daily Revenue Tracking**: `fct_orders_daily.sql`
4. **Customer Profile History**: `customers_scd2.sql` (Slowly Changing Dimensions)

---

## Command Reference and Outputs

### 1. Project Setup and Validation

#### `dbt debug`
Tests connection and validates configuration.

**Command:**
```bash
dbt debug --target snowflake
```

**Expected Output:**
```
(.venv) austinabrahamanjiparambilhayis@Austins-MacBook-Air dbt-multi-warehouse-demo % dbt debug --target snowflake

16:59:56  Running with dbt=1.10.11
16:59:56  dbt version: 1.10.11
16:59:56  python version: 3.13.7
16:59:56  python path: /Users/austinabrahamanjiparambilhayis/Documents/repos/dbt-multi-warehouse-demo/.venv/bin/python3.13
16:59:56  os info: macOS-15.6.1-arm64-arm-64bit-Mach-O
16:59:57  Using profiles dir at /Users/austinabrahamanjiparambilhayis/.dbt
16:59:57  Using profiles.yml file at /Users/austinabrahamanjiparambilhayis/.dbt/profiles.yml
16:59:57  Using dbt_project.yml file at /Users/austinabrahamanjiparambilhayis/Documents/repos/dbt-multi-warehouse-demo/dbt_project.yml
16:59:57  adapter type: snowflake
16:59:57  adapter version: 1.10.2
16:59:57  Configuration:
16:59:57    profiles.yml file [OK found and valid]
16:59:57    dbt_project.yml file [OK found and valid]
16:59:57  Required dependencies:
16:59:57   - git [OK found]

16:59:57  Connection:
16:59:57    account: HAVPNFN-LD77838
16:59:57    user: AUSTIN
16:59:57    database: DBT_PROJECT
16:59:57    warehouse: COMPUTE_WH
16:59:57    role: ACCOUNTADMIN
16:59:57    schema: DEV
16:59:57    authenticator: None
16:59:57    oauth_client_id: None
16:59:57    query_tag: None
16:59:57    client_session_keep_alive: False
16:59:57    host: None
16:59:57    port: None
16:59:57    proxy_host: None
16:59:57    proxy_port: None
16:59:57    protocol: None
16:59:57    connect_retries: 1
16:59:57    connect_timeout: None
16:59:57    retry_on_database_errors: False
16:59:57    retry_all: False
16:59:57    insecure_mode: False
16:59:57    reuse_connections: True
16:59:57    s3_stage_vpce_dns_name: None
16:59:57  Registered adapter: snowflake=1.10.2
16:59:59    Connection test: [OK connection ok]

16:59:59  All checks passed!
```

---

### 2. Data Loading (Seed Command)

#### `dbt seed`
Loads CSV files into your data warehouse (like loading test fixtures).

**Command:**
```bash
dbt seed --target snowflake
```

**Expected Output:**
```
(.venv) austinabrahamanjiparambilhayis@Austins-MacBook-Air dbt-multi-warehouse-demo % dbt seed --target snowflake

17:21:33  Running with dbt=1.10.11
17:21:33  Registered adapter: snowflake=1.10.2
17:21:34  Unable to do partial parsing because profile has changed
17:21:35  [WARNING][MissingArgumentsPropertyInGenericTestDeprecation]: Deprecated
functionality
Found top-level arguments to test `accepted_values`. Arguments to generic tests
should be nested under the `arguments` property.`
17:21:35  Found 6 models, 1 snapshot, 4 seeds, 14 data tests, 4 sources, 480 macros
17:21:35  
17:21:35  Concurrency: 1 threads (target='snowflake')
17:21:35  
17:21:36  1 of 4 START seed file ANALYTICS.raw_order_items ............................... [RUN]
17:21:39  1 of 4 OK loaded seed file ANALYTICS.raw_order_items ........................... [INSERT 8 in 2.59s]
17:21:39  2 of 4 START seed file ANALYTICS.raw_orders .................................... [RUN]
17:21:40  2 of 4 OK loaded seed file ANALYTICS.raw_orders ................................ [INSERT 5 in 1.52s]
17:21:40  3 of 4 START seed file ANALYTICS.raw_users ..................................... [RUN]
17:21:42  3 of 4 OK loaded seed file ANALYTICS.raw_users ................................. [INSERT 5 in 1.24s]
17:21:42  4 of 4 START seed file ANALYTICS.raw_users_changes ............................. [RUN]
17:21:43  4 of 4 OK loaded seed file ANALYTICS.raw_users_changes ......................... [INSERT 7 in 1.43s]
17:21:43  
17:21:43  Finished running 4 seeds in 0 hours 0 minutes and 8.05 seconds (8.05s).
17:21:43  
17:21:43  Completed successfully
17:21:43  
17:21:43  Done. PASS=4 WARN=0 ERROR=0 SKIP=0 NO-OP=0 TOTAL=4
17:21:43  [WARNING][DeprecationsSummary]: Deprecated functionality
Summary of encountered deprecations:
- MissingArgumentsPropertyInGenericTestDeprecation: 2 occurrences
To see all deprecation instances instead of just the first occurrence of each,
run command again with the `--show-all-deprecations` flag. You may also need to
run with `--no-partial-parse` as some deprecations are only encountered during
parsing.
```

**What happened architecturally:**
- DBT read CSV files from `seeds/` directory
- Created corresponding tables in target schema
- This is equivalent to loading reference data or test fixtures

---

### 3. Model Compilation (Parse Command)

#### `dbt parse`
Compiles Jinja templates and validates model dependencies.

**Command:**
```bash
dbt parse
```

**Expected Output:**
```
(.venv) austinabrahamanjiparambilhayis@Austins-MacBook-Air dbt-multi-warehouse-demo % dbt parse

17:22:20  Running with dbt=1.10.11
17:22:20  Registered adapter: snowflake=1.10.2
17:22:20  Unable to do partial parsing because config vars, config profile, or config target have changed
17:22:21  [WARNING][MissingArgumentsPropertyInGenericTestDeprecation]: Deprecated
functionality
Found top-level arguments to test `accepted_values`. Arguments to generic tests
should be nested under the `arguments` property.`
17:22:22  Performance info: /Users/austinabrahamanjiparambilhayis/Documents/repos/dbt-multi-warehouse-demo/target/perf_info.json
17:22:22  [WARNING][DeprecationsSummary]: Deprecated functionality
Summary of encountered deprecations:
- MissingArgumentsPropertyInGenericTestDeprecation: 2 occurrences
To see all deprecation instances instead of just the first occurrence of each,
run command again with the `--show-all-deprecations` flag. You may also need to
run with `--no-partial-parse` as some deprecations are only encountered during
parsing.
```

---

### 4. Building the Entire Project

#### `dbt build`
Runs models, tests, and snapshots in dependency order.

**Command:**
```bash
dbt build --target snowflake
```

**Expected Output:**
```
(.venv) austinabrahamanjiparambilhayis@Austins-MacBook-Air dbt-multi-warehouse-demo % dbt build --target snowflake

17:27:57  Running with dbt=1.10.11
17:27:58  Registered adapter: snowflake=1.10.2
17:27:58  [WARNING][MissingArgumentsPropertyInGenericTestDeprecation]: Deprecated
functionality
Found top-level arguments to test `relationships`. Arguments to generic tests
should be nested under the `arguments` property.`
17:27:58  Found 6 models, 1 snapshot, 4 seeds, 14 data tests, 4 sources, 480 macros
17:27:58  
17:27:58  Concurrency: 1 threads (target='snowflake')
17:27:58  
17:28:00  1 of 25 START sql view model ANALYTICS.stg_order_items ......................... [RUN]
17:28:00  1 of 25 OK created sql view model ANALYTICS.stg_order_items .................... [SUCCESS 1 in 0.27s]
17:28:00  2 of 25 START sql incremental model ANALYTICS.stg_orders ....................... [RUN]
17:28:02  2 of 25 OK created sql incremental model ANALYTICS.stg_orders .................. [SUCCESS 0 in 2.16s]
17:28:02  3 of 25 START sql view model ANALYTICS.stg_users ............................... [RUN]
17:28:02  3 of 25 OK created sql view model ANALYTICS.stg_users .......................... [SUCCESS 1 in 0.18s]
17:28:02  4 of 25 START seed file ANALYTICS.raw_order_items .............................. [RUN]
17:28:04  4 of 25 OK loaded seed file ANALYTICS.raw_order_items .......................... [INSERT 8 in 1.64s]
17:28:04  5 of 25 START seed file ANALYTICS.raw_orders ................................... [RUN]
17:28:06  5 of 25 OK loaded seed file ANALYTICS.raw_orders ............................... [INSERT 5 in 1.73s]
17:28:06  6 of 25 START seed file ANALYTICS.raw_users .................................... [RUN]
17:28:07  6 of 25 OK loaded seed file ANALYTICS.raw_users ................................ [INSERT 5 in 1.36s]
17:28:07  7 of 25 START seed file ANALYTICS.raw_users_changes ............................ [RUN]
17:28:08  7 of 25 OK loaded seed file ANALYTICS.raw_users_changes ........................ [INSERT 7 in 1.19s]
17:28:08  8 of 25 START snapshot analytics_snapshots.customers_scd2 ...................... [RUN]
17:28:11  8 of 25 OK snapshotted analytics_snapshots.customers_scd2 ...................... [SUCCESS 2 in 3.08s]
17:28:11  9 of 25 START test not_null_stg_order_items_order_id ........................... [RUN]
17:28:12  9 of 25 PASS not_null_stg_order_items_order_id ................................. [PASS in 0.19s]
17:28:12  10 of 25 START test not_null_stg_order_items_qty ............................... [RUN]
17:28:12  10 of 25 PASS not_null_stg_order_items_qty ..................................... [PASS in 0.22s]
17:28:12  11 of 25 START test accepted_values_stg_orders_status__completed__cancelled .... [RUN]
17:28:12  11 of 25 PASS accepted_values_stg_orders_status__completed__cancelled .......... [PASS in 0.59s]
17:28:12  12 of 25 START test not_null_stg_orders_order_id ............................... [RUN]
17:28:12  12 of 25 PASS not_null_stg_orders_order_id ..................................... [PASS in 0.15s]
17:28:12  13 of 25 START test not_null_stg_orders_user_id ................................ [RUN]
17:28:13  13 of 25 PASS not_null_stg_orders_user_id ...................................... [PASS in 0.43s]
17:28:13  14 of 25 START test relationships_stg_order_items_order_id__order_id__ref_stg_orders_  [RUN]
17:28:13  14 of 25 PASS relationships_stg_order_items_order_id__order_id__ref_stg_orders_  [PASS in 0.22s]
17:28:13  15 of 25 START test unique_stg_orders_order_id ................................. [RUN]
17:28:13  15 of 25 PASS unique_stg_orders_order_id ....................................... [PASS in 0.16s]
17:28:13  16 of 25 START test not_null_stg_users_user_id ................................. [RUN]
17:28:14  16 of 25 PASS not_null_stg_users_user_id ....................................... [PASS in 0.36s]
17:28:14  17 of 25 START test unique_stg_users_user_id ................................... [RUN]
17:28:14  17 of 25 PASS unique_stg_users_user_id ......................................... [PASS in 0.21s]
17:28:14  18 of 25 START sql view model ANALYTICS.fct_orders ............................. [RUN]
17:28:14  18 of 25 OK created sql view model ANALYTICS.fct_orders ........................ [SUCCESS 1 in 0.19s]
17:28:14  19 of 25 START sql incremental model ANALYTICS.fct_orders_daily ................ [RUN]
17:28:15  19 of 25 OK created sql incremental model ANALYTICS.fct_orders_daily ........... [SUCCESS 1 in 0.80s]
17:28:15  20 of 25 START sql view model ANALYTICS.dim_customers .......................... [RUN]
17:28:15  20 of 25 OK created sql view model ANALYTICS.dim_customers ..................... [SUCCESS 1 in 0.22s]
17:28:15  21 of 25 START test not_null_fct_orders_order_amount ........................... [RUN]
17:28:16  21 of 25 PASS not_null_fct_orders_order_amount ................................. [PASS in 0.41s]
17:28:16  22 of 25 START test not_null_fct_orders_order_id ............................... [RUN]
17:28:16  22 of 25 PASS not_null_fct_orders_order_id ..................................... [PASS in 0.15s]
17:28:16  23 of 25 START test unique_fct_orders_order_id ................................. [RUN]
17:28:16  23 of 25 PASS unique_fct_orders_order_id ....................................... [PASS in 0.23s]
17:28:16  24 of 25 START test not_null_dim_customers_user_id ............................. [RUN]
17:28:16  24 of 25 PASS not_null_dim_customers_user_id ................................... [PASS in 0.23s]
17:28:16  25 of 25 START test unique_dim_customers_user_id ............................... [RUN]
17:28:17  25 of 25 PASS unique_dim_customers_user_id ..................................... [PASS in 0.40s]
17:28:17  
17:28:17  Finished running 2 incremental models, 4 seeds, 1 snapshot, 14 data tests, 4 view models in 0 hours 0 minutes and 18.13 seconds (18.13s).
17:28:17  
17:28:17  Completed successfully
17:28:17  
17:28:17  Done. PASS=25 WARN=0 ERROR=0 SKIP=0 NO-OP=0 TOTAL=25
17:28:17  [WARNING][DeprecationsSummary]: Deprecated functionality
Summary of encountered deprecations:
- MissingArgumentsPropertyInGenericTestDeprecation: 1 occurrence
To see all deprecation instances instead of just the first occurrence of each,
run command again with the `--show-all-deprecations` flag. You may also need to
run with `--no-partial-parse` as some deprecations are only encountered during
parsing.
```

**Key Architectural Points:**
- **Dependency Resolution**: DBT automatically determines execution order
- **Parallel Execution**: Independent models run concurrently
- **Atomic Operations**: Each model is a transaction
- **Error Handling**: Failure stops execution, maintaining consistency

---

### 5. Individual Model Execution

#### `dbt run` (Specific Models)

**Command:**
```bash
dbt run --models stg_users stg_orders
```

**Expected Output:**
```
(.venv) austinabrahamanjiparambilhayis@Austins-MacBook-Air dbt-multi-warehouse-demo % dbt run --models stg_users stg_orders

17:29:15  Running with dbt=1.10.11
17:29:15  [WARNING]: Deprecated functionality
Usage of `--models`, `--model`, and `-m` is deprecated in favor of `--select` or
`-s`.
17:29:16  Registered adapter: snowflake=1.10.2
17:29:16  Unable to do partial parsing because config vars, config profile, or config target have changed
17:29:17  [WARNING][MissingArgumentsPropertyInGenericTestDeprecation]: Deprecated
functionality
Found top-level arguments to test `accepted_values`. Arguments to generic tests
should be nested under the `arguments` property.`
17:29:17  Found 6 models, 1 snapshot, 4 seeds, 14 data tests, 4 sources, 480 macros
17:29:17  
17:29:17  Concurrency: 1 threads (target='snowflake')
17:29:17  
17:29:18  1 of 2 START sql incremental model ANALYTICS.stg_orders ........................ [RUN]
17:29:20  1 of 2 OK created sql incremental model ANALYTICS.stg_orders ................... [SUCCESS 0 in 1.36s]
17:29:20  2 of 2 START sql view model ANALYTICS.stg_users ................................ [RUN]
17:29:20  2 of 2 OK created sql view model ANALYTICS.stg_users ........................... [SUCCESS 1 in 0.17s]
17:29:20  
17:29:20  Finished running 1 incremental model, 1 view model in 0 hours 0 minutes and 2.71 seconds (2.71s).
17:29:20  
17:29:20  Completed successfully
17:29:20  
17:29:20  Done. PASS=2 WARN=0 ERROR=0 SKIP=0 NO-OP=0 TOTAL=2
17:29:20  [WARNING][DeprecationsSummary]: Deprecated functionality
Summary of encountered deprecations:
- ModelParamUsageDeprecation: 1 occurrence
- MissingArgumentsPropertyInGenericTestDeprecation: 2 occurrences
To see all deprecation instances instead of just the first occurrence of each,
run command again with the `--show-all-deprecations` flag. You may also need to
run with `--no-partial-parse` as some deprecations are only encountered during
parsing.
```

---

### 6. Testing Data Quality

#### `dbt test`
Runs all defined tests to validate data quality.

**Command:**
```bash
dbt test --target snowflake
```

**Expected Output:**
```
(.venv) austinabrahamanjiparambilhayis@Austins-MacBook-Air dbt-multi-warehouse-demo % dbt test --target snowflake

17:29:57  Running with dbt=1.10.11
17:29:57  Registered adapter: snowflake=1.10.2
17:29:57  Unable to do partial parsing because config vars, config profile, or config target have changed
17:29:58  [WARNING][MissingArgumentsPropertyInGenericTestDeprecation]: Deprecated
functionality
Found top-level arguments to test `accepted_values`. Arguments to generic tests
should be nested under the `arguments` property.`
17:29:59  Found 6 models, 1 snapshot, 4 seeds, 14 data tests, 4 sources, 480 macros
17:29:59  
17:29:59  Concurrency: 1 threads (target='snowflake')
17:29:59  
17:30:00  1 of 14 START test accepted_values_stg_orders_status__completed__cancelled ..... [RUN]
17:30:00  1 of 14 PASS accepted_values_stg_orders_status__completed__cancelled ........... [PASS in 0.25s]
17:30:00  2 of 14 START test not_null_dim_customers_user_id .............................. [RUN]
17:30:01  2 of 14 PASS not_null_dim_customers_user_id .................................... [PASS in 0.47s]
17:30:01  3 of 14 START test not_null_fct_orders_order_amount ............................ [RUN]
17:30:01  3 of 14 PASS not_null_fct_orders_order_amount .................................. [PASS in 0.71s]
17:30:01  4 of 14 START test not_null_fct_orders_order_id ................................ [RUN]
17:30:02  4 of 14 PASS not_null_fct_orders_order_id ...................................... [PASS in 0.24s]
17:30:02  5 of 14 START test not_null_stg_order_items_order_id ........................... [RUN]
17:30:02  5 of 14 PASS not_null_stg_order_items_order_id ................................. [PASS in 0.10s]
17:30:02  6 of 14 START test not_null_stg_order_items_qty ................................ [RUN]
17:30:02  6 of 14 PASS not_null_stg_order_items_qty ...................................... [PASS in 0.13s]
17:30:02  7 of 14 START test not_null_stg_orders_order_id ................................ [RUN]
17:30:02  7 of 14 PASS not_null_stg_orders_order_id ...................................... [PASS in 0.21s]
17:30:02  8 of 14 START test not_null_stg_orders_user_id ................................. [RUN]
17:30:02  8 of 14 PASS not_null_stg_orders_user_id ....................................... [PASS in 0.08s]
17:30:02  9 of 14 START test not_null_stg_users_user_id .................................. [RUN]
17:30:02  9 of 14 PASS not_null_stg_users_user_id ........................................ [PASS in 0.18s]
17:30:02  10 of 14 START test relationships_stg_order_items_order_id__order_id__ref_stg_orders_  [RUN]
17:30:03  10 of 14 PASS relationships_stg_order_items_order_id__order_id__ref_stg_orders_  [PASS in 0.29s]
17:30:03  11 of 14 START test unique_dim_customers_user_id ............................... [RUN]
17:30:03  11 of 14 PASS unique_dim_customers_user_id ..................................... [PASS in 0.36s]
17:30:03  12 of 14 START test unique_fct_orders_order_id ................................. [RUN]
17:30:03  12 of 14 PASS unique_fct_orders_order_id ....................................... [PASS in 0.45s]
17:30:03  13 of 14 START test unique_stg_orders_order_id ................................. [RUN]
17:30:04  13 of 14 PASS unique_stg_orders_order_id ....................................... [PASS in 0.19s]
17:30:04  14 of 14 START test unique_stg_users_user_id ................................... [RUN]
17:30:04  14 of 14 PASS unique_stg_users_user_id ......................................... [PASS in 0.16s]
17:30:04  
17:30:04  Finished running 14 data tests in 0 hours 0 minutes and 5.02 seconds (5.02s).
17:30:04  
17:30:04  Completed successfully
17:30:04  
17:30:04  Done. PASS=14 WARN=0 ERROR=0 SKIP=0 NO-OP=0 TOTAL=14
17:30:04  [WARNING][DeprecationsSummary]: Deprecated functionality
Summary of encountered deprecations:
- MissingArgumentsPropertyInGenericTestDeprecation: 2 occurrences
To see all deprecation instances instead of just the first occurrence of each,
run command again with the `--show-all-deprecations` flag. You may also need to
run with `--no-partial-parse` as some deprecations are only encountered during
parsing.
```

**When Tests Fail:**

Let's intentionally break something:

**Command:**
```sql
-- Run this in your data warehouse to break a test:
UPDATE ANALYTICS.STG_ORDERS SET status = 'invalid_status' WHERE order_id = 101;
```

Then run:
```bash
dbt test --models stg_orders
```

**Expected Output:**
```
(.venv) austinabrahamanjiparambilhayis@Austins-MacBook-Air dbt-multi-warehouse-demo % dbt test --models stg_orders

17:37:30  Running with dbt=1.10.11
17:37:30  [WARNING]: Deprecated functionality
Usage of `--models`, `--model`, and `-m` is deprecated in favor of `--select` or
`-s`.
17:37:30  Registered adapter: snowflake=1.10.2
17:37:31  Found 6 models, 1 snapshot, 4 seeds, 14 data tests, 4 sources, 480 macros
17:37:31  
17:37:31  Concurrency: 1 threads (target='snowflake')
17:37:31  
17:37:32  1 of 5 START test accepted_values_stg_orders_status__completed__cancelled ...... [RUN]
17:37:32  1 of 5 FAIL 1 accepted_values_stg_orders_status__completed__cancelled .......... [FAIL 1 in 0.22s]
17:37:32  2 of 5 START test not_null_stg_orders_order_id ................................. [RUN]
17:37:32  2 of 5 PASS not_null_stg_orders_order_id ....................................... [PASS in 0.14s]
17:37:32  3 of 5 START test not_null_stg_orders_user_id .................................. [RUN]
17:37:33  3 of 5 PASS not_null_stg_orders_user_id ........................................ [PASS in 0.15s]
17:37:33  4 of 5 START test relationships_stg_order_items_order_id__order_id__ref_stg_orders_  [RUN]
17:37:33  4 of 5 PASS relationships_stg_order_items_order_id__order_id__ref_stg_orders_ .. [PASS in 0.23s]
17:37:33  5 of 5 START test unique_stg_orders_order_id ................................... [RUN]
17:37:33  5 of 5 PASS unique_stg_orders_order_id ......................................... [PASS in 0.22s]
17:37:33  
17:37:33  Finished running 5 data tests in 0 hours 0 minutes and 2.26 seconds (2.26s).
17:37:33  
17:37:33  Completed with 1 error, 0 partial successes, and 0 warnings:
17:37:33  
17:37:33  Failure in test accepted_values_stg_orders_status__completed__cancelled (models/staging/staging.yml)
17:37:33    Got 1 result, configured to fail if != 0
17:37:33  
17:37:33    compiled code at target/compiled/multi_warehouse_demo/models/staging/staging.yml/accepted_values_stg_orders_status__completed__cancelled.sql
17:37:33  
17:37:33  Done. PASS=4 WARN=0 ERROR=1 SKIP=0 NO-OP=0 TOTAL=5
17:37:33  [WARNING][DeprecationsSummary]: Deprecated functionality
Summary of encountered deprecations:
- ModelParamUsageDeprecation: 1 occurrence
To see all deprecation instances instead of just the first occurrence of each,
run command again with the `--show-all-deprecations` flag. You may also need to
run with `--no-partial-parse` as some deprecations are only encountered during
parsing.
```

Fix the data:
```sql
UPDATE ANALYTICS.STG_ORDERS SET status = 'completed' WHERE order_id = 101;
```

---

### 7. Documentation Generation

#### `dbt docs generate`
Creates interactive documentation website.

**Command:**
```bash
dbt docs generate --target snowflake
```

**Expected Output:**
```
(.venv) austinabrahamanjiparambilhayis@Austins-MacBook-Air dbt-multi-warehouse-demo % dbt docs generate --target snowflake

17:39:11  Running with dbt=1.10.11
17:39:12  Registered adapter: snowflake=1.10.2
17:39:12  Unable to do partial parsing because config vars, config profile, or config target have changed
17:39:13  [WARNING][MissingArgumentsPropertyInGenericTestDeprecation]: Deprecated
functionality
Found top-level arguments to test `accepted_values`. Arguments to generic tests
should be nested under the `arguments` property.`
17:39:13  Found 6 models, 1 snapshot, 4 seeds, 14 data tests, 4 sources, 480 macros
17:39:13  
17:39:13  Concurrency: 1 threads (target='snowflake')
17:39:13  
17:39:15  Building catalog
17:39:20  Catalog written to /Users/austinabrahamanjiparambilhayis/Documents/repos/dbt-multi-warehouse-demo/target/catalog.json
17:39:20  [WARNING][DeprecationsSummary]: Deprecated functionality
Summary of encountered deprecations:
- MissingArgumentsPropertyInGenericTestDeprecation: 2 occurrences
To see all deprecation instances instead of just the first occurrence of each,
run command again with the `--show-all-deprecations` flag. You may also need to
run with `--no-partial-parse` as some deprecations are only encountered during
parsing.
```

#### `dbt docs serve`
Serves documentation locally.

**Command:**
```bash
dbt docs serve --port 8080
```

**Expected Output:**
```
(.venv) austinabrahamanjiparambilhayis@Austins-MacBook-Air dbt-multi-warehouse-demo % dbt docs serve --port 8080

17:40:18  Running with dbt=1.10.11
Serving docs at 8080
To access from your browser, navigate to: http://localhost:8080



Press Ctrl+C to exit.
127.0.0.1 - - [09/Sep/2025 18:40:19] "GET / HTTP/1.1" 200 -
127.0.0.1 - - [09/Sep/2025 18:40:19] "GET /manifest.json?cb=1757439619922 HTTP/1.1" 200 -
127.0.0.1 - - [09/Sep/2025 18:40:19] "GET /catalog.json?cb=1757439619922 HTTP/1.1" 200 -
127.0.0.1 - - [09/Sep/2025 18:40:20] code 404, message File not found
127.0.0.1 - - [09/Sep/2025 18:40:20] "GET /%7B%7B%20getIcon(item.type,%20'on')%20%7D%7D HTTP/1.1" 404 -
127.0.0.1 - - [09/Sep/2025 18:40:20] code 404, message File not found
127.0.0.1 - - [09/Sep/2025 18:40:20] "GET /%7B%7B%20getIcon(item.type,%20'off')%20%7D%7D HTTP/1.1" 404 -
127.0.0.1 - - [09/Sep/2025 18:40:20] code 404, message File not found
127.0.0.1 - - [09/Sep/2025 18:40:20] "GET /$%7Brequire('./assets/favicons/favicon.ico')%7D HTTP/1.1" 404 -
```

---

### 8. Incremental Model Updates

#### Understanding Incremental Processing

Incremental models are like **event sourcing** - they only process new/changed data.

**Command:**
```bash
dbt run --models fct_orders_daily --vars '{"run_start": "2024-03-01", "run_end": "2024-03-31"}'
```

**Expected Output:**
```
(.venv) austinabrahamanjiparambilhayis@Austins-MacBook-Air dbt-multi-warehouse-demo % dbt run --models fct_orders_daily --vars '{"run_start": "2024-03-01", "run_end": "2024-03-31"}'

17:44:56  Running with dbt=1.10.11
17:44:56  [WARNING]: Deprecated functionality
Usage of `--models`, `--model`, and `-m` is deprecated in favor of `--select` or
`-s`.
17:44:57  Registered adapter: snowflake=1.10.2
17:44:57  Unable to do partial parsing because config vars, config profile, or config target have changed
17:44:58  [WARNING][MissingArgumentsPropertyInGenericTestDeprecation]: Deprecated
functionality
Found top-level arguments to test `accepted_values`. Arguments to generic tests
should be nested under the `arguments` property.`
17:44:59  Found 6 models, 1 snapshot, 4 seeds, 14 data tests, 4 sources, 480 macros
17:44:59  
17:44:59  Concurrency: 1 threads (target='snowflake')
17:44:59  
17:45:00  1 of 1 START sql incremental model ANALYTICS.fct_orders_daily .................. [RUN]
17:45:02  1 of 1 OK created sql incremental model ANALYTICS.fct_orders_daily ............. [SUCCESS 0 in 2.36s]
17:45:02  
17:45:02  Finished running 1 incremental model in 0 hours 0 minutes and 3.55 seconds (3.55s).
17:45:02  
17:45:02  Completed successfully
17:45:02  
17:45:02  Done. PASS=1 WARN=0 ERROR=0 SKIP=0 NO-OP=0 TOTAL=1
17:45:02  [WARNING][DeprecationsSummary]: Deprecated functionality
Summary of encountered deprecations:
- ModelParamUsageDeprecation: 1 occurrence
- MissingArgumentsPropertyInGenericTestDeprecation: 2 occurrences
To see all deprecation instances instead of just the first occurrence of each,
run command again with the `--show-all-deprecations` flag. You may also need to
run with `--no-partial-parse` as some deprecations are only encountered during
parsing.
```

---

### 9. Snapshot Execution (SCD2)

#### `dbt snapshot`
Implements Slowly Changing Dimensions (like event sourcing for dimension data).

**Command:**
```bash
dbt snapshot --target snowflake
```

**Expected Output:**
```
(.venv) austinabrahamanjiparambilhayis@Austins-MacBook-Air dbt-multi-warehouse-demo % dbt snapshot --target snowflake

17:40:49  Running with dbt=1.10.11
17:40:50  Registered adapter: snowflake=1.10.2
17:40:50  Found 6 models, 1 snapshot, 4 seeds, 14 data tests, 4 sources, 480 macros
17:40:50  
17:40:50  Concurrency: 1 threads (target='snowflake')
17:40:50  
17:40:52  1 of 1 START snapshot analytics_snapshots.customers_scd2 ....................... [RUN]
17:40:55  1 of 1 OK snapshotted analytics_snapshots.customers_scd2 ....................... [SUCCESS 0 in 2.95s]
17:40:55  
17:40:55  Finished running 1 snapshot in 0 hours 0 minutes and 4.37 seconds (4.37s).
17:40:55  
17:40:55  Completed successfully
17:40:55  
17:40:55  Done. PASS=1 WARN=0 ERROR=0 SKIP=0 NO-OP=0 TOTAL=1
```

**Query the Results:**
```sql
SELECT 
    user_id, 
    email, 
    country,
    dbt_valid_from,
    dbt_valid_to,
    dbt_updated_at
FROM ANALYTICS_SNAPSHOTS.CUSTOMERS_SCD2 
ORDER BY user_id, dbt_valid_from;
```

**Expected Results:**
```
USER_ID	EMAIL	COUNTRY	DBT_VALID_FROM	DBT_VALID_TO	DBT_UPDATED_AT
1	a@x.com	UK	2024-01-03 10:00:00.000		2024-01-03 10:00:00.000
2	b@x.com	IN	2024-01-04 11:00:00.000	2024-03-15 09:00:00.000	2024-01-04 11:00:00.000
2	b@x.com	UK	2024-03-15 09:00:00.000		2024-03-15 09:00:00.000
3	c@x.com	US	2024-02-10 08:20:00.000		2024-02-10 08:20:00.000
4	d@x.com	UK	2024-03-01 12:00:00.000		2024-03-01 12:00:00.000
5	e@x.com	DE	2024-03-02 13:10:00.000	2024-03-20 12:00:00.000	2024-03-02 13:10:00.000
5	elena@x.com	DE	2024-03-20 12:00:00.000		2024-03-20 12:00:00.000
```

---

### 10. Multi-Warehouse Deployment

#### Switching Target Warehouses

**Databricks:**
```bash
dbt build --target databricks
```

**Redshift:**
```bash
dbt build --target redshift
```

**Expected Outputs:**
```
[PLACEHOLDER - SHOW DIFFERENCES IN OUTPUT BETWEEN WAREHOUSES]

Key differences:
- SQL dialect variations handled automatically
- Performance characteristics
- Feature availability
```

---

### 11. Advanced Operations

#### Dependency Visualization

**Command:**
```bash
dbt list --select +fct_orders+ --output json
```

**Expected Output:**
```
(.venv) austinabrahamanjiparambilhayis@Austins-MacBook-Air dbt-multi-warehouse-demo % dbt list --select +fct_orders+ --output json
17:49:00  Running with dbt=1.10.11
17:49:01  Registered adapter: snowflake=1.10.2
{"name": "fct_orders", "resource_type": "model", "package_name": "multi_warehouse_demo", "original_file_path": "models/marts/fct_orders.sql", "unique_id": "model.multi_warehouse_demo.fct_orders", "alias": "fct_orders", "config": {"enabled": true, "alias": null, "schema": null, "database": null, "tags": [], "meta": {}, "group": null, "materialized": "view", "incremental_strategy": null, "batch_size": null, "lookback": 1, "begin": null, "persist_docs": {}, "post-hook": [], "pre-hook": [], "quoting": {}, "column_types": {}, "full_refresh": null, "unique_key": null, "on_schema_change": "ignore", "on_configuration_change": "apply", "grants": {}, "packages": [], "docs": {"show": true, "node_color": null}, "contract": {"enforced": false, "alias_types": true}, "event_time": null, "concurrent_batches": null, "access": "protected", "freshness": null}, "tags": [], "depends_on": {"macros": [], "nodes": ["model.multi_warehouse_demo.stg_orders", "model.multi_warehouse_demo.stg_order_items"]}}
{"name": "stg_order_items", "resource_type": "model", "package_name": "multi_warehouse_demo", "original_file_path": "models/staging/stg_order_items.sql", "unique_id": "model.multi_warehouse_demo.stg_order_items", "alias": "stg_order_items", "config": {"enabled": true, "alias": null, "schema": null, "database": null, "tags": [], "meta": {}, "group": null, "materialized": "view", "incremental_strategy": null, "batch_size": null, "lookback": 1, "begin": null, "persist_docs": {}, "post-hook": [], "pre-hook": [], "quoting": {}, "column_types": {}, "full_refresh": null, "unique_key": null, "on_schema_change": "ignore", "on_configuration_change": "apply", "grants": {}, "packages": [], "docs": {"show": true, "node_color": null}, "contract": {"enforced": false, "alias_types": true}, "event_time": null, "concurrent_batches": null, "access": "protected", "freshness": null}, "tags": [], "depends_on": {"macros": [], "nodes": ["source.multi_warehouse_demo.analytics.raw_order_items"]}}
{"name": "stg_orders", "resource_type": "model", "package_name": "multi_warehouse_demo", "original_file_path": "models/staging/stg_orders.sql", "unique_id": "model.multi_warehouse_demo.stg_orders", "alias": "stg_orders", "config": {"enabled": true, "alias": null, "schema": null, "database": null, "tags": [], "meta": {}, "group": null, "materialized": "incremental", "incremental_strategy": null, "batch_size": null, "lookback": 1, "begin": null, "persist_docs": {}, "post-hook": [], "pre-hook": [], "quoting": {}, "column_types": {}, "full_refresh": null, "unique_key": "order_id", "on_schema_change": "ignore", "on_configuration_change": "apply", "grants": {}, "packages": [], "docs": {"show": true, "node_color": null}, "contract": {"enforced": false, "alias_types": true}, "event_time": null, "concurrent_batches": null, "access": "protected", "freshness": null}, "tags": [], "depends_on": {"macros": ["macro.dbt.is_incremental"], "nodes": ["source.multi_warehouse_demo.analytics.raw_orders"]}}
{"name": "raw_order_items", "resource_type": "source", "package_name": "multi_warehouse_demo", "original_file_path": "models/sources/sources.yml", "unique_id": "source.multi_warehouse_demo.analytics.raw_order_items", "source_name": "analytics", "tags": [], "config": {"enabled": true, "event_time": null, "freshness": {"warn_after": {"count": null, "period": null}, "error_after": {"count": null, "period": null}, "filter": null}, "loaded_at_field": null, "loaded_at_query": null, "meta": {}, "tags": []}}
{"name": "raw_orders", "resource_type": "source", "package_name": "multi_warehouse_demo", "original_file_path": "models/sources/sources.yml", "unique_id": "source.multi_warehouse_demo.analytics.raw_orders", "source_name": "analytics", "tags": [], "config": {"enabled": true, "event_time": null, "freshness": {"warn_after": {"count": null, "period": null}, "error_after": {"count": null, "period": null}, "filter": null}, "loaded_at_field": null, "loaded_at_query": null, "meta": {}, "tags": []}}
{"name": "accepted_values_stg_orders_status__completed__cancelled", "resource_type": "test", "package_name": "multi_warehouse_demo", "original_file_path": "models/staging/staging.yml", "unique_id": "test.multi_warehouse_demo.accepted_values_stg_orders_status__completed__cancelled.0881a3f2d1", "alias": "accepted_values_stg_orders_status__completed__cancelled", "config": {"enabled": true, "alias": null, "schema": "dbt_test__audit", "database": null, "tags": [], "meta": {}, "group": null, "materialized": "test", "severity": "ERROR", "store_failures": null, "store_failures_as": null, "where": null, "limit": null, "fail_calc": "count(*)", "warn_if": "!= 0", "error_if": "!= 0"}, "tags": [], "depends_on": {"macros": ["macro.dbt.test_accepted_values", "macro.dbt.get_where_subquery"], "nodes": ["model.multi_warehouse_demo.stg_orders"]}}
{"name": "not_null_fct_orders_order_amount", "resource_type": "test", "package_name": "multi_warehouse_demo", "original_file_path": "models/marts/marts.yml", "unique_id": "test.multi_warehouse_demo.not_null_fct_orders_order_amount.ca14a44d1f", "alias": "not_null_fct_orders_order_amount", "config": {"enabled": true, "alias": null, "schema": "dbt_test__audit", "database": null, "tags": [], "meta": {}, "group": null, "materialized": "test", "severity": "ERROR", "store_failures": null, "store_failures_as": null, "where": null, "limit": null, "fail_calc": "count(*)", "warn_if": "!= 0", "error_if": "!= 0"}, "tags": [], "depends_on": {"macros": ["macro.dbt.test_not_null"], "nodes": ["model.multi_warehouse_demo.fct_orders"]}}
{"name": "not_null_fct_orders_order_id", "resource_type": "test", "package_name": "multi_warehouse_demo", "original_file_path": "models/marts/marts.yml", "unique_id": "test.multi_warehouse_demo.not_null_fct_orders_order_id.4e687af8d0", "alias": "not_null_fct_orders_order_id", "config": {"enabled": true, "alias": null, "schema": "dbt_test__audit", "database": null, "tags": [], "meta": {}, "group": null, "materialized": "test", "severity": "ERROR", "store_failures": null, "store_failures_as": null, "where": null, "limit": null, "fail_calc": "count(*)", "warn_if": "!= 0", "error_if": "!= 0"}, "tags": [], "depends_on": {"macros": ["macro.dbt.test_not_null"], "nodes": ["model.multi_warehouse_demo.fct_orders"]}}
{"name": "not_null_stg_order_items_order_id", "resource_type": "test", "package_name": "multi_warehouse_demo", "original_file_path": "models/staging/staging.yml", "unique_id": "test.multi_warehouse_demo.not_null_stg_order_items_order_id.2063801f96", "alias": "not_null_stg_order_items_order_id", "config": {"enabled": true, "alias": null, "schema": "dbt_test__audit", "database": null, "tags": [], "meta": {}, "group": null, "materialized": "test", "severity": "ERROR", "store_failures": null, "store_failures_as": null, "where": null, "limit": null, "fail_calc": "count(*)", "warn_if": "!= 0", "error_if": "!= 0"}, "tags": [], "depends_on": {"macros": ["macro.dbt.test_not_null"], "nodes": ["model.multi_warehouse_demo.stg_order_items"]}}
{"name": "not_null_stg_order_items_qty", "resource_type": "test", "package_name": "multi_warehouse_demo", "original_file_path": "models/staging/staging.yml", "unique_id": "test.multi_warehouse_demo.not_null_stg_order_items_qty.8ef4f29677", "alias": "not_null_stg_order_items_qty", "config": {"enabled": true, "alias": null, "schema": "dbt_test__audit", "database": null, "tags": [], "meta": {}, "group": null, "materialized": "test", "severity": "ERROR", "store_failures": null, "store_failures_as": null, "where": null, "limit": null, "fail_calc": "count(*)", "warn_if": "!= 0", "error_if": "!= 0"}, "tags": [], "depends_on": {"macros": ["macro.dbt.test_not_null"], "nodes": ["model.multi_warehouse_demo.stg_order_items"]}}
{"name": "not_null_stg_orders_order_id", "resource_type": "test", "package_name": "multi_warehouse_demo", "original_file_path": "models/staging/staging.yml", "unique_id": "test.multi_warehouse_demo.not_null_stg_orders_order_id.81cfe2fe64", "alias": "not_null_stg_orders_order_id", "config": {"enabled": true, "alias": null, "schema": "dbt_test__audit", "database": null, "tags": [], "meta": {}, "group": null, "materialized": "test", "severity": "ERROR", "store_failures": null, "store_failures_as": null, "where": null, "limit": null, "fail_calc": "count(*)", "warn_if": "!= 0", "error_if": "!= 0"}, "tags": [], "depends_on": {"macros": ["macro.dbt.test_not_null"], "nodes": ["model.multi_warehouse_demo.stg_orders"]}}
{"name": "not_null_stg_orders_user_id", "resource_type": "test", "package_name": "multi_warehouse_demo", "original_file_path": "models/staging/staging.yml", "unique_id": "test.multi_warehouse_demo.not_null_stg_orders_user_id.7d129d0209", "alias": "not_null_stg_orders_user_id", "config": {"enabled": true, "alias": null, "schema": "dbt_test__audit", "database": null, "tags": [], "meta": {}, "group": null, "materialized": "test", "severity": "ERROR", "store_failures": null, "store_failures_as": null, "where": null, "limit": null, "fail_calc": "count(*)", "warn_if": "!= 0", "error_if": "!= 0"}, "tags": [], "depends_on": {"macros": ["macro.dbt.test_not_null"], "nodes": ["model.multi_warehouse_demo.stg_orders"]}}
{"name": "relationships_stg_order_items_order_id__order_id__ref_stg_orders_", "resource_type": "test", "package_name": "multi_warehouse_demo", "original_file_path": "models/staging/staging.yml", "unique_id": "test.multi_warehouse_demo.relationships_stg_order_items_order_id__order_id__ref_stg_orders_.dbe9930c54", "alias": "relationships_stg_order_items_b3d7cdbd08ebfad01e3226c01c10bba0", "config": {"enabled": true, "alias": "relationships_stg_order_items_b3d7cdbd08ebfad01e3226c01c10bba0", "schema": "dbt_test__audit", "database": null, "tags": [], "meta": {}, "group": null, "materialized": "test", "severity": "ERROR", "store_failures": null, "store_failures_as": null, "where": null, "limit": null, "fail_calc": "count(*)", "warn_if": "!= 0", "error_if": "!= 0"}, "tags": [], "depends_on": {"macros": ["macro.dbt.test_relationships", "macro.dbt.get_where_subquery"], "nodes": ["model.multi_warehouse_demo.stg_orders", "model.multi_warehouse_demo.stg_order_items"]}}
{"name": "unique_fct_orders_order_id", "resource_type": "test", "package_name": "multi_warehouse_demo", "original_file_path": "models/marts/marts.yml", "unique_id": "test.multi_warehouse_demo.unique_fct_orders_order_id.523ddb6ce5", "alias": "unique_fct_orders_order_id", "config": {"enabled": true, "alias": null, "schema": "dbt_test__audit", "database": null, "tags": [], "meta": {}, "group": null, "materialized": "test", "severity": "ERROR", "store_failures": null, "store_failures_as": null, "where": null, "limit": null, "fail_calc": "count(*)", "warn_if": "!= 0", "error_if": "!= 0"}, "tags": [], "depends_on": {"macros": ["macro.dbt.test_unique"], "nodes": ["model.multi_warehouse_demo.fct_orders"]}}
{"name": "unique_stg_orders_order_id", "resource_type": "test", "package_name": "multi_warehouse_demo", "original_file_path": "models/staging/staging.yml", "unique_id": "test.multi_warehouse_demo.unique_stg_orders_order_id.e3b841c71a", "alias": "unique_stg_orders_order_id", "config": {"enabled": true, "alias": null, "schema": "dbt_test__audit", "database": null, "tags": [], "meta": {}, "group": null, "materialized": "test", "severity": "ERROR", "store_failures": null, "store_failures_as": null, "where": null, "limit": null, "fail_calc": "count(*)", "warn_if": "!= 0", "error_if": "!= 0"}, "tags": [], "depends_on": {"macros": ["macro.dbt.test_unique"], "nodes": ["model.multi_warehouse_demo.stg_orders"]}}
```

#### Fresh Data Checks

**Command:**
```bash
dbt source freshness
```

**Expected Output:**
```
(.venv) austinabrahamanjiparambilhayis@Austins-MacBook-Air dbt-multi-warehouse-demo % dbt source freshness

17:48:43  Running with dbt=1.10.11
17:48:44  Registered adapter: snowflake=1.10.2
17:48:44  Found 6 models, 1 snapshot, 4 seeds, 14 data tests, 4 sources, 480 macros
17:48:44  Nothing to do. Try checking your model configs and model specification args
17:48:44  Done.
```

---

## Best Practices and Patterns

### 1. Naming Conventions
```
stg_[source_name]     # Staging models
dim_[entity]          # Dimension tables
fct_[event/process]   # Fact tables
int_[description]     # Intermediate models
```

### 2. Model Organization
- **One model per file**
- **Clear dependencies** using `{{ ref() }}`
- **Consistent materialization strategies**

### 3. Testing Strategy
```yaml
# Every model should have:
- name: model_name
  columns:
    - name: primary_key
      tests: [unique, not_null]
    - name: foreign_key
      tests:
        - relationships:
            to: ref('parent_table')
            field: parent_key
```

### 4. Documentation Standards
```yaml
models:
  - name: dim_customers
    description: "Customer dimension with lifetime value metrics"
    columns:
      - name: customer_id
        description: "Unique identifier for customer"
      - name: lifetime_value
        description: "Total revenue from customer to date"
```

### 5. Performance Optimization
- **Use appropriate materializations**
- **Implement incremental models for large datasets**
- **Partition tables by date when possible**
- **Add indexes on frequently queried columns**

---

## Integration with Modern Data Stack

### Typical Architecture Stack

```
Data Sources → Ingestion → Storage → Transformation → Analytics
    (APIs)      (Fivetran)  (Snowflake)    (DBT)      (Tableau)
    (Files)     (Airbyte)   (Databricks)              (Looker)
    (DBs)       (Stitch)    (Redshift)                (PowerBI)
```

### DBT's Role in CI/CD Pipeline

```yaml
# Example GitHub Actions workflow
name: DBT CI/CD
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Run DBT Tests
        run: |
          dbt deps
          dbt seed --target dev
          dbt run --target dev
          dbt test --target dev
  
  deploy:
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    steps:
      - name: Deploy to Production
        run: |
          dbt run --target prod
          dbt test --target prod
```

### Monitoring and Observability

DBT integrates with:
- **Data lineage tools** (automatically generated)
- **Data quality monitoring** (test results)
- **Performance monitoring** (execution times)
- **Alerting systems** (test failures, freshness issues)

---

## Understanding the Results: What Each Output Tells You

### Model Execution Results
```
What Successful Runs Look Like:

17:23:06  1 of 25 START sql view model ANALYTICS.stg_order_items ......................... [RUN]
17:23:07  1 of 25 OK created sql view model ANALYTICS.stg_order_items .................... [SUCCESS 1 in 0.81s]
17:23:07  2 of 25 START sql incremental model ANALYTICS.stg_orders ....................... [RUN]
17:23:08  2 of 25 OK created sql incremental model ANALYTICS.stg_orders .................. [SUCCESS 1 in 1.22s]

Key Success Indicators:
✅ Status: START → OK (no errors)
✅ Materialization: Shows strategy (view/incremental/table)
✅ Timing: Execution time per model (0.81s, 1.22s)
✅ Impact: Row counts or objects affected (SUCCESS 1, INSERT 8)
```

### Test Results Analysis
```
Examples of Test Outputs:

✅ PASS Examples:
17:23:15  9 of 25 PASS not_null_stg_order_items_order_id ................................. [PASS in 0.20s]
17:23:16  11 of 25 PASS accepted_values_stg_orders_status__completed__cancelled .......... [PASS in 0.44s]

❌ FAIL Example:
17:23:17  14 of 25 FAIL 8 relationships_stg_order_items_qty__order_id__ref_stg_orders_ ... [FAIL 8 in 0.75s]
(Meaning: 8 rows failed referential integrity check)

⏭️ SKIP Example:
17:23:18  18 of 25 SKIP relation ANALYTICS.fct_orders .................................... [SKIP]
(Meaning: Dependent model skipped due to upstream failure)
```

### Performance Insights
```
Performance Breakdown (14.99s total):
- Models (6): ~3.5s (23% of time)
- Seeds (4): ~5.2s (35% of time) 
- Tests (14): ~4.8s (32% of time)
- Snapshots (1): ~1.3s (9% of time)

Execution Efficiency:
- Average model time: 0.58s
- Average test time: 0.34s
- Parallel execution: 1 thread (room for improvement)
- Memory usage: Minimal for this dataset size
```

---

## Conclusion for Software Architects

DBT brings **software engineering best practices** to data transformations:

1. **Version Control**: All logic in Git
2. **Testing**: Automated data quality checks
3. **Documentation**: Self-documenting code and lineage
4. **Modularity**: Reusable, composable transformations
5. **CI/CD**: Fits into existing deployment pipelines
6. **Multi-environment**: Dev/staging/prod workflows

**Key Takeaway**: DBT transforms data engineering from ad-hoc scripting into **structured software development**, making data pipelines more reliable, maintainable, and scalable.

The shift from "data as scripts" to "data as code" enables the same quality, reliability, and collaboration patterns that software teams already know and use.

<!-- ---

## Next Steps

1. **Run through this demo** with your data team
2. **Identify pilot use case** in your organization
3. **Set up development environment** with your data warehouse
4. **Define initial models** for one business domain
5. **Implement CI/CD pipeline** for data transformations
6. **Establish governance** around model development and testing

This represents a **paradigm shift** toward treating data infrastructure with the same rigor as application infrastructure - something software architects naturally understand and can champion within their organizations. -->