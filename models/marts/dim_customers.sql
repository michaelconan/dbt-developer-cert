with
customer_orders as (

    select
        customer_id,

        min(order_placed_at) as first_order_date,
        max(order_placed_at) as most_recent_order_date,
        count(order_id) as number_of_orders

    from {{ ref("stg_jaffle_shop__orders") }}

    group by 1

),

final as (

    select
        customers.customer_id,
        customers.customer_first_name,
        customers.customer_last_name,
        customer_orders.first_order_date,
        customer_orders.most_recent_order_date,
        coalesce(customer_orders.number_of_orders, 0) as number_of_orders

    from {{ ref("stg_jaffle_shop__customers") }} as customers

    left join customer_orders on customers.customer_id = customer_orders.customer_id

)

select *
from final
