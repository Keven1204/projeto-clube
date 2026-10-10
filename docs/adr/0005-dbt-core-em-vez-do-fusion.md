# 0005. Execução com dbt-core, não com o Fusion

## Contexto

Neste Windows existem dois comandos chamados `dbt`. O dbt-core 1.10 está em `.venv\Scripts` e fala com o PostgreSQL pelo `dbt-postgres`. O dbt Fusion 2.0.6 está em `.local\bin`. O Fusion ainda não trata o PostgreSQL como adapter estável e, com o adapter experimental ligado, o driver falha ao carregar a biblioteca.

## Decisão

`dbt seed`, `dbt run` e `dbt test` usam o dbt-core 1.10 do virtualenv. O `requirements.txt` fixa `dbt-core` 1.10 e `dbt-postgres` 1.9. O perfil de terminal do workspace ativa esse virtualenv. O Fusion fica só como language server do editor.

## Consequência

`dbt --version` no terminal do projeto precisa mostrar `installed: 1.10.23`. Se mostrar `2.0.6`, o comando é o Fusion e o `dbt run` não constrói os modelos. O painel de linhagem do editor depende do Fusion e permanece vazio enquanto o adapter PostgreSQL não compilar. O grafo consultável é o de `dbt docs serve`.
