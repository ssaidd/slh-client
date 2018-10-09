module AppCss exposing (buttonStyle, centerDiv)

import Html exposing (..)
import Html.Attributes exposing (..)


buttonStyle : List (Attribute msg)
buttonStyle =
    List.map (\(a, b) -> style a b)
        [ ("padding", "14px 20px")
        , ( "margin-top", "10px" )
        , ( "margin-right", "10px" )
        , ( "border-radius", "4px" )
        , ( "border", "none" )
        , ( "font-size", "16px" )
        ]


centerDiv : List (Attribute msg)
centerDiv =
    List.map (\(a, b) -> style a b)
        [ ("margin", "0 auto")
        , ("padding", "20px")
        ]
