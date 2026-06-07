with customers as (

    select * from {{ ref('dim_customers') }}

),

segment_summary as (

    select
        rfm_segment,
        clv_tier,
        state,
        count(customer_unique_id)           as customer_count,
        avg(total_spent)                    as avg_lifetime_value,
        avg(total_orders)                   as avg_orders,
        avg(days_since_last_order)          as avg_recency_days,
        avg(avg_review_score)               as avg_satisfaction,
        sum(total_spent)                    as segment_revenue,
        countif(is_repeat_customer) /
            nullif(count(*), 0)             as repeat_rate

    from customers
    group by rfm_segment, clv_tier, state

)

select
    *,
    round(
        segment_revenue /
        nullif(sum(segment_revenue) over (), 0) * 100
    , 2)                                    as revenue_share_pct

from segment_summary
order by segment_revenue desc
