module Main exposing (main)

import Autocomplete exposing (Autocomplete, choices)
import Autocomplete.View as AutocompleteView
import Browser exposing (Document, UrlRequest(..))
import Browser.Navigation exposing (Key, pushUrl)
import Data.Stop exposing (AutocompleteStopItem, AutocompleteStopKind(..), Passage, PassageStatus(..), StopPassages, stopItemListDecoder, stopPassagesDecoder)
import Html exposing (Attribute, Html, a, div, li, span, text)
import Html.Attributes exposing (class, href)
import Http
import Json.Decode as D
import Json.Encode as E
import RemoteData exposing (RemoteData(..), WebData)
import Route exposing (Route(..))
import Task exposing (Task)
import UI.Autocomplete exposing (autocomplete)
import Url exposing (Url)


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , update = update
        , view = view
        , onUrlChange = UrlChanged
        , onUrlRequest = UrlRequested
        , subscriptions = subscriptions
        }


type alias Model =
    { key : Key
    , route : Route
    , autocompleteStop : Autocomplete AutocompleteStopItem
    , selectedStop : Maybe AutocompleteStopItem
    , stopPassages : WebData StopPassages
    }


type Msg
    = NoOp
    | UrlChanged Url
    | UrlRequested UrlRequest
    | OnAutocomplete (Autocomplete.Msg AutocompleteStopItem)
    | OnAutocompleteSelect
    | GotStopPassages (WebData StopPassages)


init : () -> Url -> Key -> ( Model, Cmd Msg )
init _ url key =
    fetch
        { key = key
        , route = Route.fromUrl url
        , autocompleteStop = Autocomplete.init { query = "", choices = [], ignoreList = [] } fetcher
        , selectedStop = Nothing
        , stopPassages = NotAsked
        }
        (Route.fromUrl url)


resolver : Autocomplete.Choices AutocompleteStopItem -> Http.Resolver String (Autocomplete.Choices AutocompleteStopItem)
resolver lastChoices =
    Http.stringResolver
        (\response ->
            case response of
                Http.BadUrl_ url ->
                    Err <| "Bad url: " ++ url

                Http.Timeout_ ->
                    Err "Request timed out"

                Http.NetworkError_ ->
                    Err "Network error, are you offline?"

                Http.BadStatus_ _ status ->
                    Err <| "Bad status: " ++ status

                Http.GoodStatus_ _ body ->
                    D.decodeString stopItemListDecoder body
                        |> Result.map (\choices -> { lastChoices | choices = choices })
                        |> Result.mapError (\_ -> "Shape error, it's on us.")
        )


fetcher : Autocomplete.Choices AutocompleteStopItem -> Task String (Autocomplete.Choices AutocompleteStopItem)
fetcher choices =
    Http.task
        { method = "POST"
        , headers = []
        , url = "/api/autocomplete"
        , body = Http.stringBody "application/json" (E.encode 0 <| E.object [ ( "search", E.string choices.query ) ])
        , timeout = Nothing
        , resolver = resolver choices
        }


fetch : Model -> Route -> ( Model, Cmd Msg )
fetch model route =
    case route of
        HomeRoute ->
            ( { model | route = HomeRoute }, Cmd.none )

        NotFoundRoute ->
            ( { model | route = NotFoundRoute }, Cmd.none )

        BusStopRoute id ->
            ( { model | stopPassages = Loading, route = BusStopRoute id }
            , Http.get
                { url = "/api/stop/bus/" ++ id
                , expect = Http.expectJson (RemoteData.fromResult >> GotStopPassages) stopPassagesDecoder
                }
            )

        TramStopRoute id ->
            ( { model | stopPassages = Loading, route = BusStopRoute id }
            , Http.get
                { url = "/api/stop/tram/" ++ id
                , expect = Http.expectJson (RemoteData.fromResult >> GotStopPassages) stopPassagesDecoder
                }
            )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        UrlChanged url ->
            fetch model (Route.fromUrl url)

        UrlRequested _ ->
            ( model, Cmd.none )

        OnAutocomplete automsg ->
            let
                ( state, cmd ) =
                    Autocomplete.update automsg model.autocompleteStop
            in
            ( { model | autocompleteStop = state }, Cmd.map OnAutocomplete cmd )

        OnAutocompleteSelect ->
            let
                query =
                    Autocomplete.query model.autocompleteStop

                selectedStop =
                    Autocomplete.selectedValue model.autocompleteStop
            in
            ( { model
                | selectedStop = selectedStop
                , autocompleteStop =
                    Autocomplete.reset
                        { query = Maybe.withDefault query <| Maybe.map .name selectedStop
                        , choices = []
                        , ignoreList = []
                        }
                        model.autocompleteStop
              }
            , case selectedStop of
                Just stop ->
                    pushUrl model.key
                        (case stop.kind of
                            Bus ->
                                Route.href (BusStopRoute stop.id)

                            Tram ->
                                Route.href (TramStopRoute stop.id)

                            Other ->
                                Route.href (BusStopRoute stop.id)
                        )

                Nothing ->
                    Cmd.none
            )

        GotStopPassages data ->
            ( { model | stopPassages = data }, Cmd.none )


view : Model -> Document Msg
view model =
    { title = "Kurwa"
    , body =
        [ div [ class "p-2" ]
            [ autocomplete
                { view = Autocomplete.viewState model.autocompleteStop
                , events =
                    AutocompleteView.events
                        { onSelect = OnAutocompleteSelect
                        , mapHtml = OnAutocomplete
                        }
                , render = stopChoiceView
                }
            ]
        , case model.route of
            HomeRoute ->
                div [] []

            BusStopRoute _ ->
                stopView model

            TramStopRoute _ ->
                stopView model

            NotFoundRoute ->
                text "NotFound"
        ]
    }


stopView : Model -> Html msg
stopView model =
    case model.stopPassages of
        NotAsked ->
            text "NotAsked"

        Failure err ->
            case err of
                Http.BadStatus msg ->
                    text (String.fromInt msg)

                Http.BadBody a ->
                    text a

                Http.NetworkError ->
                    text "Seems there's some trouble in your network"

                Http.BadUrl url ->
                    text ("Bad url: " ++ url)

                Http.Timeout ->
                    text "The request timed out"

        Loading ->
            div [ class "p-2" ]
                [ div [ class "flex gap-2 flex-col p-2 font-mono font-light border rounded border-neutral" ]
                    [ div [ class "animate-pulse" ] [ text "Loading" ]
                    , div [ class "flex flex-col p-2 bg-orange-950 rounded" ]
                        (List.map
                            passageView
                            [ { patternText = "69", direction = "The data", status = Stopping, actualRelativeTime = 0, plannedTime = "01:00" }
                            , { patternText = "42", direction = "Will come", status = Stopping, actualRelativeTime = 60, plannedTime = "01:00" }
                            , { patternText = "13", direction = "Very, very soon", status = Stopping, actualRelativeTime = 120, plannedTime = "01:00" }
                            , { patternText = "24", direction = "Please wait ...", status = Stopping, actualRelativeTime = 240, plannedTime = "01:00" }
                            ]
                        )
                    ]
                ]

        Success data ->
            div [ class "p-2" ]
                [ div [ class "flex gap-2 flex-col p-2 font-mono font-light border rounded border-neutral" ]
                    [ div [ class "" ] [ text data.stopName ]
                    , div [ class "flex flex-col p-2 bg-orange-950 rounded" ] (List.map passageView data.actual)
                    ]
                ]


passageView : Passage -> Html msg
passageView passage =
    div [ class "flex gap-3 text-orange-500" ]
        [ div [ class "w-6 text-right shrink-0" ] [ text passage.patternText ]
        , div [ class "grow" ] [ div [ class "w-52 sm:w-full text-ellipsis overflow-hidden whitespace-nowrap" ] [ text passage.direction ] ]
        , div [ class "tabular-nums" ] [ passageStatusView passage ]
        ]


passageStatusView : Passage -> Html msg
passageStatusView passage =
    case passage.status of
        Planned ->
            text (String.fromInt (toMinutes passage.actualRelativeTime) ++ " min")

        Predicted ->
            text (String.fromInt (toMinutes passage.actualRelativeTime) ++ " min")

        Stopping ->
            span [ class "animate-pulse" ] [ text ">>>" ]

        Departed ->
            text ">>>"


stopChoiceView : (Int -> List (Attribute Msg)) -> Maybe Int -> Int -> AutocompleteStopItem -> Html Msg
stopChoiceView events selectedIndex index stop =
    li []
        [ a
            (List.append
                [ selectedStopView selectedIndex index
                , href (Route.href (BusStopRoute stop.id))
                , class "p-2 rounded flex flex-row items-center font-mono"
                ]
                (events index)
            )
            [ div [ class "grow" ] [ text stop.name ]
            , stopKindView stop
            ]
        ]


stopKindView : AutocompleteStopItem -> Html msg
stopKindView stop =
    case stop.kind of
        Bus ->
            span [ class "text-neutral-content" ] [ text "Bus" ]

        Tram ->
            span [ class "text-neutral-content" ] [ text "Tram" ]

        Other ->
            span [ class "text-neutral-content" ] [ text "Other" ]


selectedStopView : Maybe Int -> Int -> Attribute msg
selectedStopView selectedIndex index =
    if Autocomplete.isSelected selectedIndex index then
        class "bg-orange-950 text-orange-500"

    else
        class ""


toMinutes : Int -> Int
toMinutes seconds =
    floor (toFloat seconds / 60)


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none
