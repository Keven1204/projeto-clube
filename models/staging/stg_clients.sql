with source as (
    select * from {{ ref('clients') }}
),

typed as (
    select
        {{ normalize_text('client_id') }} as client_id,
        {{ normalize_text('name') }} as client_name,
        {{ normalize_text('city') }} as city,
        {{ normalize_text('state') }} as state,
        created_at::date as client_created_at
    from source
),

valid as (
    select
        client_id,
        client_name,
        city,
        state,
        client_created_at
    from typed
    where client_id is not null
),

deduped as (
    {{ deduplicate(
        relation='valid',
        partition_by='client_id',
        order_by='(city is null), client_created_at'
    ) }}
)

select
    client_id,
    client_name,
    city,
    state,
    client_created_at
from deduped
