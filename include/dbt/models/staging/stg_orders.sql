with source as (

    select * from {{ source('olist', 'raw_orders') }}

),

renamed as (

    select
        -- primary key
        order_id,

        -- foreign keys
        customer_id,

        -- order status
        order_status,

        -- timestamps
        cast(order_purchase_timestamp as timestamp)     as ordered_at,
        cast(order_approved_at as timestamp)            as approved_at,
        cast(order_delivered_carrier_date as timestamp) as shipped_at,
        cast(order_delivered_customer_date as timestamp)as delivered_at,
        cast(order_estimated_delivery_date as timestamp)as estimated_delivery_at,

        -- derived metrics
        date_diff(
            cast(order_delivered_customer_date as date),
            cast(order_estimated_delivery_date as date),
            day
        ) as delivery_delay_days,

        -- metadata
        current_timestamp() as _loaded_at

    from source
    where order_id is not null

)

select * from renamed
