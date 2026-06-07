with orders as (

    select * from {{ ref('int_orders_enriched') }}

),

customers as (

    select * from {{ ref('stg_customers') }}

),

customer_orders as (

    select
        c.customer_unique_id,
        c.city,
        c.state,

        -- frequency
        count(distinct o.order_id)              as total_orders,

        -- monetary
        sum(o.order_value)                      as total_spent,
        avg(o.order_value)                      as avg_order_value,

        -- recency
        min(o.ordered_at)                       as first_order_at,
        max(o.ordered_at)                       as last_order_at,
        date_diff(
            current_date(),
            cast(max(o.ordered_at) as date),
            day
        )                                       as days_since_last_order,

        -- satisfaction
        avg(o.review_score)                     as avg_review_score,
        countif(o.is_on_time)                   as on_time_deliveries,

        -- repeat purchase flag
        case
            when count(distinct o.order_id) > 1
            then true else false
        end                                     as is_repeat_customer

    from customers c
    left join orders o on c.customer_id = o.customer_id
    where o.is_delivered = true
    group by
        c.customer_unique_id,
        c.city,
        c.state

),

rfm_scored as (

    select
        *,

        -- RFM quintile scoring (1=worst, 5=best)
        ntile(5) over (
            order by days_since_last_order desc
        )                                       as recency_score,

        ntile(5) over (
            order by total_orders asc
        )                                       as frequency_score,

        ntile(5) over (
            order by total_spent asc
        )                                       as monetary_score

    from customer_orders

),

segmented as (

    select
        *,
        recency_score + frequency_score + monetary_score as rfm_total,

        case
            when recency_score >= 4
             and frequency_score >= 4
             and monetary_score >= 4
            then 'Champions'

            when recency_score >= 3
             and frequency_score >= 3
            then 'Loyal Customers'

            when recency_score >= 4
             and frequency_score <= 2
            then 'New Customers'

            when recency_score <= 2
             and frequency_score >= 3
             and monetary_score >= 3
            then 'At Risk'

            when recency_score = 1
             and frequency_score = 1
            then 'Lost'

            else 'Potential Loyalists'
        end                                     as rfm_segment

    from rfm_scored

)

select * from segmented
