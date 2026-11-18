port module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Casos
import Dict
import Html exposing (Html, button, div, h1, h2, hr, li, p, span, text, ul)
import Html.Attributes exposing (class, type_)
import Html.Events exposing (onClick)
import Http
import Office exposing (..)
import Route exposing (fromFragment, toHash)
import Save exposing (decodeProgresso, encodeProgresso)
import String
import Url


port progressoPedir : () -> Cmd msg


port progressoRecebido : (String -> msg) -> Sub msg


port progressoSalvar : String -> Cmd msg


type alias Model =
    { key : Nav.Key
    , url : Url.Url
    , casos : List Caso
    , progresso : Progresso
    , filtro : Filtro
    , visita : Visita
    , route : Route
    , visible : Visible
    , progressoCarregado : Bool
    }


type Msg
    = NoOp
    | CasosCarregados (Result Http.Error (List Caso))
    | ProgressoDoBrowser String
    | UrlChanged Url.Url
    | UrlRequested Browser.UrlRequest
    | OfficeMsg Office.Action


main : Program String Model Msg
main =
    Browser.application
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        , onUrlRequest = UrlRequested
        , onUrlChange = UrlChanged
        }


init : String -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init casosUrl url key =
    let
        route =
            fromFragment url.fragment

        model =
            { key = key
            , url = url
            , casos = []
            , progresso = Dict.empty
            , filtro = filtroVazio
            , visita = visitaVazia
            , route = route
            , visible = Office.view [] Dict.empty filtroVazio visitaVazia route
            , progressoCarregado = False
            }
    in
    ( model
    , Cmd.batch
        [ Http.get
            { url = casosUrl
            , expect = Http.expectJson CasosCarregados Casos.decodeCasos
            }
        , progressoPedir ()
        ]
    )

subscriptions : Model -> Sub Msg
subscriptions _ =
    progressoRecebido ProgressoDoBrowser


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        CasosCarregados (Ok casos) ->
            let
                visible =
                    Office.view casos model.progresso model.filtro model.visita model.route
            in
            ( { model | casos = casos, visible = visible }, Cmd.none )

        CasosCarregados (Err _) ->
            ( model, Cmd.none )

        ProgressoDoBrowser raw ->
            let
                progresso =
                    decodeProgresso raw

                visible =
                    Office.view model.casos progresso model.filtro model.visita model.route
            in
            ( { model | progresso = progresso, visible = visible, progressoCarregado = True }
            , Cmd.none
            )

        UrlChanged url ->
            let
                route =
                    fromFragment url.fragment

                visible =
                    Office.view model.casos model.progresso model.filtro model.visita route
            in
            ( { model | url = url, route = route, visible = visible }, Cmd.none )

        UrlRequested request ->
            case request of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        OfficeMsg action ->
            let
                ( progresso, saida ) =
                    Office.update model.casos model.progresso model.filtro model.visita model.route action

                cmds =
                    if progresso /= model.progresso then
                        [ progressoSalvar (encodeProgresso progresso) ]

                    else
                        []

                nav =
                    if saida.route /= model.route then
                        pushRoute model.url model.key saida.route

                    else
                        Cmd.none
            in
            ( { model
                | progresso = progresso
                , filtro = saida.filtro
                , visita = saida.visita
                , route = saida.route
                , visible = saida.visible
              }
            , Cmd.batch (nav :: cmds)
            )


view : Model -> Browser.Document Msg
view model =
    { title = "Histórias Sinistras"
    , body =
        [ div [ class "papel" ]
            [ case model.visible of
                VisLista page ->
                    viewLista page

                VisCapa capa ->
                    viewCapa capa

                VisCenario cen ->
                    viewCenario cen

                VisComoJogar page ->
                    viewComoJogar page

                VisCreditos page ->
                    viewCreditos page
            ]
        ]
    }


viewLista : Office.ListaPage -> Html Msg
viewLista page =
    let
        contador =
            String.fromInt page.resolvidos
                ++ "/60 resolvidos"

        aposLinhas =
            case page.avisoZerar of
                Just _ ->
                    text ""

                Nothing ->
                    div [ class "lista-apos-linhas" ] <|
                        List.map viewControle page.controlesAposLinhas
    in
    div []
        [ div [ class "titulo-dossier" ]
            [ text "Histórias "
            , span [ class "linha-vermelha" ] [ text "Sinistras" ]
            ]
        , p [ class "contador-resolvidos" ] [ text contador ]
        , div [ class "lista-atalhos" ] <|
            List.map viewControle page.atalhos
        , div [ class "lista-controles" ] <|
            List.map viewControle page.controles
        , ul [ class "filtro-ativo" ] <|
            List.map (\r -> li [] [ text r ]) page.filtroAtivo
        , case page.painelFiltrar of
            Just painel ->
                viewPainelFiltrar painel

            Nothing ->
                text ""
        , case page.avisoSemCorrespondencia of
            Just aviso ->
                p [ class "filtro-vazio" ] [ text aviso ]

            Nothing ->
                text ""
        , ul [ class "lista-pastas" ] <|
            List.map viewLinha page.linhas
        , case page.avisoZerar of
            Just aviso ->
                viewPainelZerar aviso page.controlesAposLinhas

            Nothing ->
                text ""
        , aposLinhas
        ]


viewPainelFiltrar : Office.PainelFiltrarOpcoes -> Html Msg
viewPainelFiltrar painel =
    div [ class "painel-filtrar" ]
        [ p [] [ text "Estado" ]
        , div [ class "painel-opcoes" ] <|
            List.map (viewOpcaoFiltro FiltroEstado) painel.estados
        , p [] [ text "Categoria" ]
        , div [ class "painel-opcoes" ] <|
            List.map (viewOpcaoFiltro FiltroCategoria) painel.categorias
        , p [] [ text "Dificuldade" ]
        , div [ class "painel-opcoes" ] <|
            List.map (viewOpcaoFiltro FiltroDificuldade) painel.dificuldades
        ]


viewOpcaoFiltro : (String -> Action) -> String -> Html Msg
viewOpcaoFiltro construtor rotulo =
    button
        [ type_ "button"
        , class "controle"
        , onClick (OfficeMsg (construtor rotulo))
        ]
        [ text rotulo ]


viewPainelZerar : String -> List String -> Html Msg
viewPainelZerar aviso controles =
    div [ class "painel-zerar" ]
        [ h2 [] [ text "Zerar progresso?" ]
        , p [] [ text aviso ]
        , div [ class "painel-zerar-acoes" ] <|
            List.map viewControle controles
        ]


viewLinha : Office.LinhaLista -> Html Msg
viewLinha linha =
    li []
        [ button
            [ type_ "button"
            , class "linha-pasta"
            , onClick (OfficeMsg (AbrirPasta linha.numero))
            ]
            [ div [ class "linha-principal" ]
                [ div [ class "linha-esq" ]
                    [ div [ class "linha-numero-titulo" ]
                        [ span [ class "linha-numero" ] [ text (numeroTresDigitos linha.numero) ]
                        , span [ class "linha-titulo" ] [ text linha.titulo ]
                        ]
                    , div [ class "linha-meta" ]
                        [ p [ class "linha-categoria" ] [ text linha.categoria ]
                        , p [ class "linha-dificuldade" ]
                            [ viewPips linha.dificuldade
                            , span [] [ text (" " ++ linha.dificuldade) ]
                            ]
                        ]
                    , case linha.detalhes of
                        [] ->
                            text ""

                        ds ->
                            ul [ class "linha-detalhes" ] <|
                                List.map (\d -> li [] [ text d ]) ds
                    ]
                , span
                    [ class <|
                        "carimbo-estado"
                            ++ carimboEstadoClasse linha.estado
                    ]
                    [ text (carimboEstadoTexto linha.estado) ]
                ]
            ]
        ]


viewComoJogar : Office.ComoJogarPage -> Html Msg
viewComoJogar page =
    div [ class "pagina-estatica" ]
        [ viewFaixaEstatica "■ COMO JOGAR" page.controles
        , div [ class "como-jogar-texto" ] <|
            List.map (\par -> p [] [ text par ]) page.paragrafos
        ]


viewCreditos : Office.CreditosPage -> Html Msg
viewCreditos page =
    div [ class "pagina-estatica" ]
        [ viewFaixaEstatica "■ CRÉDITOS" page.controles
        , div [ class "creditos-texto" ] <|
            List.map (\bloco -> p [ class "creditos-bloco" ] [ text bloco ]) page.blocos
        ]


viewCapa : Office.CapaPage -> Html Msg
viewCapa capa =
    let
        nav =
            List.filter (\c -> c /= "Ler o caso") capa.controles

        temLer =
            List.member "Ler o caso" capa.controles
    in
    div []
        [ viewFaixaCaso capa.numero capa.estado nav
        , div [ class "capa-corpo" ]
            [ p [ class "capa-categoria" ] [ text capa.categoria ]
            , h1 [ class "capa-titulo" ] [ text capa.titulo ]
            , div [ class "capa-meta" ]
                [ viewPips capa.dificuldade
                , span [] [ text capa.dificuldade ]
                ]
            , hr [ class "capa-regra" ] []
            , if temLer then
                div [ class "capa-acao" ]
                    [ button
                        [ type_ "button"
                        , class "controle controle-primario"
                        , onClick (OfficeMsg LerOCaso)
                        ]
                        [ text "Ler o caso" ]
                    ]

              else
                text ""
            ]
        ]


viewCenario : Office.CenarioPage -> Html Msg
viewCenario cen =
    let
        status =
            if cen.carimbo then
                "Resolvido"

            else
                "Em andamento"

        nDicas =
            List.length cen.dicas
    in
    div [ class "pagina-cenario" ]
        [ viewFaixaCaso cen.numero status cen.controles
        , div [ class "cenario-identidade" ]
            [ p [ class "capa-categoria" ] [ text cen.categoria ]
            , div [ class "titulo-com-carimbo" ]
                [ h2 [] [ text cen.titulo ]
                , if cen.carimbo then
                    span [ class "carimbo-resolvido-pagina" ] [ text "Resolvido" ]

                  else
                    text ""
                ]
            , p [ class "linha-meta" ]
                [ viewPips cen.dificuldade
                , span [] [ text (" " ++ cen.dificuldade) ]
                ]
            ]
        , div [ class "bloco-dicas" ]
            [ p [ class "bloco-dicas-titulo" ] [ text "Dicas" ]
            , ul [ class "dica-chips" ] <|
                List.map (viewDicaChip nDicas) (List.range 1 4)
            ]
        , p [ class "cenario-texto" ] [ text cen.cenario ]
        , ul [ class "dicas-abertas" ] <|
            List.indexedMap viewDicaAberta cen.dicas
        , case cen.verdade of
            Just v ->
                div [ class "verdade-bloco" ]
                    [ p [ class "verdade-rotulo" ] [ text "A verdade" ]
                    , p [ class "verdade-texto" ] [ text v ]
                    ]

            Nothing ->
                text ""
        , viewBar cen.barControles
        ]


viewFaixaEstatica : String -> List String -> Html Msg
viewFaixaEstatica titulo controles =
    viewFaixa titulo Nothing controles


viewFaixaCaso : Int -> String -> List String -> Html Msg
viewFaixaCaso numero status controles =
    viewFaixa
        ("■ CASO #" ++ numeroTresDigitos numero)
        (Just status)
        controles


viewFaixa : String -> Maybe String -> List String -> Html Msg
viewFaixa titulo maybeStatus controles =
    let
        ( lista, nav ) =
            List.partition (\c -> c == "Lista") controles
    in
    div [ class "faixa-sticky" ]
        (List.filterMap identity <|
            [ List.head lista |> Maybe.map (\c -> div [] [ viewControle c ])
            , Just (span [ class "faixa-titulo" ] [ text titulo ])
            , if List.isEmpty nav then
                Nothing

              else
                Just (div [ class "faixa-nav" ] <| List.map viewControle nav)
            , case maybeStatus of
                Just s ->
                    Just (p [ class "faixa-status" ] [ text s ])

                Nothing ->
                    Nothing
            ]
        )


viewDicaChip : Int -> Int -> Html Msg
viewDicaChip abertas indice =
    let
        rotulo =
            numeroDoisDigitos indice

        classes =
            if indice <= abertas then
                "dica-chip aberta"

            else
                "dica-chip"
    in
    li [ class classes ] [ text rotulo ]


viewDicaAberta : Int -> String -> Html Msg
viewDicaAberta index texto =
    let
        rotulo =
            "DICA "
                ++ numeroDoisDigitos (index + 1)
                ++ " / 04"
    in
    li [ class "dica-bloco" ]
        [ p [ class "dica-rotulo" ] [ text rotulo ]
        , p [] [ text texto ]
        ]


viewBar : List String -> Html Msg
viewBar controles =
    if List.isEmpty controles then
        text ""

    else
        div [ class "bar-cenario" ]
            [ div [ class "bar-cenario-inner" ] <|
                List.map viewBarControle controles
            ]


viewBarControle : String -> Html Msg
viewBarControle rotulo =
    let
        classes =
            case rotulo of
                "Revelar dica" ->
                    "controle controle-primario"

                "Revelar a verdade" ->
                    "controle controle-secundario-vermelho"

                _ ->
                    "controle controle-secundario-cream"
    in
    button
        [ type_ "button"
        , class classes
        , onClick (controleParaMsg rotulo)
        ]
        [ text rotulo ]


viewControle : String -> Html Msg
viewControle rotulo =
    button
        [ type_ "button"
        , class "controle"
        , onClick (controleParaMsg rotulo)
        ]
        [ text rotulo ]


viewPips : String -> Html Msg
viewPips dificuldade =
    let
        nivel =
            pipNivel dificuldade
    in
    span [ class "pips" ] <|
        List.map
            (\n ->
                span
                    [ class <|
                        "pip"
                            ++ (if n <= nivel then
                                    " pip-on"

                                else
                                    ""
                               )
                    ]
                    []
            )
            (List.range 1 4)


pipNivel : String -> Int
pipNivel dificuldade =
    case dificuldade of
        "Fácil" ->
            1

        "Médio" ->
            2

        "Difícil" ->
            3

        "Insano" ->
            4

        _ ->
            1


numeroTresDigitos : Int -> String
numeroTresDigitos n =
    if n < 10 then
        "00" ++ String.fromInt n

    else if n < 100 then
        "0" ++ String.fromInt n

    else
        String.fromInt n


numeroDoisDigitos : Int -> String
numeroDoisDigitos n =
    if n < 10 then
        "0" ++ String.fromInt n

    else
        String.fromInt n


carimboEstadoClasse : String -> String
carimboEstadoClasse estado =
    case estado of
        "Em andamento" ->
            " andamento"

        "Resolvido" ->
            " resolvido"

        _ ->
            ""


carimboEstadoTexto : String -> String
carimboEstadoTexto estado =
    case estado of
        "Novo" ->
            "Novo"

        "Em andamento" ->
            "Em andamento"

        "Resolvido" ->
            "Resolvido"

        _ ->
            estado


pushRoute : Url.Url -> Nav.Key -> Route -> Cmd Msg
pushRoute current key route =
    let
        hash =
            toHash route

        fragment =
            String.dropLeft 1 hash
    in
    Nav.pushUrl key (Url.toString { current | fragment = Just fragment })


controleParaMsg : String -> Msg
controleParaMsg rotulo =
    case rotulo of
        "Lista" ->
            OfficeMsg IrParaLista

        "Anterior" ->
            OfficeMsg IrAnterior

        "Próximo" ->
            OfficeMsg IrProximo

        "Ler o caso" ->
            OfficeMsg LerOCaso

        "Revelar dica" ->
            OfficeMsg RevelarDica

        "Revelar a verdade" ->
            OfficeMsg RevelarVerdade

        "Marcar como resolvido" ->
            OfficeMsg MarcarComoResolvido

        "Desmarcar" ->
            OfficeMsg Desmarcar

        "Filtrar" ->
            OfficeMsg Filtrar

        "Limpar" ->
            OfficeMsg Limpar

        "Zerar progresso" ->
            OfficeMsg ZerarProgresso

        "Confirmar" ->
            OfficeMsg Confirmar

        "Cancelar" ->
            OfficeMsg Cancelar

        "Como jogar" ->
            OfficeMsg IrComoJogar

        "Créditos" ->
            OfficeMsg IrCreditos

        _ ->
            NoOp