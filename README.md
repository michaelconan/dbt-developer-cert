# dbt Developer Certification — Training Project

A hands-on project supporting the [dbt Developer Certification](https://www.getdbt.com/certifications/analytics-engineer) learning path, built around the classic Jaffle Shop dataset.

## Prerequisites

### dbt Runtime

Choose **one** of the following ways to run dbt:

| Option | Notes |
|---|---|
| **dbt Cloud** | Easiest to get started. [Developer Edition](https://www.getdbt.com/signup/) is free for 1 project. |
| **dbt Core 1.x** (Python adapters) | Install platform-specific Python adapter (e.g. `dbt-bigquery`, `dbt-databricks`, `dbt-duckdb`). Requires Python 3.11+. |
| **dbt Core 2.x / dbt Fusion** | New Rust-based engine. Adapters ship separately; check [docs.getdbt.com](https://docs.getdbt.com) for current adapter support. |

- One of the supported data platforms below

---

## Platform Setup Options

This project supports three free platform options. Choose the one that best fits your setup. The active target is controlled by the `target:` field in [`profiles.yml`](profiles.yml).

### Option 1 — BigQuery (Free Tier)

Google BigQuery offers a **persistent free tier** with 10 GB of storage and 1 TB of query processing per month — more than enough for this project.

**Steps:**

1. Create a [Google Cloud account](https://cloud.google.com/free) (free tier, no credit card required for sandbox usage).
2. Create a new GCP project and enable the BigQuery API.
3. Create a service account with the **BigQuery Data Editor** and **BigQuery Job User** roles, then download the JSON key file.
4. Set the required environment variables:
   ```bash
   export GCP_PROJECT_ID="your-gcp-project-id"
   export GOOGLE_APPLICATION_CREDENTIALS="/path/to/keyfile.json"
   ```
5. In [`profiles.yml`](profiles.yml), set `target: gbq`.
6. The source data lives in the public `dbt-tutorial` GCP project — no data loading script is needed. The `source_db` var in [`dbt_project.yml`](dbt_project.yml) handles this automatically.

---

### Option 2 — Databricks (Free Edition)

Databricks offers a **Community Edition** that is permanently free and includes a single-node cluster.

**Steps:**

1. Sign up for [Databricks Community Edition](https://community.cloud.databricks.com/login.html).
2. Start a cluster and note the **Server Hostname** and **HTTP Path** from the cluster's *Advanced Options → JDBC/ODBC* tab.
3. Set the required environment variables:
   ```bash
   export DATABRICKS_HOST="https://<your-workspace>.azuredatabricks.net"
   export DATABRICKS_HTTP_PATH="/sql/1.0/warehouses/<id>"
   ```
4. In [`profiles.yml`](profiles.yml), set `target: dbx`.
5. Run the setup script to create schemas and load source data:
   ```bash
   # Run via the Databricks SQL editor or CLI
   scripts/setup_databricks.sql
   ```
   This creates the `workspace.jaffle_shop` and `workspace.stripe` schemas and loads data from the public S3 bucket.

---

### Option 3 — DuckDB (Local, No Account Needed)

DuckDB is an **embedded analytical database** that runs entirely on your machine — no cloud account, no credentials, no setup friction. It's the fastest way to get started.

**Steps:**

1. Install the dbt-duckdb adapter (dbt Core 1.x):
   ```bash
   pip install dbt-duckdb
   # or with uv (recommended for this project):
   uv add dbt-duckdb
   ```
   > **dbt Core 2.x / Fusion:** Check [hub.getdbt.com](https://hub.getdbt.com) for the current DuckDB adapter package, as the distribution model changed in v2. **dbt Cloud** users can connect to DuckDB via the Cloud CLI without a local adapter install.
2. In [`profiles.yml`](profiles.yml), set `target: duck`. The database file `training.duckdb` will be created automatically in the project root.
3. Run the setup script to create schemas and load source data from S3:
   ```bash
   duckdb training.duckdb < scripts/setup_duckdb.sql
   ```
   > **Note:** The first run installs the `httpfs` extension to read from S3. An internet connection is required for the initial data load only.

---

## Running dbt

Once your platform is set up, run the standard dbt workflow:

```bash
# Install dependencies
dbt deps

# Validate your connection
dbt debug

# Build all models
dbt build

# Or run models and tests separately
dbt run
dbt test
```

## Project Structure

```
jaffle_shop/
├── models/
│   ├── staging/        # Cleaned, typed views over raw source tables
│   ├── intermediate/   # (optional) Business logic building blocks
│   └── marts/          # Final dimensional and fact models (materialized as tables)
├── seeds/              # Static reference data loaded via dbt seed
├── snapshots/          # SCD Type 2 snapshots
├── tests/              # Custom data tests
├── scripts/
│   ├── setup_databricks.sql
│   └── setup_duckdb.sql
└── profiles.yml        # Connection targets: gbq | dbx | duck
```
