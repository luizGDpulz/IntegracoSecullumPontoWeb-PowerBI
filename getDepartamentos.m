let
  getToken = Json.Document(
      Web.Contents(
          urlToken,
          [
              Headers = [#"Accept"="application/json", #"Content-Type"="application/x-www-form-urlencoded;charset=utf-8"],
              Content = Text.ToBinary("grant_type=password&username="&username&"&password="&password&"&client_id=3")
          ]
  )),
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
