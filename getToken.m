let
    getToken = Json.Document(
        Web.Contents(
            urlToken,
            [
                Headers = [#"Accept"="application/json", #"Content-Type"="application/x-www-form-urlencoded;charset=utf-8"],
                Content = Text.ToBinary("grant_type=password&username="&username&"&password="&password&"&client_id=3")
            ]
    ))
in
    getToken
