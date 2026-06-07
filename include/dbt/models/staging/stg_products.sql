with source as (

    select * from {{ source('olist', 'raw_products') }}

),

renamed as (

    select
        -- primary key
        product_id,

        -- attributes
        product_category_name           as category_name_portuguese,
        product_name_lenght             as product_name_length,
        product_description_lenght      as product_description_length,
        product_photos_qty              as photos_count,

        -- dimensions
        product_weight_g                as weight_g,
        product_length_cm               as length_cm,
        product_height_cm               as height_cm,
        product_width_cm                as width_cm,

        -- metadata
        current_timestamp()             as _loaded_at

    from source
    where product_id is not null

)

select * from renamed
