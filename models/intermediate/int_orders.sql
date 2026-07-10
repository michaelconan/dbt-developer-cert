with
-- import statements
customers as (select * from {{ ref("stg_jaffle_shop__customers") }}),

payments as (
    select * from {{ ref("stg_stripe__payments") }}
    where payment_status <> 'fail'
),

orders as (
    select * from {{ ref("stg_jaffle_shop__orders") }}
),

-- Logical CTEs

completed_payments as (

    select
        order_id,
        max(payment_created_at) as payment_finalized_date,
        sum(payment_amount) as total_amount_paid
    from payments
    group by all

),

paid_orders as (

    select
        orders.order_id,
        orders.customer_id,
        orders.order_placed_at,
        orders.order_status,
        orders.valid_order_date,
        completed_payments.total_amount_paid,
        completed_payments.payment_finalized_date
    from orders
    left join completed_payments on orders.order_id = completed_payments.order_id

)

select * from paid_orders
