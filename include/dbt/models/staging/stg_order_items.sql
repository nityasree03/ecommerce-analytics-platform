with source as (

    select * from {{ source('olist', 'raw_order_items') }}

),

renamed as (

    select
        -- primary key (composite)
        order_id,
        order_item_id,

        -- foreign keys
        product_id,
        seller_id,

        -- dates
        cast(shipping_limit_date as timestamp) as shipping_limit_at,

        -- financials
        price                                  as item_price,
        freight_value                          as freight_value,
        price + freight_value                  as total_item_value,

        -- metadata
        current_timestamp()                    as _loaded_at

    from source
    where order_id is not null

)

select * from renamed
