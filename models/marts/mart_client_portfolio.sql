with transactions as (
    select * from {{ ref('fact_transactions') }}
),

clients as (
    select * from {{ ref('dim_clients') }}
),

positions as (
    select
        client_id,
        asset_ticker,
        sum(case when operation = 'BUY' then quantity else 0 end)::numeric(18, 4) as bought_quantity,
        sum(case when operation = 'SELL' then quantity else 0 end)::numeric(18, 4) as sold_quantity,
        sum(signed_quantity)::numeric(18, 4) as net_quantity,
        sum(case when operation = 'BUY' then gross_amount else 0 end)::numeric(18, 4) as bought_amount,
        sum(case when operation = 'SELL' then gross_amount else 0 end)::numeric(18, 4) as sold_amount,
        sum(signed_amount)::numeric(18, 4) as net_amount,
        max(transaction_date) as last_transaction_date
    from transactions
    group by client_id, asset_ticker
)

select
    positions.client_id,
    clients.client_name,
    positions.asset_ticker,
    positions.bought_quantity,
    positions.sold_quantity,
    positions.net_quantity,
    positions.bought_amount,
    positions.sold_amount,
    positions.net_amount,
    positions.last_transaction_date
from positions
inner join clients
    on positions.client_id = clients.client_id
