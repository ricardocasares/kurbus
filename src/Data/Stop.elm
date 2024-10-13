module Data.Stop exposing (..)

import Codec exposing (Codec, array, buildObject, decoder, enum, field, int, list, object, optionalField, string)


type PassageStatus
    = Planned
    | Predicted
    | Stopping
    | Departed


passageStatusCodec : Codec PassageStatus
passageStatusCodec =
    enum string
        [ ( "PLANNED", Planned )
        , ( "PREDICTED", Predicted )
        , ( "STOPPING", Stopping )
        , ( "DEPARTED", Departed )
        ]


type alias Passage =
    { status : PassageStatus
    , patternText : String
    , direction : String
    , plannedTime : String
    , actualRelativeTime : Int
    }


passageCodec : Codec Passage
passageCodec =
    object Passage
        |> field "status" .status passageStatusCodec
        |> field "patternText" .patternText string
        |> field "direction" .direction string
        |> field "plannedTime" .plannedTime string
        |> field "actualRelativeTime" .actualRelativeTime int
        |> buildObject


type alias StopPassages =
    { stopName : String
    , stopShortName : String
    , actual : List Passage
    }


stopPassagesCodec : Codec StopPassages
stopPassagesCodec =
    object StopPassages
        |> field "stopName" .stopName string
        |> field "stopShortName" .stopShortName string
        |> field "actual" .actual (list passageCodec)
        |> buildObject


stopPassagesDecoder : Codec.Decoder StopPassages
stopPassagesDecoder =
    decoder stopPassagesCodec


type AutocompleteStopKind
    = Bus
    | Tram
    | Other


stopKindCodec : Codec AutocompleteStopKind
stopKindCodec =
    enum string [ ( "bus", Bus ), ( "tram", Tram ), ( "other", Other ) ]


type alias AutocompleteStopItem =
    { id : String
    , name : String
    , kind : AutocompleteStopKind
    }


stopItemCodec : Codec AutocompleteStopItem
stopItemCodec =
    object AutocompleteStopItem
        |> field "shortName" .id string
        |> field "name" .name string
        |> field "category" .kind stopKindCodec
        |> Codec.buildObject


stopItemListCodec : Codec (List AutocompleteStopItem)
stopItemListCodec =
    list stopItemCodec


stopItemListDecoder : Codec.Decoder (List AutocompleteStopItem)
stopItemListDecoder =
    decoder stopItemListCodec
