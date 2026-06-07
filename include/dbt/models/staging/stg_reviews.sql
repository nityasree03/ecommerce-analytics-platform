with source as (

    select * from {{ source('olist', 'raw_reviews') }}

),

renamed as (

    select
        -- primary key
        review_id,

        -- foreign key
        order_id,

        -- review content
        review_score,
        review_comment_title    as comment_title,
        review_comment_message  as comment_message,

        -- timestamps
        cast(review_creation_date as timestamp)     as review_created_at,
        cast(review_answer_timestamp as timestamp)  as review_answered_at,

        -- metadata
        current_timestamp()                         as _loaded_at

    from source
    where review_id is not null

)

select * from renamed
