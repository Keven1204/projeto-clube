{{ config(severity='warn', store_failures=true) }}

select
    client_id,
    client_name,
    asset_ticker,
    net_quantity,
    net_amount
from {{ ref('mart_client_portfolio') }}
where net_quantity < 0
