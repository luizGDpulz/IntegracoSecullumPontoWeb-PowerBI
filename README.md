# Integração Secullum Ponto Web - Power BI

![Power BI](https://img.shields.io/badge/Power%20BI-Integration-yellow?style=for-the-badge&logo=powerbi) ![API](https://img.shields.io/badge/API-REST-blue?style=for-the-badge)

## Introdução

Este repositório documenta a integração entre o Secullum Ponto Web e o Power BI, permitindo a extração, processamento e análise de dados via API. Aqui, são apresentados snippets de código para a obtenção de informações sobre funcionários, departamentos e cálculo de horas, além de um guia detalhado sobre a implementação e uso adequado dessas funcionalidades.

## Requisitos

- **Power BI Desktop**
- **Acesso à API do Secullum Ponto Web**
- **Credenciais de autenticação válidas**
- **Conhecimento intermediário em Power Query (M)**
- **Configuração de parâmetros no Power BI para requisições dinâmicas**

## Fundamentos da Linguagem Power Query (M)

A linguagem Power Query (M) é funcional e projetada para manipulação e transformação de dados. Sua sintaxe estruturada permite a construção de pipelines eficientes de processamento de dados antes da carga no Power BI.

### Conceitos essenciais:

- **Bloco `let ... in`**: Estrutura que define variáveis e retorna valores no escopo da consulta.
- **Funções essenciais**: `Json.Document`, `Web.Contents`, `Table.FromRecords` são fundamentais para ingestão e transformação de dados.
- **Autenticação HTTP**: Uso de tokens `Bearer` para acessar APIs protegidas.

## Configuração de Parâmetros no Power BI

Para tornar as consultas mais dinâmicas e adaptáveis, utilizamos parâmetros configuráveis no Power BI Desktop. Eles permitem modificar URLs, credenciais e outras informações sem a necessidade de alterar o código.

### Como criar um parâmetro:

1. No Power BI, vá para `Gerenciar Parâmetros > Novo Parâmetro`.
2. Escolha um nome adequado (ex.: `urlToken`, `username`, `password`, `id_banco`).
3. Selecione o tipo de dado apropriado e forneça um valor padrão.
4. Confirme clicando em `OK` e utilize o parâmetro dentro das consultas.

## Autenticação e Obtenção do Token

```m
let
    getToken = Json.Document(
        Web.Contents(
            urlToken,
            [
                Headers = [#"Accept"="application/json", #"Content-Type"="application/x-www-form-urlencoded;charset=utf-8"],
                Content = Text.ToBinary("grant_type=password&username=" & username & "&password=" & password & "&client_id=3")
            ]
        )
    )
in
    getToken
```

Este trecho realiza a autenticação na API e recupera um token de acesso para futuras requisições HTTP.

## Obtendo Dados dos Funcionários

[Clique aqui para acessar o código completo](#)

```m
let
    token = getToken[access_token],
    authToken = "Bearer " & token,
    getDados = Json.Document(
        Web.Contents(
            urlFuncionarios,
            [
                Headers=[
                    Authorization=authToken,
                    secullumidbancoselecionado=id_banco
                ]
            ]
        )
    )
in
    getDados
```

Este código retorna uma lista de funcionários cadastrados no sistema.

## Cálculo de Horas para um Funcionário

[Clique aqui para acessar o código completo](#)

```m
let
    token = getToken[access_token],
    authToken = "Bearer " & token,

    jsonBody = "{\n    \"funcionarioPis\": \"\",\n    \"funcionarioCpf\": \"112.226.969-24\",\n    \"dataInicial\": \"2025-03-22\",\n    \"dataFinal\": \"2025-03-25\",\n    \"centrosDeCustos\": [\"string\"]\n}",

    response = Json.Document(
        Web.Contents(
            urlCalcular,
            [
                Headers = [
                    Authorization = authToken,
                    secullumidbancoselecionado = id_banco,
                    #"Content-Type" = "application/json"
                ],
                Content = Text.ToBinary(jsonBody)
            ]
        )
    ),

    colunas = response[Colunas],
    linhas = response[Linhas],
    totais = response[Totais],
    
    linhasTransformadas = List.Transform(linhas, each
        Record.FromList(
            _[Value],
            colunas
        )
    ),
    
    tabela = Table.FromRecords(linhasTransformadas),
    tabelaComTotais = Table.InsertRows(
        tabela,
        Table.RowCount(tabela),
        {Record.FromList(totais, colunas)}
    )

in
    tabelaComTotais
```

Este código retorna o cálculo detalhado das horas trabalhadas por um funcionário em um determinado período, considerando suas informações e centro de custos.

## Obtendo Dados dos Departamentos

[Clique aqui para acessar o código completo](#)

```m
let
    token = getToken[access_token],
    authToken = "Bearer " & token,
    getDados = Json.Document(
        Web.Contents(
            urlDepartamentos,
            [
                Headers=[
                    Authorization=authToken,
                    secullumidbancoselecionado=id_banco
                ]
            ]
        )
    )
in
    getDados
```

Este código recupera os dados de todos os departamentos cadastrados.

## Observações Finais

- Para evitar conflitos ao incluir exemplos de Markdown, substitua os acentos graves internos (`) por caracteres similares (`´`).
- Pelo menos um dos campos `funcionarioCpf` ou `funcionarioPis` deve ser preenchido.
- Os campos de data são obrigatórios.
- Caso não deseje filtrar por centro de custos, utilize o valor "string".
- Certifique-se de que as credenciais fornecidas tenham permissão para acessar os endpoints desejados.

Com este guia, você terá as ferramentas necessárias para realizar uma integração eficiente entre o Secullum Ponto Web e o Power BI. Em caso de dúvidas ou sugestões, contribua com o repositório ou entre em contato!

