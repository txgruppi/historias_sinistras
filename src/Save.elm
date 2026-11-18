module Save exposing (decodeProgresso, encodeProgresso, storageKey)

import Dict exposing (Dict)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Office exposing (Estado(..), PastaProgresso, Progresso)


storageKey : String
storageKey =
    "historias-sinistras.progresso"


encodeProgresso : Progresso -> String
encodeProgresso progresso =
    progresso
        |> Dict.toList
        |> List.filterMap
            (\( id, pasta ) ->
                if pasta.estado == Novo then
                    Nothing

                else
                    Just
                        ( String.fromInt id
                        , Encode.object
                            [ ( "estado", Encode.string (estadoToString pasta.estado) )
                            , ( "dicas", Encode.int pasta.dicas )
                            , ( "verdade", Encode.bool pasta.verdade )
                            ]
                        )
            )
        |> Encode.object
        |> Encode.encode 0


estadoToString : Estado -> String
estadoToString estado =
    case estado of
        Novo ->
            "Novo"

        EmAndamento ->
            "Em andamento"

        Resolvido ->
            "Resolvido"


decodeProgresso : String -> Progresso
decodeProgresso raw =
    case Decode.decodeString progressoDecoder raw of
        Ok progresso ->
            progresso

        Err _ ->
            Dict.empty


progressoDecoder : Decoder Progresso
progressoDecoder =
    Decode.dict pastaDecoder
        |> Decode.map
            (Dict.toList
                >> List.filterMap
                    (\( key, pasta ) ->
                        case String.toInt key of
                            Just id ->
                                if id >= 1 && id <= 60 then
                                    Just ( id, pasta )

                                else
                                    Nothing

                            Nothing ->
                                Nothing
                    )
                >> Dict.fromList
            )


pastaDecoder : Decoder PastaProgresso
pastaDecoder =
    Decode.map3 PastaProgresso
        (Decode.field "estado" estadoDecoder)
        (Decode.field "dicas" Decode.int)
        (Decode.field "verdade" Decode.bool)
        |> Decode.andThen validatePasta


estadoDecoder : Decoder Estado
estadoDecoder =
    Decode.string
        |> Decode.andThen
            (\s ->
                case s of
                    "Novo" ->
                        Decode.succeed Novo

                    "Em andamento" ->
                        Decode.succeed EmAndamento

                    "Resolvido" ->
                        Decode.succeed Resolvido

                    _ ->
                        Decode.fail "estado inválido"
            )


validatePasta : PastaProgresso -> Decoder PastaProgresso
validatePasta pasta =
    if pasta.dicas < 0 || pasta.dicas > 4 then
        Decode.fail "dicas inválidas"

    else
        Decode.succeed pasta