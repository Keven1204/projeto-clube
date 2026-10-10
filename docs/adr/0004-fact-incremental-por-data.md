# 0004. Fato incremental pela data da transação

## Contexto

O bônus pede `fact_transactions` incremental, com `transaction_date` como chave de controle. Uma carga completa a cada execução é simples, mas não demonstra o incremental. Uma marca d'água só com `>` perde lançamento que chega no mesmo dia depois da carga.

## Decisão

A materialização é incremental, com `unique_key = transaction_id` e estratégia `delete+insert`. O filtro reaplica o último dia já carregado:

```sql
where transaction_date >= (select max(transaction_date) from {{ this }})
```

O `delete+insert` apaga a chave que volta e insere de novo, então o dia da fronteira não duplica.

## Consequência

A segunda execução mexe só nas transações da data máxima e a contagem da fato permanece. Lançamento atrasado de um dia anterior não entra nessa janela. Nesse caso a carga é `dbt run --select fact_transactions --full-refresh`.
