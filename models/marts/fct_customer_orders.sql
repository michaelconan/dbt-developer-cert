with
-- import statements
customers as (select * from {{ ref("stg_jaffle_shop__customers") }}),

paid_orders as (
    select * from {{ ref("int_orders") }}
),

customer_orders as (

    select
        paid_orders.*,
        count(*) over (partition by paid_orders.customer_id) as order_count,
        sum(case when paid_orders.valid_order_date is null then 1 else 0 end)
            over (partition by paid_orders.customer_id)
            as non_returned_order_count,
        sum(case when paid_orders.valid_order_date is null then paid_orders.total_amount_paid else 0 end)
            over (partition by paid_orders.customer_id)
            as total_lifetime_value
    from paid_orders
    inner join customers
        on paid_orders.customer_id = customers.customer_id
),

add_avg_order_values as (

    select
        customer_orders.*,
        safe_divide(total_lifetime_value, non_returned_order_count) as avg_non_returned_order_value
    from customer_orders

),

-- Final CTE
final as (

    select
        paid_orders.order_id,
        paid_orders.customer_id,
        paid_orders.order_placed_at,
        paid_orders.order_status,
        paid_orders.total_amount_paid,
        paid_orders.payment_finalized_date,
        customers.customer_first_name,
        customers.customer_last_name,

        -- sales transaction sequence
        row_number() over (order by paid_orders.order_placed_at, paid_orders.order_id) as transaction_seq,

        -- customer sales sequence
        row_number() over (
            partition by paid_orders.customer_id
            order by paid_orders.order_placed_at, paid_orders.order_id
        ) as customer_sales_seq,

        -- new vs returning customer
        case
            when (
                rank() over (
                    partition by paid_orders.customer_id
                    order by paid_orders.order_placed_at, paid_orders.order_id
                ) = 1
            ) then 'new'
            else 'return'
        end as nvsr,

        -- customer lifetime value
        sum(paid_orders.total_amount_paid) over (
            partition by paid_orders.customer_id
            order by paid_orders.order_placed_at, paid_orders.order_id
        ) as customer_lifetime_value,

        -- first day of sale
        first_value(paid_orders.order_placed_at) over (
            partition by paid_orders.customer_id
            order by paid_orders.order_placed_at, paid_orders.order_id
        ) as fdos
    from paid_orders
    left join customers on paid_orders.customer_id = customers.customer_id
)

-- Simple Select Statment
select * from final
