with source as (

    select * from {{ source('olist', 'raw_geolocation') }}

),

renamed as (

    select
        -- location key
        geolocation_zip_code_prefix as zip_code_prefix,

        -- coordinates
        geolocation_lat             as latitude,
        geolocation_lng             as longitude,

        -- place names
        geolocation_city            as city,
        geolocation_state           as state,

        -- metadata
        current_timestamp()         as _loaded_at

    from source
    where geolocation_zip_code_prefix is not null

)

select * from renamed
