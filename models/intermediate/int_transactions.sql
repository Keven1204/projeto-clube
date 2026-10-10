with transactions as (
    select * from {{ ref('stg_transactions') }}
),

clients as (
    select * from {{ ref('stg_clients') }}
)

select
    transactions.transaction_id,
    transactions.client_id,
    clients.client_name,
    transactions.asset_ticker,
    transactions.operation,
    transactions.quantity,
    transactions.unit_price,
    (transactions.quantity * transactions.unit_price)::numeric(18, 4) as gross_amount,
    ({{ signed_by_operation('transactions.operation', 'transactions.quantity') }})::numeric(18, 4)
        as signed_quantity,
    ({{ signed_by_operation(
        'transactions.operation',
        'transactions.quantity * transactions.unit_price'
    ) }})::numeric(18, 4) as signed_amount,
    transactions.transaction_date
from transactions
inner join clients
    on transactions.client_id = clients.client_id
