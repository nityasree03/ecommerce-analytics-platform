with source as (

    select * from {{ source('olist', 'raw_sellers') }}

),

renamed as (

    select
        -- primary key
        seller_id,

        -- location
        seller_zip_code_prefix  as zip_code_prefix,
        seller_city             as city,
        seller_state            as state,

        -- metadata
        current_timestamp()     as _loaded_at

    from source
    where seller_id is not null

)

select * from renamed
