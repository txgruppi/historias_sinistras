port module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Casos
import Dict
import Html exposing (Html, button, div, h1, h2, li, p, text, ul)
import Html.Attributes exposing (class, type_)
import Html.Events exposing (onClick)
import Http
import Office exposing (..)
import Route exposing (fromFragment, toHash)
import Save exposing (decodeProgresso, encodeProgresso)
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


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        , onUrlRequest = UrlRequested
        , onUrlChange = UrlChanged
        }


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key =
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
            { url = "casos.json"
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
    div []
        [ h1 [] [ text page.tituloPagina ]
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
        , div [ class "lista-apos-linhas" ] <|
            List.map viewControle page.controlesAposLinhas
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


viewLinha : Office.LinhaLista -> Html Msg
viewLinha linha =
    li []
        [ button
            [ type_ "button"
            , class "linha-pasta"
            , onClick (OfficeMsg (AbrirPasta linha.numero))
            ]
            [ p [ class "linha-numero" ] [ text (String.fromInt linha.numero) ]
            , p [ class "linha-titulo" ] [ text linha.titulo ]
            , p [ class "linha-meta" ]
                [ text (linha.categoria ++ " · " ++ linha.dificuldade) ]
            , p [ class "linha-estado" ] [ text linha.estado ]
            , ul [ class "linha-detalhes" ] <|
                List.map (\d -> li [] [ text d ]) linha.detalhes
            ]
        ]


viewComoJogar : Office.ComoJogarPage -> Html Msg
viewComoJogar page =
    div []
        [ viewNav page.controles
        , h1 [] [ text page.titulo ]
        , div [ class "como-jogar-texto" ] <|
            List.map (\par -> p [] [ text par ]) page.paragrafos
        ]


viewCreditos : Office.CreditosPage -> Html Msg
viewCreditos page =
    div []
        [ viewNav page.controles
        , h1 [] [ text page.titulo ]
        , div [ class "creditos-texto" ] <|
            List.map (\bloco -> p [ class "creditos-bloco" ] [ text bloco ]) page.blocos
        ]


viewCapa capa =
    div []
        [ viewNav capa.controles
        , h1 [] [ text (String.fromInt capa.numero) ]
        , h2 [] [ text capa.titulo ]
        , p [ class "identidade" ]
            [ text (capa.categoria ++ " · " ++ capa.dificuldade) ]
        , p [ class "capa-estado" ] [ text capa.estado ]
        ]


viewCenario : Office.CenarioPage -> Html Msg
viewCenario cen =
    div [ class "pagina-cenario" ]
        [ viewNav cen.controles
        , h1 [] [ text (String.fromInt cen.numero) ]
        , h2 [] [ text cen.titulo ]
        , p [ class "identidade" ]
            [ text (cen.categoria ++ " · " ++ cen.dificuldade) ]
        , p [ class "cenario-texto" ] [ text cen.cenario ]
        , ul [ class "dicas-abertas" ] <|
            List.map (\d -> li [] [ text d ]) cen.dicas
        , case cen.verdade of
            Just v ->
                p [ class "verdade-texto" ] [ text v ]

            Nothing ->
                text ""
        , viewBar cen.carimbo cen.barControles
        ]


viewNav : List String -> Html Msg
viewNav controles =
    div [ class "nav-topo" ] <|
        List.map viewControle controles


viewBar : Bool -> List String -> Html Msg
viewBar carimbo controles =
    if List.isEmpty controles then
        text ""

    else
        div [ class "bar-cenario" ]
            [ div [ class "bar-cenario-inner" ] <|
                List.map (viewBarControle carimbo) controles
            ]


viewBarControle : Bool -> String -> Html Msg
viewBarControle carimbo rotulo =
    let
        classes =
            if carimbo && rotulo == "Desmarcar" then
                "controle carimbo-resolvido"

            else
                "controle"
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