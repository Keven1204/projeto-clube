# 0001. PostgreSQL 16 como warehouse

## Contexto

O desafio pede um projeto dbt que rode a partir do README, com `dbt seed`, `dbt run` e `dbt test`. As sugestões de stack incluem PostgreSQL e BigQuery. BigQuery exige conta e credencial de quem avalia. DuckDB dispensa servidor, mas não é o warehouse pedido para esta entrega.

## Decisão

O warehouse é o PostgreSQL 16, sobe com `docker compose up -d` e usa usuário, senha e banco `clube` na porta 5432. O `profiles.yml` repete esses valores como padrão, então o `.env` é opcional.

## Consequência

Quem clona o repositório precisa de Docker e de Python 3.10, 3.11 ou 3.12. Não precisa de projeto no Google Cloud. O workflow de CI sobe o mesmo PostgreSQL num container de serviço.
