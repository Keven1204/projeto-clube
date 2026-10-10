# 0002. Problemas de qualidade sinalizados como aviso

## Contexto

Os CSVs trazem defeitos de propósito: cliente duplicado, cliente sem cidade, transação sem cliente, quantidade negativa e lançamento repetido. O enunciado pede que os testes apontem esses problemas, sem limpar o arquivo à mão. O critério eliminatório é `dbt test` terminar sem erro.

## Decisão

Os CSVs entram em `seeds/` sem edição, como texto. O staging descarta o que não serve para análise. Os testes que existem para mostrar o defeito na origem usam `severity: warn` e `store_failures: true`. As linhas ficam no schema `audit`. Os testes dos modelos já tratados continuam com severidade de erro e precisam passar.

## Consequência

`dbt test` sai com código 0 e lista cinco avisos. Um aviso não quebra o encadeamento `dbt run && dbt test`. Esconder a posição negativa no mart faria o teste singular passar calado, e isso contraria o enunciado.
