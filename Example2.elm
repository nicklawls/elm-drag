module Main (main) where

import Drag exposing (..)
import Signal exposing (foldp)
import Html exposing (Html)
import Svg exposing (Svg)
import Svg.Events
import Svg.Attributes


hover : Signal.Mailbox (Maybe Int)
hover =
    Signal.mailbox Nothing


box : Int -> String -> (Float,Float) -> Svg
box id msg (x,y) =
    Svg.text'
        [ Svg.Events.onMouseOver (Signal.message hover.address (Just id) )
        , Svg.Events.onMouseOut (Signal.message hover.address Nothing)
        , Svg.Attributes.x <| toString x
        , Svg.Attributes.y <| toString y
        ]
        [ Svg.text msg ]


moveBy : (Int, Int) -> (Float,Float) -> (Float,Float)
moveBy ( dx, dy ) ( x, y ) =
    ( x + toFloat dx, y + toFloat dy )


main : Signal Html
main =
    let
        update m =
            case m of
                Just ( 1, MoveBy ( dx, dy ) ) ->
                    \( p1, p2 ) -> ( moveBy ( dx, dy ) p1, p2 )

                Just ( 2, MoveBy ( dx, dy ) ) ->
                    \( p1, p2 ) -> ( p1, moveBy ( dx, dy ) p2 )

                _ ->
                    identity
    in
        Signal.map
            (\(p1,p2) -> Svg.svg
                    [ Svg.Attributes.height "200"
                    , Svg.Attributes.width "200"
                    , Svg.Attributes.viewBox "0 0 200 200"
                    ]
                    [ box 1 "drag me around" p1, box 2 "and me too" p2 ]
            )
            (foldp update ( ( 50, 50 ), ( 150, 150 ) ) (trackMany Nothing hover.signal))
