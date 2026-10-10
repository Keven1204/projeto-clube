with source as (
    select * from {{ ref('transactions') }}
),

typed as (
    select
        {{ normalize_text('transaction_id') }} as transaction_id,
        {{ normalize_text('client_id') }} as client_id,
        {{ normalize_text('asset_ticker') }} as asset_ticker,
        {{ normalize_text('operation') }} as operation,
        quantity::numeric(18, 4) as quantity,
        unit_price::numeric(18, 2) as unit_price,
        transaction_date::date as transaction_date
    from source
),

valid as (
    select
        transaction_id,
        client_id,
        asset_ticker,
        operation,
        quantity,
        unit_price,
        transaction_date
    from typed
    where
        client_id is not null
        and asset_ticker is not null
        and transaction_date is not null
        and quantity > 0
        and unit_price > 0
        and operation in ('BUY', 'SELL')
),

deduped as (
    {{ deduplicate(
        relation='valid',
        partition_by='client_id, asset_ticker, operation, quantity, unit_price, transaction_date',
        order_by='transaction_id'
    ) }}
)

select
    transaction_id,
    client_id,
    asset_ticker,
    operation,
    quantity,
    unit_price,
    transaction_date
from deduped
