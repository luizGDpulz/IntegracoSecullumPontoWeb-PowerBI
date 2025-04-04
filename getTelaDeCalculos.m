let
    getToken = Json.Document(
        Web.Contents(
            urlToken,
            [
                Headers = [
                    #"Accept" = "application/json", 
                    #"Content-Type" = "application/x-www-form-urlencoded;charset=utf-8"
                ],
                Content = Text.ToBinary("grant_type=password&username=" & username & "&password=" & password & "&client_id=3")
            ]
        )
    ),
    token = getToken[access_token],
    authToken = "Bearer " & token,

    jsonBody = "{ 
        ""funcionarioPis"": ""PISFuncionarioAQUI"", 
        ""funcionarioCpf"": ""CPFFuncionarioAQUI"", 
        ""dataInicial"": ""DataInicialDoPeriodoAQUI"", 
        ""dataFinal"": ""DataFinalDoPeriodoAQUI"", 
        ""centrosDeCustos"": [""string""] 
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

    // Transformação do JSON em tabela 
    colunas = response[Colunas],
    linhas = response[Linhas],
    totais = response[Totais],
    
    // Converter linhas em registros 
    linhasTransformadas = List.Transform(linhas, each 
        Record.FromList(
            _[Value],  
            colunas
        )
    ),
    
    // Criar tabela a partir dos registros
    tabela = Table.FromRecords(linhasTransformadas),
    
    // Adicionar linha de totais
    tabelaComTotais = Table.InsertRows(
        tabela, 
        Table.RowCount(tabela), 
        {Record.FromList(totais, colunas)}
    )
in
    tabelaComTotais
