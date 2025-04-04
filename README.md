# Integração Secullum Ponto Web - Power BI

![Power BI](https://img.shields.io/badge/Power%20BI-Integration-yellow?style=for-the-badge&logo=powerbi) ![API](https://img.shields.io/badge/API-REST-blue?style=for-the-badge)

## Sumário

- [Introdução](#introdução)
- [Requisitos](#requisitos)
- [Introdução ao Power Query (M)](#introdução-ao-power-query-m)
  - [Conceitos-chave](#conceitos-chave)
- [Criação de Parâmetros no Power BI](#criação-de-parâmetros-no-power-bi)
  - [Parâmetros necessários](#parâmetros-necessários)
  - [Procedimento](#procedimento)
- [Autenticação na API Secullum Ponto Web](#autenticação-na-api-secullum-ponto-web)
- [Exemplos Extração de Dados](#exemplos-extração-de-dados)
  - [1. Consulta de Funcionários](#1-consulta-de-funcionários)
  - [2. Dados da Tela de Cálculos](#2-dados-da-tela-de-calculos)
  - [3. Consulta de Departamentos](#3-consulta-de-departamentos)
- [Observações Finais](#observações-finais)

## Introdução

Este repositório documenta a integração entre o Power BI e o sistema Secullum Ponto Web, permitindo a extração e análise de informações com exemplos relacionados a funcionários, departamentos e tela de cálculos. Este guia fornece uma abordagem detalhada para implementar essa conexão, utilizando a linguagem **Power Query (M)** e interagindo com a API do Secullum Ponto Web.

## Requisitos

Para realizar a integração, certifique-se de ter:

- **Power BI Desktop** instalado.
- Credenciais válidas de acesso ao sistema **Secullum Ponto Web**.
- Habilitar a integração para o usuário dentro do **Secullum Ponto Web**.
- Conhecimento básico sobre **Power Query (M)** e manipulação de APIs REST.

## Introdução ao Power Query (M)

A linguagem **Power Query (M)** é utilizada no Power BI para importar e transformar dados. Ela permite a extração de informações de diferentes fontes e a estruturação dos dados de forma organizada e eficiente.

### Conceitos-chave:

- A estrutura da linguagem segue o formato **`let ... in`**, definindo variáveis e retornando resultados.
- A função **`Web.Contents`** permite interagir com APIs externas.
- Os dados podem ser transformados em tabelas organizadas para facilitar análises posteriores.

## Criação de Parâmetros no Power BI

Os parâmetros no Power BI permitem personalizar valores sem a necessidade de alteração direta do código.

### Parâmetros necessários:

Antes de executar os códigos abaixo, certifique-se de criar os seguintes parâmetros no Power BI:

- `username` - Nome de usuário para autenticação.

- `password` - Senha do usuário para autenticação.

- `id_banco` - Identificador do banco de dados da empresa dentro da API.

- `urlToken` - URL do endpoint de autenticação da API.

- `urlFuncionarios` - URL do endpoint para obter os dados dos funcionários.

- `urlCalcular` - URL do endpoint para cálculo de horas trabalhadas.

- `urlDepartamentos` - URL do endpoint para obtenção dos departamentos.

### Procedimento:

1. No Power BI, acesse `Gerenciar Parâmetros > Novo Parâmetro`.
2. Defina um nome apropriado (exemplo: `urlToken`, `username`, `password`).
3. Selecione o tipo de dado correspondente (em nosso ambiente selecione `Texto`).
4. Confirme clicando em `OK`.

## Autenticação na API Secullum Ponto Web

Este bloco de código realiza a autenticação na API, obtendo um **Token de Acesso** para requisições futuras.
[Código completo](getToken.m)
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

### Principais Características da Autenticação

#### Protocolo de Autenticação
- Utiliza **OAuth2** com fluxo `Resource Owner Password Credentials`
- Requer `client_id=3` (valor fixo para integração com Secullum)

#### Parâmetros Obrigatórios
- `urlToken`: Endpoint da API de autenticação
- `username`: Credencial do usuário (e-mail de login no Secullum Ponto Web)
- `password`: Senha do usuário (senha de login no Secullum Ponto Web)

#### Headers da Requisição
| Header | Valor | Descrição |
|--------|-------|-----------|
| `Accept` | `application/json` | Formato esperado para a resposta |
| `Content-Type` | `application/x-www-form-urlencoded` | Formato do payload enviado |

#### Medidas de Segurança
🔒 **Proteção de Dados:**
- Credenciais trafegadas exclusivamente no corpo da requisição (nunca na URL)
- Uso obrigatório de **HTTPS** (criptografia TLS)

⏱ **Validade:**
- O Token têm duração limitada (padrão: 1 hora / 3600 segundos)
- Exige renovação após expiração (código HTTP 401)

## Exemplos Extração de Dados

### 1. Consulta de Funcionários

Este trecho obtém a lista de funcionários registrados no banco do usuário.
[Código completo](getFuncionarios.m)

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

#### Características Principais
🔑 **Autenticação:**
- Utiliza token Bearer obtido previamente
- Requer `id_banco` para identificar o banco de dados corporativo

📦 **Estrutura da Requisição:**
- Método: GET implícito
- Headers:
  - `Authorization`: Token no formato Bearer
  - `secullumidbancoselecionado`: ID do banco de dados

🔄 **Processamento:**
1. Extrai token de acesso da autenticação prévia
2. Monta header de autorização
3. Consome endpoint REST de funcionários
4. Retorna payload JSON bruto
   
### 2. Dados da Tela de Calculos

Este bloco calcula as horas trabalhadas para um determinado funcionário.
[Código completo](getTelaCalculos.m)

```m
let
    token = getToken[access_token],
    authToken = "Bearer " & token,

    jsonBody = "{
        \"funcionarioPis\":\"PisDoFuncionario\",
        \"funcionarioCpf\":\"CpfDoFuncionario\",
        \"dataInicial\":\"DataInicialDoPeriodo\",
        \"dataFinal\":\"DataFinalDoPeriodo\",
        \"centrosDeCustos\":[\"string\"]
    }",

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
#### Fluxo de Processamento
1. **Preparação:**
   - Gera payload JSON com filtros:
     - CPF/PIS do funcionário
     - Período (dataInicial/dataFinal)
     - Centros de custo (opcional)

2. **Execução:**
   - Método: POST implícito
   - Headers:
     - `Content-Type: application/json`
     - Demais headers de autenticação

3. **Transformação:**
   - Converte resposta JSON em tabela estruturada
   - Adiciona linha de totais consolidados

⚠ **Regras de Validação:**
- Obrigatório informar CPF **ou** PIS
- Formato de datas: `YYYY-MM-DD`
- Campos de data são **obrigatórios**
- Para centros de custo sem filtro, usar `"string"`

### 3. Consulta de Departamentos

Este bloco retorna informações sobre os departamentos da empresa.
[Código completo](getDepartamentos.m)

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

#### Particularidades
📊 **Estrutura de Retorno:**
- Lista de departamentos
- Inclui metadados como id, descrição e número folha;

🔗 **Dependências:**
- Requer mesmo token de autenticação das demais consultas
- Compatível com estrutura de `id_banco` compartilhada

## Observações Finais

- Certifique-se de que as credenciais fornecidas tenham permissão para acessar os endpoints desejados.

Com este guia, você terá as ferramentas necessárias para realizar uma integração eficiente entre o Secullum Ponto Web e o Power BI. Em caso de dúvidas ou sugestões, contribua com o repositório ou entre em contato com o Suporte Secullum! 🚀
