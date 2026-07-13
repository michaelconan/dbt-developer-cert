-- DuckDB training setup script
-- Targets the 'training.duckdb' database defined in profiles.yml (duck target)


-- create schemas
CREATE SCHEMA IF NOT EXISTS jaffle_shop;
CREATE SCHEMA IF NOT EXISTS stripe;


-- create tables
CREATE TABLE IF NOT EXISTS jaffle_shop.customers (
    id          INTEGER,
    first_name  VARCHAR,
    last_name   VARCHAR
);

CREATE TABLE IF NOT EXISTS jaffle_shop.orders (
    id              INTEGER,
    user_id         INTEGER,
    order_date      DATE,
    status          VARCHAR,
    _etl_loaded_at  TIMESTAMP DEFAULT current_timestamp
);

CREATE TABLE IF NOT EXISTS stripe.payment (
    id              INTEGER,
    orderid         INTEGER,
    paymentmethod   VARCHAR,
    status          VARCHAR,
    amount          INTEGER,
    created         DATE,
    _batched_at     TIMESTAMP DEFAULT current_timestamp
);


-- load data from S3 using DuckDB's read_csv_auto (requires httpfs extension)
INSTALL httpfs;
LOAD httpfs;

INSERT INTO jaffle_shop.customers
SELECT id, first_name, last_name
FROM read_csv_auto('s3://dbt-tutorial-public/jaffle_shop_customers.csv', header = true);

INSERT INTO jaffle_shop.orders
SELECT id, user_id, order_date, status, current_timestamp AS _etl_loaded_at
FROM read_csv_auto('s3://dbt-tutorial-public/jaffle_shop_orders.csv', header = true);

INSERT INTO stripe.payment
SELECT id, orderid, paymentmethod, status, amount, created, current_timestamp AS _batched_at
FROM read_csv_auto('s3://dbt-tutorial-public/stripe_payments.csv', header = true);


-- check data to confirm load

SELECT * FROM jaffle_shop.customers;

SELECT * FROM jaffle_shop.orders;

SELECT * FROM stripe.payment;
