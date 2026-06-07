with orders as (

    select * from {{ ref('stg_orders') }}

),

order_items as (

    select
        order_id,
        count(order_item_id)        as item_count,
        sum(item_price)             as subtotal,
        sum(freight_value)          as total_freight,
        sum(total_item_value)       as order_value
    from {{ ref('stg_order_items') }}
    group by order_id

),

payments as (

    select
        order_id,
        sum(payment_value)          as total_payment_value,
        max(installments)           as max_installments,
        count(payment_sequence)     as payment_method_count,
        max(payment_type)           as primary_payment_type
    from {{ ref('stg_payments') }}
    group by order_id

),

reviews as (

    select
        order_id,
        avg(review_score)           as avg_review_score,
        max(review_score)           as review_score
    from {{ ref('stg_reviews') }}
    group by order_id

),

enriched as (

    select
        -- order identifiers
        o.order_id,
        o.customer_id,

        -- order status and timing
        o.order_status,
        o.ordered_at,
        o.approved_at,
        o.shipped_at,
        o.delivered_at,
        o.estimated_delivery_at,
        o.delivery_delay_days,

        -- order financials
        coalesce(i.item_count, 0)           as item_count,
        coalesce(i.subtotal, 0)             as subtotal,
        coalesce(i.total_freight, 0)        as total_freight,
        coalesce(i.order_value, 0)          as order_value,

        -- payment details
        coalesce(p.total_payment_value, 0)  as total_payment_value,
        coalesce(p.max_installments, 1)     as max_installments,
        coalesce(p.payment_method_count, 1) as payment_method_count,
        p.primary_payment_type,

        -- customer satisfaction
        coalesce(r.review_score, 0)         as review_score,

        -- derived flags
        case
            when o.delivery_delay_days <= 0 then true
            else false
        end as is_on_time,

        case
            when o.order_status = 'delivered' then true
            else false
        end as is_delivered

    from orders o
    left join order_items i  on o.order_id = i.order_id
    left join payments p     on o.order_id = p.order_id
    left join reviews r      on o.order_id = r.order_id

)

select * from enriched
