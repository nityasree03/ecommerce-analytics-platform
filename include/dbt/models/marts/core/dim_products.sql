with products as (

    select * from {{ ref('stg_products') }}

),

translations as (

    select * from {{ ref('stg_product_translations') }}

),

order_items as (

    select
        product_id,
        count(order_id)         as total_orders,
        avg(item_price)         as avg_price,
        sum(item_price)         as total_revenue
    from {{ ref('stg_order_items') }}
    group by product_id

),

final as (

    select
        -- primary key
        {{ dbt_utils.generate_surrogate_key(['p.product_id']) }}
                                                as product_key,

        -- natural key
        p.product_id,

        -- category
        p.category_name_portuguese,
        coalesce(t.product_category_name_english,
                 p.category_name_portuguese)    as category_name_english,

        -- attributes
        p.weight_g,
        p.length_cm,
        p.height_cm,
        p.width_cm,
        p.photos_count,

        -- performance metrics
        coalesce(i.total_orders, 0)             as total_orders,
        coalesce(i.avg_price, 0)                as avg_price,
        coalesce(i.total_revenue, 0)            as total_revenue

    from products p
    left join translations t    on p.category_name_portuguese
                                 = t.product_category_name
    left join order_items i     on p.product_id = i.product_id

)

select * from final
