with source as (

    select * from {{ source('olist', 'raw_customers') }}

),

renamed as (

    select
        -- primary key
        customer_id,

        -- natural key (the real customer identifier across orders)
        customer_unique_id,

        -- location
        customer_zip_code_prefix    as zip_code_prefix,
        customer_city               as city,
        customer_state              as state,

        -- metadata
        current_timestamp()         as _loaded_at

    from source
    where customer_id is not null

)

select * from renamed
