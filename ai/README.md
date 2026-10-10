# Preparação para IA

Este diretório não entra em `dbt seed`, `dbt run` nem `dbt test`. Não há chamada de modelo de linguagem nesse fluxo.

## O que um agente já pode usar

Os três marts são públicos e têm contrato de coluna. O grão está na descrição de cada um:

- `dim_clients`: um cliente
- `fact_transactions`: uma transação
- `mart_client_portfolio`: um cliente e um ativo

A descrição de modelo e de coluna também fica como comentário no PostgreSQL. `dbt docs generate` grava `target/manifest.json`, com linhagem e testes. Seed e staging são detalhe interno. Isso é convenção deste projeto: o servidor MCP não impede uma consulta a `raw`.

## Servidor MCP

O exemplo abaixo sobe o `dbt-mcp` só com a CLI local. Semantic Layer, Discovery, Admin API e SQL da dbt platform ficam desligados. Este repositório não tem conta na dbt platform. O arquivo fica na máquina de quem clona, fora do Git.

```json
{
  "mcpServers": {
    "dbt": {
      "command": "uvx",
      "args": ["dbt-mcp"],
      "env": {
        "DBT_PROJECT_DIR": "C:/caminho/deste/clone",
        "DBT_PATH": "C:/caminho/deste/clone/.venv/Scripts/dbt.exe",
        "DBT_PROFILES_DIR": "C:/caminho/deste/clone",
        "DISABLE_SEMANTIC_LAYER": "true",
        "DISABLE_DISCOVERY": "true",
        "DISABLE_ADMIN_API": "true",
        "DISABLE_SQL": "true"
      }
    }
  }
}
```

Os caminhos são absolutos de propósito. `.` não funciona, porque o processo não sobe na raiz do repositório. Quem clonar o projeto troca estes três valores:

- `DBT_PROJECT_DIR`: pasta do `dbt_project.yml`
- `DBT_PROFILES_DIR`: a mesma pasta, onde está o `profiles.yml`
- `DBT_PATH`: o `dbt` do virtualenv, depois do `pip install`

No Windows, use barra normal (`C:/...`). Não aponte o servidor para o `.env`: ali `DBT_HOST` é o host do PostgreSQL, e o `dbt-mcp` lê `DBT_HOST` como host da dbt platform.

`DISABLE_SQL` não liga nem desliga consulta ao banco local. `execute_sql` e text-to-SQL são da dbt platform. No projeto, a consulta local é `dbt show` em cima dos marts.

## O que fica para depois

Semantic Layer, time spine e métricas de posição só entram quando existir uma pergunta de negócio recorrente e uma conta da dbt platform. Até lá, a resposta segura é SQL nos três marts.
