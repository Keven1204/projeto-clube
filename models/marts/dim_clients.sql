with clients as (
    select * from {{ ref('stg_clients') }}
)

select
    client_id,
    client_name,
    city,
    state,
    client_created_at
from clients
