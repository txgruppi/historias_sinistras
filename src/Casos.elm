module Casos exposing (decodeCasos)

import Json.Decode as Decode exposing (Decoder)
import Office exposing (Caso)


decodeCasos : Decoder (List Caso)
decodeCasos =
    Decode.list decodeCaso


decodeCaso : Decoder Caso
decodeCaso =
    Decode.map3
        (\base dica4 verdade ->
            { base | dica4 = dica4, verdade = verdade }
        )
        baseDecoder
        (Decode.field "dica4" Decode.string)
        (Decode.field "verdade" Decode.string)


baseDecoder : Decoder Caso
baseDecoder =
    Decode.map7
        (\id titulo categoria dificuldade cenario dica1 dica2 ->
            { id = id
            , titulo = titulo
            , categoria = categoria
            , dificuldade = dificuldade
            , cenario = cenario
            , dica1 = dica1
            , dica2 = dica2
            , dica3 = ""
            , dica4 = ""
            , verdade = ""
            }
        )
        (Decode.field "id" Decode.int)
        (Decode.field "titulo" Decode.string)
        (Decode.field "categoria" Decode.string)
        (Decode.field "dificuldade" Decode.string)
        (Decode.field "cenario" Decode.string)
        (Decode.field "dica1" Decode.string)
        (Decode.field "dica2" Decode.string)
        |> Decode.andThen
            (\partial ->
                Decode.map (\dica3 -> { partial | dica3 = dica3 })
                    (Decode.field "dica3" Decode.string)
            )