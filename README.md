# Carteira de clientes

Projeto dbt que transforma o cadastro e as movimentações de uma corretora fictícia em modelos analíticos. O critério de entrega é `dbt seed`, `dbt run` e `dbt test` terminarem sem erro.

Os CSVs não são editados. Problema de origem aparece como `WARN` e fica gravado no schema `audit`. Modelo já tratado só passa com `PASS`.

## Pré-requisitos

- Docker
- Python 3.10, 3.11 ou 3.12. O dbt 1.10 não sobe no Python 3.14.

## Execução

Na raiz do projeto.

```powershell
docker compose up -d
python -m venv .venv
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
$env:DBT_PROFILES_DIR = "."
dbt seed
dbt run
dbt test
```

Se o comando `dbt` mostrar `dbt 2.0.6`, esse é o dbt Fusion e ele não executa este projeto no Windows: o adapter de PostgreSQL falha ao carregar a biblioteca. O comando do desafio usa o dbt-core 1.10 do virtualenv. Ative o ambiente, ou chame o executável direto:

```powershell
$env:DBT_PROFILES_DIR = "."
.\.venv\Scripts\dbt.exe run
.\.venv\Scripts\dbt.exe test
```

```bash
docker compose up -d
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
export DBT_PROFILES_DIR=.
dbt seed
dbt run
dbt test
```

O `.env` é opcional. Host, porta, usuário, senha e banco já têm o mesmo padrão do `docker-compose.yml` (`localhost`, `5432`, `clube`, `clube`, `clube`).

## Resultado esperado

`dbt seed` e `dbt run` terminam com `ERROR=0`. `dbt test` termina com código 0: `PASS=67`, `WARN=5`, `ERROR=0`. Os testes dos modelos e os unit tests ficam em `PASS`. Os cinco `WARN` são a detecção pedida pelo desafio:

| Teste | O que aponta |
| --- | --- |
| `unique` de `clients.client_id` | `C1` repetido e `C6` repetido com cidade vazia |
| `not_null` de `transactions.client_id` | movimentação `T021` sem cliente |
| `transactions_quantity_is_positive` | movimentação `T037` com quantidade `-50` |
| combinação única da chave de negócio | `T035` e `T036` com o mesmo conteúdo |
| `assert_no_negative_position` | posição líquida negativa no mart |

O teste singular devolve 6 posições, todas venda sem compra suficiente: C1/BBDC4 -50, C3/WEGE3 -30, C5/BBDC4 -400, C6/ITUB4 -50, C7/WEGE3 -60 e C8/VALE3 -30. As linhas ficam em `audit.assert_no_negative_position`.

```sql
select client_id, asset_ticker, net_quantity, net_amount
from audit.assert_no_negative_position
order by client_id, asset_ticker;
```

## Linhagem

```text
raw.clients        -> staging.stg_clients        -> marts.dim_clients
raw.transactions   -> staging.stg_transactions   -> intermediate.int_transactions
                                                      -> marts.fact_transactions
                                                          -> marts.mart_client_portfolio
```

| Modelo | Grão |
| --- | --- |
| `stg_transactions`, `int_transactions`, `fact_transactions` | uma transação |
| `stg_clients`, `dim_clients` | um cliente |
| `mart_client_portfolio` | um cliente e um ativo |

## Problemas e decisões

| Problema | Decisão |
| --- | --- |
| `C1` duplicado | deduplicação por `client_id` no staging |
| `C6` duplicado, um deles sem cidade | fica o registro com cidade preenchida |
| `T021` sem cliente | sai no filtro do staging |
| `T037` com quantidade negativa | sai no filtro do staging |
| `T035` e `T036` iguais | fica o menor `transaction_id` |
| posição negativa | permanece no mart; o teste singular avisa |

A posição negativa é venda sem compra suficiente na origem. Corrigir isso no mart esconderia o problema que o teste precisa mostrar.

## Incremental

`fact_transactions` usa `delete+insert` com `unique_key = transaction_id`. A cada execução entra o que tem `transaction_date` maior ou igual à maior data já carregada. O dia da fronteira é reprocessado para não perder lançamento atrasado do mesmo dia. Lançamento atrasado de uma data anterior pede carga completa:

```powershell
dbt run --select fact_transactions --full-refresh
```

## Requisitos

- [x] Seeds em `seeds/` e carga com `dbt seed`
- [x] Staging com snake_case, tipo e filtro de inválido
- [x] `mart_client_portfolio` com posição líquida de quantidade e de valor
- [x] `not_null`, `unique` e `accepted_values` nos YAML de cada camada (`_stg__models.yml`, `_int__models.yml`, `_marts__models.yml` e `seeds/_seeds.yml`), no lugar de um único `schema.yml`
- [x] Teste singular `assert_no_negative_position`
- [x] Descrição de modelo e de coluna, gravada também no PostgreSQL
- [x] `fact_transactions` incremental por `transaction_date`
- [x] Macros `normalize_text`, `deduplicate` e `signed_by_operation`

## Qual dbt usar

Depois de ativar o virtualenv, `dbt --version` precisa mostrar `installed: 1.10.23`. Se mostrar `2.x`, o comando no `PATH` é o dbt Fusion. Esse binário não executa este projeto: o adapter de PostgreSQL não é suportado. Use o executável do virtualenv:

```powershell
$env:DBT_PROFILES_DIR = "."
.\.venv\Scripts\dbt.exe seed
.\.venv\Scripts\dbt.exe run
.\.venv\Scripts\dbt.exe test
```

## Decisões

O registro das decisões de arquitetura está em [docs/adr](docs/adr/README.md), em português do Brasil.

## Documentação e CI

```powershell
dbt docs generate
dbt docs serve
```

O workflow em `.github/workflows/ci.yml` sobe um PostgreSQL limpo e executa `dbt seed`, `dbt run`, `dbt test` e o lint. A pasta `ai/` descreve o uso futuro por agente e não participa desses comandos.
