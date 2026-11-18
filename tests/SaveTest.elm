module SaveTest exposing (suite)

import Dict
import Expect
import Office exposing (Estado(..))
import Save exposing (decodeProgresso, encodeProgresso)
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "save dicas"
        [ test "recarregar mantém quantas dicas estão abertas" <|
            \_ ->
                let
                    progresso =
                        Dict.singleton 2
                            { estado = EmAndamento, dicas = 3, verdade = False }
                in
                progresso
                    |> encodeProgresso
                    |> decodeProgresso
                    |> Dict.get 2
                    |> Expect.equal
                        (Just { estado = EmAndamento, dicas = 3, verdade = False })
        , test "save ilegível vira progresso vazio" <|
            \_ ->
                decodeProgresso "isto-não-é-json"
                    |> Expect.equal Dict.empty
        ]