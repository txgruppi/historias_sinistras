module Office exposing
    ( Action(..)
    , Caso
    , Estado(..)
    , Filtro
    , Visita
    , LinhaLista
    , PastaProgresso
    , Progresso
    , Route(..)
    , Visible(..)
    , CapaPage
    , CenarioPage
    , ComoJogarPage
    , CreditosPage
    , ListaPage
    , PainelFiltrarOpcoes
    , OfficeSaida
    , estadoDe
    , filtroVazio
    , visitaVazia
    , semCorrespondencia
    , update
    , view
    )

import Dict exposing (Dict)
import Licencas


type alias Caso =
    { id : Int
    , titulo : String
    , categoria : String
    , dificuldade : String
    , cenario : String
    , dica1 : String
    , dica2 : String
    , dica3 : String
    , dica4 : String
    , verdade : String
    }


type Estado
    = Novo
    | EmAndamento
    | Resolvido


type alias PastaProgresso =
    { estado : Estado
    , dicas : Int
    , verdade : Bool
    }


type alias Progresso =
    Dict Int PastaProgresso


type Route
    = Lista
    | Pasta Int
    | ComoJogar
    | Creditos


type alias Filtro =
    { painelAberto : Bool
    , estado : Maybe Estado
    , categoria : Maybe String
    , dificuldade : Maybe String
    }


filtroVazio : Filtro
filtroVazio =
    { painelAberto = False
    , estado = Nothing
    , categoria = Nothing
    , dificuldade = Nothing
    }


type alias Visita =
    { confirmarZerar : Bool }


visitaVazia : Visita
visitaVazia =
    { confirmarZerar = False }


semCorrespondencia : String
semCorrespondencia =
    "Nenhuma pasta corresponde ao filtro."


type Action
    = IrParaLista
    | IrComoJogar
    | IrCreditos
    | IrAnterior
    | IrProximo
    | AbrirPasta Int
    | LerOCaso
    | RevelarDica
    | RevelarVerdade
    | MarcarComoResolvido
    | Desmarcar
    | Filtrar
    | Limpar
    | FiltroEstado String
    | FiltroCategoria String
    | FiltroDificuldade String
    | ZerarProgresso
    | Confirmar
    | Cancelar


type alias LinhaLista =
    { numero : Int
    , titulo : String
    , categoria : String
    , dificuldade : String
    , estado : String
    , detalhes : List String
    }


type alias PainelFiltrarOpcoes =
    { estados : List String
    , categorias : List String
    , dificuldades : List String
    }


type alias OfficeSaida =
    { filtro : Filtro
    , visita : Visita
    , route : Route
    , visible : Visible
    }


type alias ListaPage =
    { tituloPagina : String
    , atalhos : List String
    , controles : List String
    , filtroAtivo : List String
    , painelFiltrar : Maybe PainelFiltrarOpcoes
    , avisoSemCorrespondencia : Maybe String
    , linhas : List LinhaLista
    , controlesAposLinhas : List String
    }


type alias CapaPage =
    { numero : Int
    , titulo : String
    , categoria : String
    , dificuldade : String
    , estado : String
    , controles : List String
    }


type alias CenarioPage =
    { numero : Int
    , titulo : String
    , categoria : String
    , dificuldade : String
    , cenario : String
    , dicas : List String
    , verdade : Maybe String
    , controles : List String
    , barControles : List String
    , carimbo : Bool
    }


type alias ComoJogarPage =
    { controles : List String
    , titulo : String
    , paragrafos : List String
    }


type alias CreditosPage =
    { controles : List String
    , titulo : String
    , blocos : List String
    }


type Visible
    = VisLista ListaPage
    | VisCapa CapaPage
    | VisCenario CenarioPage
    | VisComoJogar ComoJogarPage
    | VisCreditos CreditosPage


estadoDe : Progresso -> Int -> Estado
estadoDe progresso id =
    Dict.get id progresso
        |> Maybe.map .estado
        |> Maybe.withDefault Novo


estadoLabel : Estado -> String
estadoLabel estado =
    case estado of
        Novo ->
            "Novo"

        EmAndamento ->
            "Em andamento"

        Resolvido ->
            "Resolvido"


mostrarCategoria : String -> String
mostrarCategoria raw =
    case raw of
        "ASSASSINATOS" ->
            "Assassinatos"

        "CRIMES IMPOSSÍVEIS" ->
            "Crimes Impossíveis"

        "MORTES MISTERIOSAS" ->
            "Mortes Misteriosas"

        "DESAPARECIMENTOS" ->
            "Desaparecimentos"

        "SEGREDOS MACABROS" ->
            "Segredos Macabros"

        "MISTÉRIOS PSICOLÓGICOS" ->
            "Mistérios Psicológicos"

        "ACIDENTES FATAIS" ->
            "Acidentes Fatais"

        _ ->
            raw


mostrarDificuldade : String -> String
mostrarDificuldade raw =
    case raw of
        "FÁCIL" ->
            "Fácil"

        "MÉDIO" ->
            "Médio"

        "DIFÍCIL" ->
            "Difícil"

        "INSANO" ->
            "Insano"

        _ ->
            raw


casoPorId : List Caso -> Int -> Maybe Caso
casoPorId casos id =
    List.filter (\c -> c.id == id) casos |> List.head


view : List Caso -> Progresso -> Filtro -> Visita -> Route -> Visible
view casos progresso filtro visita route =
    case route of
        Lista ->
            VisLista (viewLista casos progresso filtro visita)

        ComoJogar ->
            VisComoJogar viewComoJogar

        Creditos ->
            VisCreditos viewCreditos

        Pasta id ->
            case casoPorId casos id of
                Nothing ->
                    VisLista (viewLista casos progresso filtro visita)

                Just caso ->
                    case estadoDe progresso id of
                        Novo ->
                            VisCapa (viewCapa caso progresso)

                        EmAndamento ->
                            VisCenario (viewCenario caso progresso)

                        Resolvido ->
                            VisCenario (viewCenario caso progresso)


categoriasFiltrar : List String
categoriasFiltrar =
    [ "Assassinatos"
    , "Crimes Impossíveis"
    , "Mortes Misteriosas"
    , "Desaparecimentos"
    , "Segredos Macabros"
    , "Mistérios Psicológicos"
    , "Acidentes Fatais"
    ]


dificuldadesFiltrar : List String
dificuldadesFiltrar =
    [ "Fácil", "Médio", "Difícil", "Insano" ]


estadosFiltrar : List String
estadosFiltrar =
    [ "Novo", "Em andamento", "Resolvido" ]


filtroTemCriterio : Filtro -> Bool
filtroTemCriterio filtro =
    filtro.estado /= Nothing
        || filtro.categoria /= Nothing
        || filtro.dificuldade /= Nothing


filtroAtivoRotulos : Filtro -> List String
filtroAtivoRotulos filtro =
    List.filterMap identity
        [ Maybe.map estadoLabel filtro.estado
        , filtro.categoria
        , filtro.dificuldade
        ]


estadoDeTexto : String -> Maybe Estado
estadoDeTexto texto =
    case texto of
        "Novo" ->
            Just Novo

        "Em andamento" ->
            Just EmAndamento

        "Resolvido" ->
            Just Resolvido

        _ ->
            Nothing


casoAtendeFiltro : Filtro -> Progresso -> Caso -> Bool
casoAtendeFiltro filtro progresso caso =
  let
    okEstado =
      case filtro.estado of
        Nothing ->
          True
        Just e ->
          estadoDe progresso caso.id == e
    okCategoria =
      case filtro.categoria of
        Nothing ->
          True
        Just c ->
          mostrarCategoria caso.categoria == c
    okDificuldade =
      case filtro.dificuldade of
        Nothing ->
          True
        Just d ->
          mostrarDificuldade caso.dificuldade == d
  in
  okEstado && okCategoria && okDificuldade


viewLista : List Caso -> Progresso -> Filtro -> Visita -> ListaPage
viewLista casos progresso filtro visita =
    let
        filtrados =
            if filtroTemCriterio filtro then
                List.filter (casoAtendeFiltro filtro progresso) casos
            else
                casos

        linhas =
            List.map
                (\caso ->
                    let
                        estado =
                            estadoDe progresso caso.id
                    in
                    { numero = caso.id
                    , titulo = caso.titulo
                    , categoria = mostrarCategoria caso.categoria
                    , dificuldade = mostrarDificuldade caso.dificuldade
                    , estado = estadoLabel estado
                    , detalhes = detalhesLinha progresso caso.id estado
                    }
                )
                filtrados

        controles =
            if filtroTemCriterio filtro then
                [ "Filtrar", "Limpar" ]
            else
                [ "Filtrar" ]

        painel =
            if filtro.painelAberto then
                Just
                    { estados = estadosFiltrar
                    , categorias = categoriasFiltrar
                    , dificuldades = dificuldadesFiltrar
                    }

            else
                Nothing

        aviso =
            if filtroTemCriterio filtro && List.isEmpty linhas then
                Just semCorrespondencia

            else
                Nothing

        aposLinhas =
            if visita.confirmarZerar then
                [ "Confirmar", "Cancelar" ]

            else
                [ "Zerar progresso" ]
    in
    { tituloPagina = "Histórias Sinistras"
    , atalhos = [ "Como jogar", "Créditos" ]
    , controles = controles
    , filtroAtivo = filtroAtivoRotulos filtro
    , painelFiltrar = painel
    , avisoSemCorrespondencia = aviso
    , linhas = linhas
    , controlesAposLinhas = aposLinhas
    }


detalhesLinha : Progresso -> Int -> Estado -> List String
detalhesLinha progresso id estado =
    case estado of
        EmAndamento ->
            Dict.get id progresso
                |> Maybe.map detalhesEmAndamento
                |> Maybe.withDefault []

        _ ->
            []


detalhesEmAndamento : PastaProgresso -> List String
detalhesEmAndamento pasta =
    let
        dicas =
            case pasta.dicas of
                0 ->
                    "0 dicas"

                1 ->
                    "1 dica"

                n ->
                    String.fromInt n ++ " dicas"
    in
    if pasta.verdade then
        [ dicas, "verdade" ]

    else
        [ dicas ]


comoJogarParagrafos : List String
comoJogarParagrafos =
    [ "Histórias Sinistras é um jogo de mistério em português. Em cada pasta você lê o cenário, monta uma teoria sobre o que aconteceu e tenta explicar o estranho caso."
    , "Abra uma dica só quando estiver travado. As dicas seguem em ordem e ficam visíveis depois de abertas."
    , "Revelar a verdade é sua escolha. A verdade explica o caso de fato; abri-la não marca a pasta como resolvida."
    , "Use Marcar como resolvido no cenário somente se você conta a pasta como resolvida. Desmarcar volta o estado para Em andamento."
    , "Em grupo, um Guardião do Segredo lê a verdade em silêncio e responde às perguntas dos outros apenas com sim, não ou irrelevante. O mesmo escritório serve para todos; não há outra tela nem papel separado no aplicativo."
    ]


viewComoJogar : ComoJogarPage
viewComoJogar =
    { controles = [ "Lista" ]
    , titulo = "Como jogar"
    , paragrafos = comoJogarParagrafos
    }


viewCreditos : CreditosPage
viewCreditos =
    { controles = [ "Lista" ]
    , titulo = "Créditos"
    , blocos = Licencas.blocosCreditos
    }


controlesTopo : Int -> List String
controlesTopo id =
    List.filterMap identity
        [ Just "Lista"
        , if id > 1 then
            Just "Anterior"

          else
            Nothing
        , if id < 60 then
            Just "Próximo"

          else
            Nothing
        ]


viewCapa : Caso -> Progresso -> CapaPage
viewCapa caso progresso =
    { numero = caso.id
    , titulo = caso.titulo
    , categoria = mostrarCategoria caso.categoria
    , dificuldade = mostrarDificuldade caso.dificuldade
    , estado = estadoLabel (estadoDe progresso caso.id)
    , controles = controlesTopo caso.id ++ [ "Ler o caso" ]
    }


viewCenario : Caso -> Progresso -> CenarioPage
viewCenario caso progresso =
    let
        pasta =
            Dict.get caso.id progresso
    in
    { numero = caso.id
    , titulo = caso.titulo
    , categoria = mostrarCategoria caso.categoria
    , dificuldade = mostrarDificuldade caso.dificuldade
    , cenario = caso.cenario
    , dicas = dicasVisiveis caso pasta
    , verdade =
        pasta
            |> Maybe.andThen
                (\p ->
                    if p.verdade then
                        Just caso.verdade

                    else
                        Nothing
                )
    , controles = controlesTopo caso.id
    , barControles = barControlesCenario pasta
    , carimbo =
        pasta
            |> Maybe.map .estado
            |> Maybe.map (\estado -> estado == Resolvido)
            |> Maybe.withDefault False
    }


dicasVisiveis : Caso -> Maybe PastaProgresso -> List String
dicasVisiveis caso maybePasta =
    case maybePasta of
        Nothing ->
            []

        Just pasta ->
            List.take pasta.dicas [ caso.dica1, caso.dica2, caso.dica3, caso.dica4 ]


barControlesCenario : Maybe PastaProgresso -> List String
barControlesCenario maybePasta =
    let
        pasta =
            Maybe.withDefault { estado = EmAndamento, dicas = 0, verdade = False } maybePasta
    in
    List.filterMap identity
        [ if pasta.dicas < 4 then
            Just "Revelar dica"

          else
            Nothing
        , if pasta.verdade then
            Nothing

          else
            Just "Revelar a verdade"
        , case pasta.estado of
            Resolvido ->
                Just "Desmarcar"

            _ ->
                Just "Marcar como resolvido"
        ]


aplicarFiltro : Filtro -> Filtro
aplicarFiltro proximo =
    { proximo | painelAberto = False }


pack : Progresso -> Filtro -> Visita -> Route -> List Caso -> ( Progresso, OfficeSaida )
pack progresso filtro visita pagina casos =
    ( progresso
    , { filtro = filtro
      , visita = visita
      , route = pagina
      , visible = view casos progresso filtro visita pagina
      }
    )


update : List Caso -> Progresso -> Filtro -> Visita -> Route -> Action -> ( Progresso, OfficeSaida )
update casos progresso filtro visita route action =
    case action of
        Filtrar ->
            let
                proximo =
                    { filtro | painelAberto = not filtro.painelAberto }
            in
            pack progresso proximo visita route casos

        Limpar ->
            pack progresso filtroVazio visita route casos

        ZerarProgresso ->
            case route of
                Lista ->
                    pack progresso filtro { visita | confirmarZerar = True } route casos

                _ ->
                    pack progresso filtro visita route casos

        Cancelar ->
            pack progresso filtro { visita | confirmarZerar = False } route casos

        Confirmar ->
            pack Dict.empty filtro { visita | confirmarZerar = False } route casos

        FiltroEstado texto ->
            case estadoDeTexto texto of
                Just estado ->
                    let
                        proximo =
                            { filtro | estado = Just estado }
                                |> aplicarFiltro
                    in
                    pack progresso proximo visita route casos

                Nothing ->
                    pack progresso filtro visita route casos

        FiltroCategoria categoria ->
            let
                proximo =
                    { filtro | categoria = Just categoria }
                        |> aplicarFiltro
            in
            pack progresso proximo visita route casos

        FiltroDificuldade dificuldade ->
            let
                proximo =
                    { filtro | dificuldade = Just dificuldade }
                        |> aplicarFiltro
            in
            pack progresso proximo visita route casos

        IrParaLista ->
            pack progresso filtro visita Lista casos

        IrComoJogar ->
            pack progresso filtro visita ComoJogar casos

        IrCreditos ->
            pack progresso filtro visita Creditos casos

        IrAnterior ->
            case route of
                Pasta id ->
                    if id > 1 then
                        let
                            newRoute =
                                Pasta (id - 1)
                        in
                        pack progresso filtro visita newRoute casos

                    else
                        pack progresso filtro visita route casos

                _ ->
                    pack progresso filtro visita route casos

        IrProximo ->
            case route of
                Pasta id ->
                    if id < 60 && casoPorId casos (id + 1) /= Nothing then
                        let
                            newRoute =
                                Pasta (id + 1)
                        in
                        pack progresso filtro visita newRoute casos

                    else
                        pack progresso filtro visita route casos

                _ ->
                    pack progresso filtro visita route casos

        AbrirPasta id ->
            if casoPorId casos id == Nothing then
                pack progresso filtro visita Lista casos

            else
                let
                    newRoute =
                        Pasta id
                in
                pack progresso filtro visita newRoute casos

        LerOCaso ->
            case route of
                Pasta id ->
                    case estadoDe progresso id of
                        Novo ->
                            let
                                novoProgresso =
                                    Dict.insert id
                                        { estado = EmAndamento, dicas = 0, verdade = False }
                                        progresso

                                newRoute =
                                    Pasta id
                            in
                            pack novoProgresso filtro visita newRoute casos

                        _ ->
                            pack progresso filtro visita route casos

                _ ->
                    pack progresso filtro visita route casos

        RevelarDica ->
            case route of
                Pasta id ->
                    case Dict.get id progresso of
                        Just pasta ->
                            if pasta.dicas < 4 then
                                let
                                    nova =
                                        { pasta | dicas = pasta.dicas + 1 }

                                    novoProgresso =
                                        Dict.insert id nova progresso
                                in
                                pack novoProgresso filtro visita route casos

                            else
                                pack progresso filtro visita route casos

                        Nothing ->
                            pack progresso filtro visita route casos

                _ ->
                    pack progresso filtro visita route casos

        RevelarVerdade ->
            case route of
                Pasta id ->
                    case Dict.get id progresso of
                        Just pasta ->
                            if pasta.verdade then
                                pack progresso filtro visita route casos

                            else
                                let
                                    nova =
                                        { pasta | verdade = True }

                                    novoProgresso =
                                        Dict.insert id nova progresso
                                in
                                pack novoProgresso filtro visita route casos

                        Nothing ->
                            pack progresso filtro visita route casos

                _ ->
                    pack progresso filtro visita route casos

        MarcarComoResolvido ->
            case route of
                Pasta id ->
                    case Dict.get id progresso of
                        Just pasta ->
                            if pasta.estado == Resolvido then
                                pack progresso filtro visita route casos

                            else
                                let
                                    nova =
                                        { pasta | estado = Resolvido }

                                    novoProgresso =
                                        Dict.insert id nova progresso
                                in
                                pack novoProgresso filtro visita route casos

                        Nothing ->
                            pack progresso filtro visita route casos

                _ ->
                    pack progresso filtro visita route casos

        Desmarcar ->
            case route of
                Pasta id ->
                    case Dict.get id progresso of
                        Just pasta ->
                            if pasta.estado == Resolvido then
                                let
                                    nova =
                                        { pasta | estado = EmAndamento }

                                    novoProgresso =
                                        Dict.insert id nova progresso
                                in
                                pack novoProgresso filtro visita route casos

                            else
                                pack progresso filtro visita route casos

                        Nothing ->
                            pack progresso filtro visita route casos

                _ ->
                    pack progresso filtro visita route casos