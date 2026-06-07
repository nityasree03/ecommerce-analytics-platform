with orders as (

    select * from {{ ref('fct_orders') }}
    where is_delivered = true

),

daily as (

    select
        order_date,
        order_year,
        order_month,
        count(distinct order_id)            as daily_orders,
        sum(order_value)                    as daily_revenue,
        avg(order_value)                    as daily_aov,
        countif(is_on_time) /
            nullif(count(*), 0)             as daily_otd_rate
    from orders
    group by order_date, order_year, order_month

),

with_rolling as (

    select
        *,

        -- 7-day rolling revenue
        sum(daily_revenue) over (
            order by order_date
            rows between 6 preceding and current row
        )                                   as revenue_7d_rolling,

        -- 30-day rolling revenue
        sum(daily_revenue) over (
            order by order_date
            rows between 29 preceding and current row
        )                                   as revenue_30d_rolling,

        -- day over day growth
        lag(daily_revenue) over (
            order by order_date
        )                                   as prev_day_revenue,

        -- month over month growth
        lag(daily_revenue, 30) over (
            order by order_date
        )                                   as prev_month_same_day_revenue

    from daily

)

select
    *,
    case
        when prev_day_revenue > 0
        then round(
            (daily_revenue - prev_day_revenue)
            / prev_day_revenue * 100, 2)
        else null
    end                                     as dod_growth_pct

from with_rolling
order by order_date
