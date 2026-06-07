with source as (

    select * from {{ source('olist', 'raw_payments') }}

),

renamed as (

    select
        -- foreign key
        order_id,

        -- payment details
        payment_sequential      as payment_sequence,
        payment_type,
        payment_installments    as installments,
        payment_value,

        -- metadata
        current_timestamp()     as _loaded_at

    from source
    where order_id is not null

)

select * from renamed
