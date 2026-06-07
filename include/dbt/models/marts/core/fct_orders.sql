with orders as (

    select * from {{ ref('int_orders_enriched') }}

),

final as (

    select
        -- primary key
        order_id,

        -- foreign keys
        customer_id,

        -- order details
        order_status,
        ordered_at,
        approved_at,
        shipped_at,
        delivered_at,
        estimated_delivery_at,

        -- delivery performance
        delivery_delay_days,
        is_on_time,
        is_delivered,

        -- financials
        item_count,
        subtotal,
        total_freight,
        order_value,
        total_payment_value,

        -- payment details
        max_installments,
        payment_method_count,
        primary_payment_type,

        -- satisfaction
        review_score,

        -- date dimensions for partitioning
        date(ordered_at)                        as order_date,
        extract(year from ordered_at)           as order_year,
        extract(month from ordered_at)          as order_month,
        extract(dayofweek from ordered_at)      as order_day_of_week,
        case
            when extract(dayofweek from ordered_at) in (1, 7)
            then true else false
        end                                     as is_weekend_order

    from orders

)

select * from final
