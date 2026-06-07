with source as (

    select * from {{ source('olist', 'raw_product_translations') }}

),

renamed as (

    select
        product_category_name,
        product_category_name_english,
        current_timestamp() as _loaded_at

    from source
    where product_category_name is not null

)

select * from renamed
