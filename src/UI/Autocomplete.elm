module UI.Autocomplete exposing (..)

import Autocomplete exposing (ViewState)
import Autocomplete.View exposing (Events)
import Html exposing (Attribute, Html, div, input, li, span, text, ul)
import Html.Attributes exposing (autofocus, class, placeholder, spellcheck, value)


type alias AutcompleteConfig a msg =
    { view : ViewState a
    , events : Events msg
    , render : (Int -> List (Attribute msg)) -> Maybe Int -> Int -> a -> Html msg
    }


autocomplete : AutcompleteConfig a msg -> Html msg
autocomplete { view, events, render } =
    div [ class "dropdown w-full" ]
        [ div [ class "text-gray-dim p-2 w-full font-mono flex items-center gap-2 input input-bordered input-md rounded" ]
            [ input (events.inputEvents ++ [ value view.query, spellcheck False, autofocus True, placeholder "Search for a stop", class "bg-base-100 grow outline-none" ]) []
            , case view.status of
                Autocomplete.NotFetched ->
                    span [ class "i-search" ] []

                Autocomplete.Fetching ->
                    span [ class "i-wait animate-pulse" ] []

                Autocomplete.Error _ ->
                    span [ class "i-search" ] []

                Autocomplete.FetchedChoices ->
                    span [ class "i-search" ] []
            ]
        , case view.status of
            Autocomplete.NotFetched ->
                ul [] []

            Autocomplete.Fetching ->
                ul [] []

            Autocomplete.Error err ->
                ul [ class "menu dropdown-content w-full bg-error text-error-content" ] [ li [ class "p-2" ] [ text err ] ]

            Autocomplete.FetchedChoices ->
                case view.choices of
                    [] ->
                        ul [] []

                    _ ->
                        ul [ class "menu dropdown-content w-full bg-base-200 rounded shadow-lg z-10" ] (List.indexedMap (render events.choiceEvents view.selectedIndex) view.choices)
        ]
