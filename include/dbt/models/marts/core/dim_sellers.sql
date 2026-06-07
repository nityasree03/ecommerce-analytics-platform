with sellers as (

    select * from {{ ref('stg_sellers') }}

),

seller_performance as (

    select
        o.order_id,
        i.seller_id,
        o.order_value,
        o.is_on_time,
        o.review_score,
        o.ordered_at
    from {{ ref('fct_orders') }} o
    join {{ ref('stg_order_items') }} i
        on o.order_id = i.order_id

),

seller_metrics as (

    select
        seller_id,
        count(distinct order_id)        as total_orders,
        sum(order_value)                as total_gmv,
        avg(order_value)                as avg_order_value,
        avg(review_score)               as avg_review_score,
        countif(is_on_time) /
            nullif(count(*), 0)         as otd_rate,
        min(ordered_at)                 as first_sale_at,
        max(ordered_at)                 as last_sale_at
    from seller_performance
    group by seller_id

),

final as (

    select
        -- primary key
        {{ dbt_utils.generate_surrogate_key(['s.seller_id']) }}
                                                as seller_key,

        -- natural key
        s.seller_id,

        -- location
        s.city,
        s.state,
        s.zip_code_prefix,

        -- performance
        coalesce(m.total_orders, 0)             as total_orders,
        coalesce(m.total_gmv, 0)                as total_gmv,
        coalesce(m.avg_order_value, 0)          as avg_order_value,
        coalesce(m.avg_review_score, 0)         as avg_review_score,
        coalesce(m.otd_rate, 0)                 as otd_rate,
        m.first_sale_at,
        m.last_sale_at,

        -- seller tier
        case
            when coalesce(m.total_gmv, 0) >= 50000  then 'Platinum'
            when coalesce(m.total_gmv, 0) >= 10000  then 'Gold'
            when coalesce(m.total_gmv, 0) >= 1000   then 'Silver'
            else 'Bronze'
        end                                     as gmv_tier

    from sellers s
    left join seller_metrics m on s.seller_id = m.seller_id

)

select * from final
