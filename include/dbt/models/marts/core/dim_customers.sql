with customer_metrics as (

    select * from {{ ref('int_customer_metrics') }}

),

final as (

    select
        -- primary key
        {{ dbt_utils.generate_surrogate_key(['customer_unique_id']) }}
                                                as customer_key,

        -- natural key
        customer_unique_id,

        -- location
        city,
        state,

        -- purchase behavior
        total_orders,
        total_spent,
        avg_order_value,
        avg_review_score,
        is_repeat_customer,

        -- recency
        first_order_at,
        last_order_at,
        days_since_last_order,

        -- segmentation
        rfm_segment,
        rfm_total,
        recency_score,
        frequency_score,
        monetary_score,

        -- customer value tier
        case
            when total_spent >= 1000 then 'High Value'
            when total_spent >= 300  then 'Mid Value'
            else 'Low Value'
        end                                     as clv_tier

    from customer_metrics

)

select * from final
