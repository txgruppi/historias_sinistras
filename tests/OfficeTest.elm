module OfficeTest exposing (..)

import Dict
import Expect
import Office exposing (..)
import Route exposing (fromHash, toHash)
import Save exposing (decodeProgresso, encodeProgresso)
import String
import Test exposing (Test, describe, test)


sampleCaso id titulo =
    { id = id
    , titulo = titulo
    , categoria = "ASSASSINATOS"
    , dificuldade = "FÁCIL"
    , cenario = "Texto do cenário " ++ String.fromInt id ++ "."
    , dica1 = "d1"
    , dica2 = "d2"
    , dica3 = "d3"
    , dica4 = "d4"
    , verdade = "v"
    }


casos60 =
    List.range 1 60 |> List.map (\n -> sampleCaso n ("Título " ++ String.fromInt n))


casoCustom id categoria dificuldade =
    { id = id
    , titulo = "Título " ++ String.fromInt id
    , categoria = categoria
    , dificuldade = dificuldade
    , cenario = "Texto do cenário " ++ String.fromInt id ++ "."
    , dica1 = "d1"
    , dica2 = "d2"
    , dica3 = "d3"
    , dica4 = "d4"
    , verdade = "v"
    }


casosVariados =
    [ casoCustom 1 "ASSASSINATOS" "FÁCIL"
    , casoCustom 2 "CRIMES IMPOSSÍVEIS" "MÉDIO"
    , casoCustom 3 "ASSASSINATOS" "MÉDIO"
    , casoCustom 4 "ACIDENTES FATAIS" "FÁCIL"
    ]


suite : Test
suite =
    describe "office ticket 01"
        [ describe "lista"
            [ test "título Histórias Sinistras e 60 pastas em ordem" <|
                \_ ->
                    let
                        vis =
                            Office.view casos60 Dict.empty filtroVazio visitaVazia Lista
                    in
                    case vis of
                        VisLista page ->
                            Expect.all
                                [ \_ -> Expect.equal page.tituloPagina "Histórias Sinistras"
                                , \_ ->
                                    page.linhas
                                        |> List.map .numero
                                        |> Expect.equal (List.range 1 60)
                                ]
                                ()

                        _ ->
                            Expect.fail "esperava lista"
            , test "cada linha mostra número, título, categoria, dificuldade e Novo" <|
                \_ ->
                    case Office.view casos60 Dict.empty filtroVazio visitaVazia Lista of
                        VisLista page ->
                            case List.head page.linhas of
                                Just linha ->
                                    Expect.all
                                        [ \_ -> Expect.equal linha.numero 1
                                        , \_ -> Expect.equal linha.titulo "Título 1"
                                        , \_ -> Expect.equal linha.categoria "Assassinatos"
                                        , \_ -> Expect.equal linha.dificuldade "Fácil"
                                        , \_ -> Expect.equal linha.estado "Novo"
                                        , \_ -> Expect.equal linha.detalhes []
                                        ]
                                        ()

                                Nothing ->
                                    Expect.fail "sem linhas"

                        _ ->
                            Expect.fail "esperava lista"
            ]
        , describe "capa e cenário"
            [ test "pasta Novo abre na capa com Ler o caso" <|
                \_ ->
                    let
                        ( _, saida ) =
                            Office.update casos60 Dict.empty filtroVazio visitaVazia Lista (AbrirPasta 1)
                    in
                    Expect.all
                        [ \_ -> Expect.equal saida.route (Pasta 1)
                        , \_ ->
                            case saida.visible of
                                VisCapa capa ->
                                    Expect.all
                                        [ \_ -> Expect.equal capa.numero 1
                                        , \_ -> Expect.equal capa.titulo "Título 1"
                                        , \_ -> Expect.equal capa.categoria "Assassinatos"
                                        , \_ -> Expect.equal capa.dificuldade "Fácil"
                                        , \_ ->
                                            Expect.equal capa.controles
                                                [ "Lista", "Próximo", "Ler o caso" ]
                                        ]
                                        ()

                                _ ->
                                    Expect.fail "esperava capa"
                        ]
                        ()
            , test "Ler o caso mostra o cenário e fica Em andamento" <|
                \_ ->
                    let
                        ( prog0, saida0 ) =
                            Office.update casos60 Dict.empty filtroVazio visitaVazia Lista (AbrirPasta 1)

                        ( prog1, saida1 ) =
                            Office.update casos60 prog0 filtroVazio visitaVazia saida0.route LerOCaso
                    in
                    Expect.all
                        [ \_ -> Expect.equal saida1.route (Pasta 1)
                        , \_ ->
                            case saida1.visible of
                                VisCenario cen ->
                                    Expect.all
                                        [ \_ -> Expect.equal cen.numero 1
                                        , \_ -> Expect.equal cen.cenario "Texto do cenário 1."
                                        , \_ ->
                                            Expect.equal cen.controles
                                                [ "Lista", "Próximo" ]
                                        ]
                                        ()

                                _ ->
                                    Expect.fail "esperava cenário"
                        , \_ ->
                            case Dict.get 1 prog1 of
                                Just pasta ->
                                    Expect.all
                                        [ \_ -> Expect.equal pasta.estado EmAndamento
                                        , \_ -> Expect.equal pasta.dicas 0
                                        , \_ -> Expect.equal pasta.verdade False
                                        ]
                                        ()

                                Nothing ->
                                    Expect.fail "sem progresso"
                        ]
                        ()
            , test "pasta Em andamento abre no cenário, não na capa" <|
                \_ ->
                    let
                        progresso =
                            Dict.singleton 1
                                { estado = EmAndamento, dicas = 0, verdade = False }

                        ( _, saida ) =
                            Office.update casos60 progresso filtroVazio visitaVazia Lista (AbrirPasta 1)
                    in
                    Expect.all
                        [ \_ -> Expect.equal saida.route (Pasta 1)
                        , \_ ->
                            case saida.visible of
                                VisCenario cen ->
                                    Expect.equal cen.cenario "Texto do cenário 1."

                                _ ->
                                    Expect.fail "esperava cenário"
                        ]
                        ()
            , test "cenário mostra identidade acima do texto" <|
                \_ ->
                    let
                        progresso =
                            Dict.singleton 2
                                { estado = EmAndamento, dicas = 0, verdade = False }

                        vis =
                            Office.view casos60 progresso filtroVazio visitaVazia (Pasta 2)
                    in
                    case vis of
                        VisCenario cen ->
                            Expect.all
                                [ \_ -> Expect.equal cen.numero 2
                                , \_ -> Expect.equal cen.titulo "Título 2"
                                , \_ -> Expect.equal cen.categoria "Assassinatos"
                                , \_ -> Expect.equal cen.dificuldade "Fácil"
                                , \_ -> Expect.equal cen.cenario "Texto do cenário 2."
                                ]
                                ()

                        _ ->
                            Expect.fail "esperava cenário"
            ]
        , describe "Lista"
            [ test "Lista volta à lista" <|
                \_ ->
                    let
                        ( prog0, saida0 ) =
                            Office.update casos60 Dict.empty filtroVazio visitaVazia Lista (AbrirPasta 3)

                        ( prog1, saida1 ) =
                            Office.update casos60 prog0 filtroVazio visitaVazia saida0.route IrParaLista
                    in
                    Expect.all
                        [ \_ -> Expect.equal saida1.route Lista
                        , \_ -> Expect.equal prog1 prog0
                        , \_ ->
                            case saida1.visible of
                                VisLista page ->
                                    Expect.equal page.tituloPagina "Histórias Sinistras"

                                _ ->
                                    Expect.fail "esperava lista"
                        ]
                        ()
            ]
        , describe "revelar dica"
            [ test "cenário Em andamento oferece Revelar dica na barra" <|
                \_ ->
                    let
                        progresso =
                            Dict.singleton 1
                                { estado = EmAndamento, dicas = 0, verdade = False }
                    in
                    case Office.view casos60 progresso filtroVazio visitaVazia (Pasta 1) of
                        VisCenario cen ->
                            Expect.equal cen.barControles
                                [ "Revelar dica", "Revelar a verdade", "Marcar como resolvido" ]

                        _ ->
                            Expect.fail "esperava cenário"
            , test "Revelar dica abre a primeira dica" <|
                \_ ->
                    let
                        progresso =
                            Dict.singleton 1
                                { estado = EmAndamento, dicas = 0, verdade = False }

                        ( prog1, saida1 ) =
                            Office.update casos60 progresso filtroVazio visitaVazia (Pasta 1) RevelarDica
                    in
                    Expect.all
                        [ \_ ->
                            case saida1.visible of
                                VisCenario cen ->
                                    Expect.all
                                        [ \_ -> Expect.equal cen.dicas [ "d1" ]
                                        , \_ ->
                                            Expect.equal cen.barControles
                                                [ "Revelar dica"
                                                , "Revelar a verdade"
                                                , "Marcar como resolvido"
                                                ]
                                        ]
                                        ()

                                _ ->
                                    Expect.fail "esperava cenário"
                        , \_ ->
                            case Dict.get 1 prog1 of
                                Just pasta ->
                                    Expect.equal pasta.dicas 1

                                Nothing ->
                                    Expect.fail "sem progresso"
                        ]
                        ()
            , test "dicas abertas ficam na ordem após o cenário" <|
                \_ ->
                    let
                        progresso =
                            Dict.singleton 1
                                { estado = EmAndamento, dicas = 2, verdade = False }
                    in
                    case Office.view casos60 progresso filtroVazio visitaVazia (Pasta 1) of
                        VisCenario cen ->
                            Expect.equal cen.dicas [ "d1", "d2" ]

                        _ ->
                            Expect.fail "esperava cenário"
            , test "após a quarta dica a barra não oferece Revelar dica" <|
                \_ ->
                    let
                        progresso =
                            Dict.singleton 1
                                { estado = EmAndamento, dicas = 4, verdade = False }
                    in
                    case Office.view casos60 progresso filtroVazio visitaVazia (Pasta 1) of
                        VisCenario cen ->
                            Expect.all
                                [ \_ ->
                                    Expect.equal cen.barControles
                                        [ "Revelar a verdade", "Marcar como resolvido" ]
                                , \_ -> Expect.equal cen.dicas [ "d1", "d2", "d3", "d4" ]
                                ]
                                ()

                        _ ->
                            Expect.fail "esperava cenário"
            , test "lista Em andamento mostra 2 dicas" <|
                \_ ->
                    let
                        progresso =
                            Dict.singleton 5
                                { estado = EmAndamento, dicas = 2, verdade = False }
                    in
                    case Office.view casos60 progresso filtroVazio visitaVazia Lista of
                        VisLista page ->
                            case
                                page.linhas
                                    |> List.filter (\l -> l.numero == 5)
                                    |> List.head
                            of
                                Just linha ->
                                    Expect.equal linha.detalhes [ "2 dicas" ]

                                Nothing ->
                                    Expect.fail "sem linha 5"

                        _ ->
                            Expect.fail "esperava lista"
            , test "abrir dica não marca Resolvido" <|
                \_ ->
                    let
                        progresso =
                            Dict.singleton 1
                                { estado = EmAndamento, dicas = 0, verdade = False }

                        ( prog1, saida1 ) =
                            Office.update casos60 progresso filtroVazio visitaVazia (Pasta 1) RevelarDica
                    in
                    case Dict.get 1 prog1 of
                        Just pasta ->
                            Expect.equal pasta.estado EmAndamento

                        Nothing ->
                            Expect.fail "sem progresso"
            , test "capa não oferece Revelar dica" <|
                \_ ->
                    case Office.view casos60 Dict.empty filtroVazio visitaVazia (Pasta 1) of
                        VisCapa capa ->
                            Expect.equal capa.controles
                                [ "Lista", "Próximo", "Ler o caso" ]

                        _ ->
                            Expect.fail "esperava capa"
            , test "quatro Revelar dica remove o controle da barra" <|
                \_ ->
                    let
                        progresso =
                            Dict.singleton 1
                                { estado = EmAndamento, dicas = 0, verdade = False }

                        finalProgresso =
                            List.foldl
                                (\_ prog ->
                                    let
                                        ( p, saida ) =
                                            Office.update casos60 prog filtroVazio visitaVazia (Pasta 1) RevelarDica
                                    in
                                    p
                                )
                                progresso
                                (List.range 1 4)
                    in
                    case Office.view casos60 finalProgresso filtroVazio visitaVazia (Pasta 1) of
                        VisCenario cen ->
                            Expect.all
                                [ \_ ->
                                    Expect.equal cen.barControles
                                        [ "Revelar a verdade", "Marcar como resolvido" ]
                                , \_ -> Expect.equal cen.dicas [ "d1", "d2", "d3", "d4" ]
                                ]
                                ()

                        _ ->
                            Expect.fail "esperava cenário"
            ]
        , describe "revelar verdade"
            [ test "cenário Em andamento oferece Revelar a verdade com zero dicas" <|
                \_ ->
                    let
                        progresso =
                            Dict.singleton 1
                                { estado = EmAndamento, dicas = 0, verdade = False }
                    in
                    case Office.view casos60 progresso filtroVazio visitaVazia (Pasta 1) of
                        VisCenario cen ->
                            Expect.all
                                [ \_ ->
                                    Expect.equal
                                        (List.member "Revelar a verdade" cen.barControles)
                                        True
                                , \_ -> Expect.equal cen.verdade Nothing
                                ]
                                ()

                        _ ->
                            Expect.fail "esperava cenário"
            , test "Revelar a verdade sem dicas mostra a verdade e tira o controle da barra" <|
                \_ ->
                    let
                        progresso =
                            Dict.singleton 1
                                { estado = EmAndamento, dicas = 0, verdade = False }

                        ( prog1, saida1 ) =
                            Office.update casos60 progresso filtroVazio visitaVazia (Pasta 1) RevelarVerdade
                    in
                    Expect.all
                        [ \_ ->
                            case saida1.visible of
                                VisCenario cen ->
                                    Expect.all
                                        [ \_ -> Expect.equal cen.dicas []
                                        , \_ -> Expect.equal cen.verdade (Just "v")
                                        , \_ ->
                                            Expect.equal
                                                (List.member "Revelar a verdade" cen.barControles)
                                                False
                                        ]
                                        ()

                                _ ->
                                    Expect.fail "esperava cenário"
                        , \_ ->
                            case Dict.get 1 prog1 of
                                Just pasta ->
                                    Expect.equal pasta.verdade True

                                Nothing ->
                                    Expect.fail "sem progresso"
                        ]
                        ()
            , test "verdade aparece depois das dicas abertas" <|
                \_ ->
                    let
                        progresso =
                            Dict.singleton 1
                                { estado = EmAndamento, dicas = 2, verdade = False }

                        ( _, saida ) =
                            Office.update casos60 progresso filtroVazio visitaVazia (Pasta 1) RevelarVerdade
                    in
                    case saida.visible of
                        VisCenario cen ->
                            Expect.all
                                [ \_ -> Expect.equal cen.dicas [ "d1", "d2" ]
                                , \_ -> Expect.equal cen.verdade (Just "v")
                                ]
                                ()

                        _ ->
                            Expect.fail "esperava cenário"
            , test "abrir a verdade não marca Resolvido" <|
                \_ ->
                    let
                        progresso =
                            Dict.singleton 1
                                { estado = EmAndamento, dicas = 0, verdade = False }

                        ( prog1, saida1 ) =
                            Office.update casos60 progresso filtroVazio visitaVazia (Pasta 1) RevelarVerdade
                    in
                    case Dict.get 1 prog1 of
                        Just pasta ->
                            Expect.equal pasta.estado EmAndamento

                        Nothing ->
                            Expect.fail "sem progresso"
            , test "lista Em andamento mostra verdade quando está aberta" <|
                \_ ->
                    let
                        progresso =
                            Dict.singleton 3
                                { estado = EmAndamento, dicas = 1, verdade = True }
                    in
                    case Office.view casos60 progresso filtroVazio visitaVazia Lista of
                        VisLista page ->
                            case
                                page.linhas
                                    |> List.filter (\l -> l.numero == 3)
                                    |> List.head
                            of
                                Just linha ->
                                    Expect.equal linha.detalhes [ "1 dica", "verdade" ]

                                Nothing ->
                                    Expect.fail "sem linha 3"

                        _ ->
                            Expect.fail "esperava lista"
            , test "voltar à pasta mantém a verdade visível" <|
                \_ ->
                    let
                        progresso =
                            Dict.singleton 7
                                { estado = EmAndamento, dicas = 0, verdade = True }

                        ( _, saida ) =
                            Office.update casos60 progresso filtroVazio visitaVazia Lista (AbrirPasta 7)
                    in
                    case saida.visible of
                        VisCenario cen ->
                            Expect.all
                                [ \_ -> Expect.equal cen.verdade (Just "v")
                                , \_ ->
                                    Expect.equal
                                        (List.member "Revelar a verdade" cen.barControles)
                                        False
                                ]
                                ()

                        _ ->
                            Expect.fail "esperava cenário"
            ]
        , describe "marcar como resolvido"
            [ test "cenário Em andamento oferece Marcar como resolvido na barra" <|
                \_ ->
                    let
                        progresso =
                            Dict.singleton 1
                                { estado = EmAndamento, dicas = 0, verdade = False }
                    in
                    case Office.view casos60 progresso filtroVazio visitaVazia (Pasta 1) of
                        VisCenario cen ->
                            Expect.equal
                                (List.member "Marcar como resolvido" cen.barControles)
                                True

                        _ ->
                            Expect.fail "esperava cenário"
            , test "Marcar como resolvido marca Resolvido e mostra o carimbo" <|
                \_ ->
                    let
                        progresso =
                            Dict.singleton 1
                                { estado = EmAndamento, dicas = 0, verdade = False }

                        ( prog1, saida1 ) =
                            Office.update casos60 progresso filtroVazio visitaVazia (Pasta 1) MarcarComoResolvido
                    in
                    Expect.all
                        [ \_ ->
                            case saida1.visible of
                                VisCenario cen ->
                                    Expect.all
                                        [ \_ -> Expect.equal cen.carimbo True
                                        , \_ ->
                                            Expect.equal cen.barControles
                                                [ "Revelar dica"
                                                , "Revelar a verdade"
                                                , "Desmarcar"
                                                ]
                                        ]
                                        ()

                                _ ->
                                    Expect.fail "esperava cenário"
                        , \_ ->
                            case Dict.get 1 prog1 of
                                Just pasta ->
                                    Expect.equal pasta.estado Resolvido

                                Nothing ->
                                    Expect.fail "sem progresso"
                        ]
                        ()
            , test "Marcar como resolvido funciona com a verdade ainda fechada" <|
                \_ ->
                    let
                        progresso =
                            Dict.singleton 1
                                { estado = EmAndamento, dicas = 2, verdade = False }

                        ( prog1, saida1 ) =
                            Office.update casos60 progresso filtroVazio visitaVazia (Pasta 1) MarcarComoResolvido
                    in
                    Expect.all
                        [ \_ ->
                            case saida1.visible of
                                VisCenario cen ->
                                    Expect.all
                                        [ \_ -> Expect.equal cen.carimbo True
                                        , \_ -> Expect.equal cen.verdade Nothing
                                        , \_ ->
                                            Expect.equal
                                                (List.member "Revelar dica" cen.barControles)
                                                True
                                        ]
                                        ()

                                _ ->
                                    Expect.fail "esperava cenário"
                        , \_ ->
                            case Dict.get 1 prog1 of
                                Just pasta ->
                                    Expect.all
                                        [ \_ -> Expect.equal pasta.estado Resolvido
                                        , \_ -> Expect.equal pasta.dicas 2
                                        , \_ -> Expect.equal pasta.verdade False
                                        ]
                                        ()

                                Nothing ->
                                    Expect.fail "sem progresso"
                        ]
                        ()
            , test "Desmarcar volta a Em andamento sem fechar dicas nem verdade" <|
                \_ ->
                    let
                        progresso =
                            Dict.singleton 1
                                { estado = Resolvido, dicas = 3, verdade = True }

                        ( prog1, saida1 ) =
                            Office.update casos60 progresso filtroVazio visitaVazia (Pasta 1) Desmarcar
                    in
                    Expect.all
                        [ \_ ->
                            case saida1.visible of
                                VisCenario cen ->
                                    Expect.all
                                        [ \_ -> Expect.equal cen.carimbo False
                                        , \_ -> Expect.equal cen.dicas [ "d1", "d2", "d3" ]
                                        , \_ -> Expect.equal cen.verdade (Just "v")
                                        , \_ ->
                                            Expect.equal
                                                (List.member "Marcar como resolvido" cen.barControles)
                                                True
                                        ]
                                        ()

                                _ ->
                                    Expect.fail "esperava cenário"
                        , \_ ->
                            case Dict.get 1 prog1 of
                                Just pasta ->
                                    Expect.all
                                        [ \_ -> Expect.equal pasta.estado EmAndamento
                                        , \_ -> Expect.equal pasta.dicas 3
                                        , \_ -> Expect.equal pasta.verdade True
                                        ]
                                        ()

                                Nothing ->
                                    Expect.fail "sem progresso"
                        ]
                        ()
            , test "lista Resolvido mostra Resolvido sem dicas nem verdade" <|
                \_ ->
                    let
                        progresso =
                            Dict.singleton 4
                                { estado = Resolvido, dicas = 2, verdade = True }
                    in
                    case Office.view casos60 progresso filtroVazio visitaVazia Lista of
                        VisLista page ->
                            case
                                page.linhas
                                    |> List.filter (\l -> l.numero == 4)
                                    |> List.head
                            of
                                Just linha ->
                                    Expect.all
                                        [ \_ -> Expect.equal linha.estado "Resolvido"
                                        , \_ -> Expect.equal linha.detalhes []
                                        ]
                                        ()

                                Nothing ->
                                    Expect.fail "sem linha 4"

                        _ ->
                            Expect.fail "esperava lista"
            , test "pasta Resolvido abre no cenário com carimbo" <|
                \_ ->
                    let
                        progresso =
                            Dict.singleton 8
                                { estado = Resolvido, dicas = 0, verdade = False }

                        ( _, saida ) =
                            Office.update casos60 progresso filtroVazio visitaVazia Lista (AbrirPasta 8)
                    in
                    case saida.visible of
                        VisCenario cen ->
                            Expect.all
                                [ \_ -> Expect.equal cen.carimbo True
                                , \_ ->
                                    Expect.equal
                                        (List.member "Desmarcar" cen.barControles)
                                        True
                                ]
                                ()

                        _ ->
                            Expect.fail "esperava cenário"
            , test "capa mostra Novo e não oferece o carimbo" <|
                \_ ->
                    case Office.view casos60 Dict.empty filtroVazio visitaVazia (Pasta 1) of
                        VisCapa capa ->
                            Expect.all
                                [ \_ -> Expect.equal capa.estado "Novo"
                                , \_ ->
                                    Expect.equal
                                        (List.member "Marcar como resolvido" capa.controles)
                                        False
                                , \_ ->
                                    Expect.equal
                                        (List.member "Desmarcar" capa.controles)
                                        False
                                ]
                                ()

                        _ ->
                            Expect.fail "esperava capa"
            , test "progresso carregado Resolvido mantém o carimbo" <|
                \_ ->
                    let
                        progresso =
                            Dict.singleton 9
                                { estado = Resolvido, dicas = 1, verdade = False }
                    in
                    case Office.view casos60 progresso filtroVazio visitaVazia (Pasta 9) of
                        VisCenario cen ->
                            Expect.all
                                [ \_ -> Expect.equal cen.carimbo True
                                , \_ ->
                                    Expect.equal cen.barControles
                                        [ "Revelar dica", "Revelar a verdade", "Desmarcar" ]
                                ]
                                ()

                        _ ->
                            Expect.fail "esperava cenário"
            ]
        , describe "anterior e próximo"
            [ test "capa da pasta 1 não oferece Anterior" <|
                \_ ->
                    case Office.view casos60 Dict.empty filtroVazio visitaVazia (Pasta 1) of
                        VisCapa capa ->
                            Expect.all
                                [ \_ ->
                                    Expect.equal
                                        (List.member "Anterior" capa.controles)
                                        False
                                , \_ ->
                                    Expect.equal
                                        (List.member "Próximo" capa.controles)
                                        True
                                ]
                                ()

                        _ ->
                            Expect.fail "esperava capa"
            , test "capa da pasta 60 não oferece Próximo" <|
                \_ ->
                    case Office.view casos60 Dict.empty filtroVazio visitaVazia (Pasta 60) of
                        VisCapa capa ->
                            Expect.all
                                [ \_ ->
                                    Expect.equal
                                        (List.member "Anterior" capa.controles)
                                        True
                                , \_ ->
                                    Expect.equal
                                        (List.member "Próximo" capa.controles)
                                        False
                                ]
                                ()

                        _ ->
                            Expect.fail "esperava capa"
            , test "cenário no meio oferece Lista, Anterior e Próximo" <|
                \_ ->
                    let
                        progresso =
                            Dict.singleton 5
                                { estado = EmAndamento, dicas = 0, verdade = False }
                    in
                    case Office.view casos60 progresso filtroVazio visitaVazia (Pasta 5) of
                        VisCenario cen ->
                            Expect.equal cen.controles
                                [ "Lista", "Anterior", "Próximo" ]

                        _ ->
                            Expect.fail "esperava cenário"
            , test "Próximo na capa abre a capa da pasta seguinte Novo" <|
                \_ ->
                    let
                        ( prog0, saida0 ) =
                            Office.update casos60 Dict.empty filtroVazio visitaVazia Lista (AbrirPasta 1)

                        ( prog1, saida1 ) =
                            Office.update casos60 prog0 filtroVazio visitaVazia saida0.route IrProximo
                    in
                    Expect.all
                        [ \_ -> Expect.equal saida1.route (Pasta 2)
                        , \_ -> Expect.equal prog1 prog0
                        , \_ ->
                            case saida1.visible of
                                VisCapa capa ->
                                    Expect.equal capa.numero 2

                                _ ->
                                    Expect.fail "esperava capa"
                        ]
                        ()
            , test "Anterior no cenário abre o cenário da pasta anterior Em andamento" <|
                \_ ->
                    let
                        progresso =
                            Dict.fromList
                                [ ( 1, { estado = EmAndamento, dicas = 1, verdade = False } )
                                , ( 2, { estado = EmAndamento, dicas = 0, verdade = False } )
                                ]

                        ( _, saida0 ) =
                            Office.update casos60 progresso filtroVazio visitaVazia Lista (AbrirPasta 2)

                        ( prog1, saida1 ) =
                            Office.update casos60 progresso filtroVazio visitaVazia saida0.route IrAnterior
                    in
                    Expect.all
                        [ \_ -> Expect.equal saida1.route (Pasta 1)
                        , \_ -> Expect.equal prog1 progresso
                        , \_ ->
                            case saida1.visible of
                                VisCenario cen ->
                                    Expect.all
                                        [ \_ -> Expect.equal cen.numero 1
                                        , \_ -> Expect.equal cen.dicas [ "d1" ]
                                        ]
                                        ()

                                _ ->
                                    Expect.fail "esperava cenário"
                        ]
                        ()
            , test "Próximo em pasta Resolvido mostra o cenário, não a capa" <|
                \_ ->
                    let
                        progresso =
                            Dict.fromList
                                [ ( 3, { estado = Resolvido, dicas = 0, verdade = False } )
                                , ( 4, { estado = EmAndamento, dicas = 0, verdade = False } )
                                ]

                        ( _, saida0 ) =
                            Office.update casos60 progresso filtroVazio visitaVazia Lista (AbrirPasta 3)

                        ( prog1, saida1 ) =
                            Office.update casos60 progresso filtroVazio visitaVazia saida0.route IrProximo
                    in
                    Expect.all
                        [ \_ -> Expect.equal saida1.route (Pasta 4)
                        , \_ -> Expect.equal prog1 progresso
                        , \_ ->
                            case saida1.visible of
                                VisCenario cen ->
                                    Expect.equal cen.cenario "Texto do cenário 4."

                                VisCapa _ ->
                                    Expect.fail "não esperava capa"

                                _ ->
                                    Expect.fail "esperava cenário"
                        ]
                        ()
            , test "Lista depois de Próximo ainda volta à lista" <|
                \_ ->
                    let
                        ( prog0, saida0 ) =
                            Office.update casos60 Dict.empty filtroVazio visitaVazia Lista (AbrirPasta 2)

                        ( prog1, saida1 ) =
                            Office.update casos60 prog0 filtroVazio visitaVazia saida0.route IrProximo

                        ( prog2, saida2 ) =
                            Office.update casos60 prog1 filtroVazio visitaVazia saida1.route IrParaLista
                    in
                    Expect.all
                        [ \_ -> Expect.equal saida2.route Lista
                        , \_ -> Expect.equal prog2 prog0
                        , \_ ->
                            case saida2.visible of
                                VisLista page ->
                                    Expect.equal page.tituloPagina "Histórias Sinistras"

                                _ ->
                                    Expect.fail "esperava lista"
                        ]
                        ()
            ]
        , describe "filtrar"
            [ test "lista em repouso tem Filtrar antes das linhas, sem painel aberto" <|
                \_ ->
                    case Office.view casos60 Dict.empty filtroVazio visitaVazia Lista of
                        VisLista page ->
                            Expect.all
                                [ \_ -> Expect.equal page.controles [ "Filtrar" ]
                                , \_ -> Expect.equal page.filtroAtivo []
                                , \_ -> Expect.equal page.painelFiltrar Nothing
                                , \_ -> Expect.equal (List.length page.linhas) 60
                                ]
                                ()

                        _ ->
                            Expect.fail "esperava lista"
            , test "Filtrar abre o painel sem empilhar filtros na lista" <|
                \_ ->
                    let
                        ( _, saida ) =
                            Office.update casos60 Dict.empty filtroVazio visitaVazia Lista Filtrar
                    in
                    case Office.view casos60 Dict.empty saida.filtro visitaVazia Lista of
                                VisLista page ->
                                    Expect.all
                                        [ \_ ->
                                            case page.painelFiltrar of
                                                Just _ ->
                                                    Expect.pass

                                                Nothing ->
                                                    Expect.fail "painel fechado"
                                        , \_ -> Expect.equal page.filtroAtivo []
                                        , \_ -> Expect.equal (List.length page.linhas) 60
                                        ]
                                        ()

                                _ ->
                                    Expect.fail "esperava lista"
            , test "filtro de categoria mantém ordem por id" <|
                \_ ->
                    let
                        ( _, saidaDepois ) =
                            Office.update casosVariados Dict.empty filtroVazio visitaVazia Lista Filtrar

                        ( _, saida ) =
                            Office.update casosVariados Dict.empty saidaDepois.filtro visitaVazia Lista
                                (FiltroCategoria "Assassinatos")
                    in
                    case saida.visible of
                        VisLista page ->
                            Expect.all
                                [ \_ ->
                                    Expect.equal (List.map .numero page.linhas) [ 1, 3 ]
                                , \_ -> Expect.equal page.filtroAtivo [ "Assassinatos" ]
                                , \_ -> Expect.equal page.controles [ "Filtrar", "Limpar" ]
                                ]
                                ()

                        _ ->
                            Expect.fail "esperava lista"
            , test "Limpar restaura as 60 pastas" <|
                \_ ->
                    let
                        ( _, saidaComFiltro ) =
                            Office.update casos60 Dict.empty filtroVazio visitaVazia Lista
                                (FiltroDificuldade "Insano")

                        ( _, saidaLimpo ) =
                            Office.update casos60 Dict.empty saidaComFiltro.filtro visitaVazia Lista Limpar
                    in
                    Expect.all
                        [ \_ -> Expect.equal saidaLimpo.filtro filtroVazio
                        , \_ ->
                            case saidaLimpo.visible of
                                VisLista page ->
                                    Expect.equal (List.length page.linhas) 60

                                _ ->
                                    Expect.fail "esperava lista"
                        ]
                        ()
            , test "filtro sem correspondência mostra aviso em português" <|
                \_ ->
                    let
                        ( _, saida ) =
                            Office.update casos60 Dict.empty filtroVazio visitaVazia Lista
                                (FiltroDificuldade "Insano")
                    in
                    case saida.visible of
                        VisLista page ->
                            Expect.all
                                [ \_ -> Expect.equal page.linhas []
                                , \_ ->
                                    Expect.equal page.avisoSemCorrespondencia
                                        (Just Office.semCorrespondencia)
                                ]
                                ()

                        _ ->
                            Expect.fail "esperava lista"
            , test "Lista após abrir pasta mantém o filtro" <|
                \_ ->
                    let
                        ( _, saidaFiltro ) =
                            Office.update casosVariados Dict.empty filtroVazio visitaVazia Lista
                                (FiltroCategoria "Assassinatos")

                        ( _, saida0 ) =
                            Office.update casosVariados Dict.empty saidaFiltro.filtro visitaVazia Lista (AbrirPasta 1)

                        ( _, saidaVolta ) =
                            Office.update casosVariados Dict.empty saidaFiltro.filtro visitaVazia saida0.route IrParaLista
                    in
                    Expect.all
                        [ \_ -> Expect.equal saidaVolta.route Lista
                        , \_ -> Expect.equal saidaVolta.filtro.categoria (Just "Assassinatos")
                        , \_ ->
                            case saidaVolta.visible of
                                VisLista page ->
                                    Expect.equal (List.map .numero page.linhas) [ 1, 3 ]

                                _ ->
                                    Expect.fail "esperava lista"
                        ]
                        ()
            , test "Anterior e Próximo mantêm o filtro" <|
                \_ ->
                    let
                        ( _, saidaFiltro ) =
                            Office.update casos60 Dict.empty filtroVazio visitaVazia Lista
                                (FiltroEstado "Novo")

                        ( _, saida0 ) =
                            Office.update casos60 Dict.empty saidaFiltro.filtro visitaVazia Lista (AbrirPasta 2)

                        ( _, saidaProx ) =
                            Office.update casos60 Dict.empty saidaFiltro.filtro visitaVazia saida0.route IrProximo

                        ( _, saidaAnt ) =
                            Office.update casos60 Dict.empty saidaProx.filtro visitaVazia saidaProx.route IrAnterior
                    in
                    Expect.all
                        [ \_ -> Expect.equal saidaAnt.filtro.estado (Just Novo)
                        , \_ -> Expect.equal saidaAnt.filtro.categoria saidaFiltro.filtro.categoria
                        ]
                        ()
            , test "lista filtrada Em andamento mostra dicas e verdade" <|
                \_ ->
                    let
                        progresso =
                            Dict.singleton 5
                                { estado = EmAndamento, dicas = 2, verdade = True }

                        ( _, saidaFiltro ) =
                            Office.update casos60 progresso filtroVazio visitaVazia Lista
                                (FiltroEstado "Em andamento")
                    in
                    case Office.view casos60 progresso saidaFiltro.filtro visitaVazia Lista of
                        VisLista page ->
                            case
                                page.linhas
                                    |> List.filter (\l -> l.numero == 5)
                                    |> List.head
                            of
                                Just linha ->
                                    Expect.equal linha.detalhes [ "2 dicas", "verdade" ]

                                Nothing ->
                                    Expect.fail "sem linha 5"

                        _ ->
                            Expect.fail "esperava lista"
            , test "filtro não entra no progresso" <|
                \_ ->
                    let
                        ( prog, saida ) =
                            Office.update casos60 Dict.empty filtroVazio visitaVazia Lista
                                (FiltroCategoria "Assassinatos")
                    in
                    Expect.all
                        [ \_ -> Expect.equal prog Dict.empty
                        , \_ -> Expect.notEqual saida.filtro filtroVazio
                        ]
                        ()
            ]
        , describe "zerar progresso"
            [ test "lista oferece Zerar progresso depois das linhas, não junto de Filtrar" <|
                \_ ->
                    case Office.view casos60 Dict.empty filtroVazio visitaVazia Lista of
                        VisLista page ->
                            Expect.all
                                [ \_ -> Expect.equal page.controles [ "Filtrar" ]
                                , \_ ->
                                    Expect.equal page.controlesAposLinhas
                                        [ "Zerar progresso" ]
                                ]
                                ()

                        _ ->
                            Expect.fail "esperava lista"
            , test "Zerar progresso mostra Confirmar e Cancelar na lista sem espera" <|
                \_ ->
                    let
                        ( _, saida ) =
                            Office.update casos60 Dict.empty filtroVazio visitaVazia Lista
                                ZerarProgresso
                    in
                    Expect.all
                        [ \_ -> Expect.equal saida.route Lista
                        , \_ ->
                            case saida.visible of
                                VisLista page ->
                                    Expect.equal page.controlesAposLinhas
                                        [ "Confirmar", "Cancelar" ]

                                _ ->
                                    Expect.fail "esperava lista"
                        ]
                        ()
            , test "Cancelar deixa cada pasta como estava e sai da confirmação" <|
                \_ ->
                    let
                        progresso =
                            Dict.singleton 4
                                { estado = EmAndamento, dicas = 2, verdade = True }

                        ( _, saidaZerar ) =
                            Office.update casos60 progresso filtroVazio visitaVazia Lista
                                ZerarProgresso

                        ( progDepois, saidaCancelar ) =
                            Office.update casos60 progresso saidaZerar.filtro
                                saidaZerar.visita Lista Cancelar
                    in
                    Expect.all
                        [ \_ -> Expect.equal progDepois progresso
                        , \_ -> Expect.equal saidaCancelar.visita visitaVazia
                        , \_ ->
                            case saidaCancelar.visible of
                                VisLista page ->
                                    Expect.equal page.controlesAposLinhas
                                        [ "Zerar progresso" ]

                                _ ->
                                    Expect.fail "esperava lista"
                        ]
                        ()
            , test "Cancelar não limpa o filtro ativo" <|
                \_ ->
                    let
                        progresso =
                            Dict.singleton 1
                                { estado = Resolvido, dicas = 0, verdade = False }

                        ( _, saidaFiltro ) =
                            Office.update casos60 progresso filtroVazio visitaVazia Lista
                                (FiltroEstado "Resolvido")

                        ( _, saidaZerar ) =
                            Office.update casos60 progresso saidaFiltro.filtro
                                visitaVazia Lista ZerarProgresso

                        ( _, saidaCancelar ) =
                            Office.update casos60 progresso saidaZerar.filtro
                                saidaZerar.visita Lista Cancelar
                    in
                    Expect.all
                        [ \_ ->
                            Expect.equal saidaCancelar.filtro.estado
                                (Just Resolvido)
                        , \_ ->
                            case saidaCancelar.visible of
                                VisLista page ->
                                    Expect.all
                                        [ \_ ->
                                            Expect.equal page.filtroAtivo
                                                [ "Resolvido" ]
                                        , \_ ->
                                            Expect.equal (List.map .numero page.linhas)
                                                [ 1 ]
                                        ]
                                        ()

                                _ ->
                                    Expect.fail "esperava lista"
                        ]
                        ()
            , test "Confirmar volta cada pasta a Novo com progresso vazio" <|
                \_ ->
                    let
                        progresso =
                            Dict.fromList
                                [ ( 1, { estado = EmAndamento, dicas = 3, verdade = True } )
                                , ( 2, { estado = Resolvido, dicas = 0, verdade = False } )
                                ]

                        ( _, saidaZerar ) =
                            Office.update casos60 progresso filtroVazio visitaVazia Lista
                                ZerarProgresso

                        ( progDepois, saidaConfirmar ) =
                            Office.update casos60 progresso saidaZerar.filtro
                                saidaZerar.visita Lista Confirmar
                    in
                    Expect.all
                        [ \_ -> Expect.equal progDepois Dict.empty
                        , \_ -> Expect.equal saidaConfirmar.visita visitaVazia
                        , \_ ->
                            case saidaConfirmar.visible of
                                VisLista page ->
                                    Expect.all
                                        [ \_ ->
                                            Expect.equal
                                                (List.map .estado page.linhas)
                                                (List.repeat 60 "Novo")
                                        , \_ ->
                                            Expect.equal page.controlesAposLinhas
                                                [ "Zerar progresso" ]
                                        ]
                                        ()

                                _ ->
                                    Expect.fail "esperava lista"
                        ]
                        ()
            , test "Confirmar com filtro Resolvido mantém o filtro e a lista vazia" <|
                \_ ->
                    let
                        progresso =
                            Dict.singleton 3
                                { estado = Resolvido, dicas = 0, verdade = False }

                        ( _, saidaFiltro ) =
                            Office.update casos60 progresso filtroVazio visitaVazia Lista
                                (FiltroEstado "Resolvido")

                        ( _, saidaZerar ) =
                            Office.update casos60 progresso saidaFiltro.filtro
                                visitaVazia Lista ZerarProgresso

                        ( _, saidaConfirmar ) =
                            Office.update casos60 progresso saidaZerar.filtro
                                saidaZerar.visita Lista Confirmar
                    in
                    Expect.all
                        [ \_ ->
                            Expect.equal saidaConfirmar.filtro.estado
                                (Just Resolvido)
                        , \_ ->
                            case saidaConfirmar.visible of
                                VisLista page ->
                                    Expect.all
                                        [ \_ -> Expect.equal page.linhas []
                                        , \_ ->
                                            Expect.equal page.avisoSemCorrespondencia
                                                (Just Office.semCorrespondencia)
                                        , \_ ->
                                            Expect.equal page.controles
                                                [ "Filtrar", "Limpar" ]
                                        ]
                                        ()

                                _ ->
                                    Expect.fail "esperava lista"
                        ]
                        ()
            , test "recarregar depois de Confirmar ainda mostra cada pasta Novo" <|
                \_ ->
                    let
                        progresso =
                            Dict.singleton 6
                                { estado = EmAndamento, dicas = 1, verdade = False }

                        ( progZerado, _ ) =
                            let
                                ( _, saidaZerar ) =
                                    Office.update casos60 progresso filtroVazio visitaVazia Lista
                                        ZerarProgresso

                                ( prog, _ ) =
                                    Office.update casos60 progresso saidaZerar.filtro
                                        saidaZerar.visita Lista Confirmar
                            in
                            ( prog, () )

                        recarregado =
                            progZerado |> encodeProgresso |> decodeProgresso
                    in
                    Expect.all
                        [ \_ -> Expect.equal progZerado Dict.empty
                        , \_ -> Expect.equal recarregado Dict.empty
                        , \_ ->
                            case Office.view casos60 recarregado filtroVazio visitaVazia Lista of
                                VisLista page ->
                                    Expect.equal
                                        (List.head page.linhas |> Maybe.map .estado)
                                        (Just "Novo")

                                _ ->
                                    Expect.fail "esperava lista"
                        ]
                        ()
            ]
        , describe "como jogar e créditos"
            [ test "lista mostra Como jogar e Créditos antes de Filtrar" <|
                \_ ->
                    case Office.view casos60 Dict.empty filtroVazio visitaVazia Lista of
                        VisLista page ->
                            Expect.all
                                [ \_ ->
                                    Expect.equal page.atalhos
                                        [ "Como jogar", "Créditos" ]
                                , \_ -> Expect.equal page.controles [ "Filtrar" ]
                                ]
                                ()

                        _ ->
                            Expect.fail "esperava lista"
            , test "hash desconhecido mostra a lista" <|
                \_ ->
                    Expect.equal (fromHash "#/foo") Lista
            , test "hash como-jogar e créditos" <|
                \_ ->
                    Expect.all
                        [ \_ -> Expect.equal (fromHash "#/como-jogar") ComoJogar
                        , \_ -> Expect.equal (fromHash "#/creditos") Creditos
                        , \_ -> Expect.equal (toHash ComoJogar) "#/como-jogar"
                        , \_ -> Expect.equal (toHash Creditos) "#/creditos"
                        ]
                        ()
            , test "Como jogar oferece só Lista no topo" <|
                \_ ->
                    case Office.view casos60 Dict.empty filtroVazio visitaVazia ComoJogar of
                        VisComoJogar page ->
                            Expect.equal page.controles [ "Lista" ]

                        _ ->
                            Expect.fail "esperava como jogar"
            , test "Como jogar explica jogar sozinho e o Guardião" <|
                \_ ->
                    case Office.view casos60 Dict.empty filtroVazio visitaVazia ComoJogar of
                        VisComoJogar page ->
                            let
                                texto =
                                    String.join " " page.paragrafos
                            in
                            Expect.all
                                [ \_ -> Expect.equal (String.contains "teoria" texto) True
                                , \_ ->
                                    Expect.equal
                                        (String.contains "travad" texto)
                                        True
                                , \_ ->
                                    Expect.equal
                                        (String.contains "verdade" texto)
                                        True
                                , \_ ->
                                    Expect.equal
                                        (String.contains "Marcar como resolvido" texto)
                                        True
                                , \_ ->
                                    Expect.equal
                                        (String.contains "Guardião do Segredo" texto)
                                        True
                                , \_ ->
                                    Expect.equal (String.contains "sim" texto) True
                                , \_ ->
                                    Expect.equal (String.contains "não" texto) True
                                , \_ ->
                                    Expect.equal
                                        (String.contains "irrelevante" texto)
                                        True
                                , \_ ->
                                    Expect.equal
                                        (String.contains "modo" texto)
                                        False
                                ]
                                ()

                        _ ->
                            Expect.fail "esperava como jogar"
            , test "Créditos oferece só Lista no topo" <|
                \_ ->
                    case Office.view casos60 Dict.empty filtroVazio visitaVazia Creditos of
                        VisCreditos page ->
                            Expect.equal page.controles [ "Lista" ]

                        _ ->
                            Expect.fail "esperava créditos"
            , test "Créditos mostra os avisos exigidos" <|
                \_ ->
                    case Office.view casos60 Dict.empty filtroVazio visitaVazia Creditos of
                        VisCreditos page ->
                            let
                                texto =
                                    String.join "\n" page.blocos
                            in
                            Expect.all
                                [ \_ ->
                                    Expect.equal
                                        (String.contains
                                            "Copyright (c) 2026 Perrart (https://github.com/perrart/cardputer)"
                                            texto
                                        )
                                        True
                                , \_ ->
                                    Expect.equal
                                        (String.contains "PolyForm Noncommercial License 1.0.0" texto)
                                        True
                                , \_ ->
                                    Expect.equal
                                        (String.contains "Noncommercial Purposes" texto)
                                        True
                                , \_ ->
                                    Expect.equal
                                        (String.contains "Brian J. Bonislawsky" texto)
                                        True
                                , \_ ->
                                    Expect.equal
                                        (String.contains "Apache License" texto)
                                        True
                                , \_ ->
                                    Expect.equal
                                        (String.contains "Version 2.0, January 2004" texto)
                                        True
                                , \_ ->
                                    Expect.equal
                                        (String.contains "Copyright 2012-present Evan Czaplicki" texto)
                                        True
                                , \_ ->
                                    Expect.equal
                                        (String.contains "Copyright 2017-present Evan Czaplicki" texto)
                                        True
                                , \_ ->
                                    Expect.equal
                                        (String.contains "Copyright 2014-present Evan Czaplicki" texto)
                                        True
                                , \_ ->
                                    Expect.equal (String.contains "M5Stack" texto) False
                                , \_ ->
                                    Expect.equal
                                        (String.contains "Open Font License" texto)
                                        False
                                ]
                                ()

                        _ ->
                            Expect.fail "esperava créditos"
            , test "Lista volta de Como jogar com o filtro" <|
                \_ ->
                    let
                        ( _, saidaFiltro ) =
                            Office.update casosVariados Dict.empty filtroVazio visitaVazia Lista
                                (FiltroCategoria "Assassinatos")

                        progresso =
                            Dict.singleton 1
                                { estado = EmAndamento, dicas = 1, verdade = False }

                        ( prog1, saidaComo ) =
                            Office.update casosVariados progresso saidaFiltro.filtro
                                visitaVazia Lista IrComoJogar

                        ( prog2, saidaLista ) =
                            Office.update casosVariados prog1 saidaComo.filtro visitaVazia
                                ComoJogar
                                IrParaLista
                    in
                    Expect.all
                        [ \_ -> Expect.equal saidaComo.route ComoJogar
                        , \_ -> Expect.equal saidaLista.route Lista
                        , \_ -> Expect.equal prog2 progresso
                        , \_ ->
                            Expect.equal saidaLista.filtro.categoria
                                (Just "Assassinatos")
                        ]
                        ()
            ]
        ]
