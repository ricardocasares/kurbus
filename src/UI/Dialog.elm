module UI.Dialog exposing (dialog)

import Html exposing (Attribute, Html, node)
import Html.Attributes exposing (attribute)
import Html.Events exposing (on)
import Json.Decode as D


dialog : Bool -> msg -> List (Attribute msg) -> List (Html msg) -> Html msg
dialog open close attrs children =
    node "elm-dialog"
        (if open then
            [ attribute "open" "" ]

         else
            []
        )
        [ node "dialog" (onDialogClose close :: attrs) children ]


onDialogClose : msg -> Attribute msg
onDialogClose msg =
    on "close" (D.succeed msg)
