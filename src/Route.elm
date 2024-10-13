module Route exposing (Route(..), fromUrl, href)

import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, map, oneOf, s, string, top)


type Route
    = HomeRoute
    | BusStopRoute String
    | TramStopRoute String
    | NotFoundRoute


parser : Parser (Route -> a) a
parser =
    oneOf
        [ map HomeRoute top
        , map BusStopRoute (s "stop" </> s "bus" </> string)
        , map TramStopRoute (s "stop" </> s "tram" </> string)
        ]


fromUrl : Url -> Route
fromUrl url =
    url
        |> Parser.parse parser
        |> Maybe.withDefault NotFoundRoute


href : Route -> String
href route =
    case route of
        HomeRoute ->
            "/"

        BusStopRoute id ->
            "/stop/bus/" ++ id

        TramStopRoute id ->
            "/stop/tram/" ++ id

        NotFoundRoute ->
            "/404"
