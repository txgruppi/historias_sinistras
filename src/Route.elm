module Route exposing (fromFragment, fromHash, toHash)

import Office exposing (Route(..))


fromFragment : Maybe String -> Route
fromFragment maybe =
    case maybe of
        Nothing ->
            Lista

        Just hash ->
            fromHash hash


fromHash : String -> Route
fromHash hash =
  let
    trimmed =
      if String.startsWith "#" hash then
        String.dropLeft 1 hash

      else
        hash
  in
  case String.split "/" trimmed of
    [] ->
      Lista

    [ "" ] ->
      Lista

    "" :: rest ->
      parseParts rest

    parts ->
      parseParts parts


parseParts : List String -> Route
parseParts parts =
  case parts of
    [ "caso", idStr ] ->
      case String.toInt idStr of
        Just id ->
          if id >= 1 && id <= 60 then
            Pasta id

          else
            Lista

        Nothing ->
          Lista

    [ "como-jogar" ] ->
      ComoJogar

    [ "creditos" ] ->
      Creditos

    _ ->
      Lista


toHash : Route -> String
toHash route =
  case route of
    Lista ->
      "#/"

    Pasta id ->
      "#/caso/" ++ String.fromInt id

    ComoJogar ->
      "#/como-jogar"

    Creditos ->
      "#/creditos"