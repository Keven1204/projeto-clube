# 0003. Deduplicação no staging

## Contexto

`clients.csv` repete `C1` com o mesmo conteúdo e repete `C6` com a cidade vazia numa das linhas. `transactions.csv` traz `T035` e `T036` com o mesmo cliente, ativo, operação, quantidade, preço e data. A chave da análise precisa ser única depois do staging.

## Decisão

A macro `deduplicate` numera as linhas por chave e fica com a primeira. Em cliente, a ordenação prioriza quem tem cidade preenchida e, em seguida, a data de cadastro. Em transação, a chave de negócio é cliente, ativo, operação, quantidade, preço e data; permanece o menor `transaction_id`.

## Consequência

`stg_clients` tem um registro por `client_id` e `stg_transactions` tem um por `transaction_id`. O teste `unique` na seed continua avisando a duplicata original. A escolha do menor identificador é estável: rodar de novo não troca a linha que permanece.
