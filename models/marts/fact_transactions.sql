{{
    config(
        materialized='incremental',
        unique_key='transaction_id',
        incremental_strategy='delete+insert',
        on_schema_change='append_new_columns'
    )
}}

with transactions as (
    select * from {{ ref('int_transactions') }}
)

select
    transactions.transaction_id,
    transactions.client_id,
    transactions.client_name,
    transactions.asset_ticker,
    transactions.operation,
    transactions.quantity,
    transactions.unit_price,
    transactions.gross_amount,
    transactions.signed_quantity,
    transactions.signed_amount,
    transactions.transaction_date
from transactions
{% if is_incremental() %}
    where transactions.transaction_date >= (
        select max(loaded.transaction_date) as transaction_date
        from {{ this }} as loaded
    )
{% endif %}
