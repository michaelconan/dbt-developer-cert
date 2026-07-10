with

payments as (select * from {{ source("stripe", "payment") }}),

renamed as (

    select
        id as payment_id,
        orderid as order_id,
        paymentmethod as payment_method,
        status as payment_status,
        -- source is stored as cents
        created as payment_created_at,
        _batched_at,
        amount / 100 as payment_amount

    from payments

)

select *
from renamed
