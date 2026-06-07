with orders as (

    select * from {{ ref('fct_orders') }}
    where is_delivered = true

),

customers as (

    select * from {{ ref('stg_customers') }}

),

customer_orders as (

    select
        c.customer_unique_id,
        o.ordered_at,
        date_trunc(
            cast(o.ordered_at as date), month
        )                                   as order_month

    from orders o
    join customers c on o.customer_id = c.customer_id

),

cohorts as (

    select
        customer_unique_id,
        min(order_month)                    as cohort_month
    from customer_orders
    group by customer_unique_id

),

cohort_orders as (

    select
        c.customer_unique_id,
        c.cohort_month,
        co.order_month,
        date_diff(co.order_month, c.cohort_month, month)
                                            as months_since_first_order
    from cohorts c
    join customer_orders co
        on c.customer_unique_id = co.customer_unique_id

),

cohort_sizes as (

    select
        cohort_month,
        count(distinct customer_unique_id)  as cohort_size
    from cohorts
    group by cohort_month

),

retention as (

    select
        co.cohort_month,
        co.months_since_first_order,
        count(distinct co.customer_unique_id)
                                            as retained_customers,
        cs.cohort_size
    from cohort_orders co
    join cohort_sizes cs on co.cohort_month = cs.cohort_month
    group by
        co.cohort_month,
        co.months_since_first_order,
        cs.cohort_size

)

select
    cohort_month,
    months_since_first_order,
    retained_customers,
    cohort_size,
    round(
        retained_customers / nullif(cohort_size, 0) * 100
    , 2)                                    as retention_rate_pct
from retention
order by cohort_month, months_since_first_order
