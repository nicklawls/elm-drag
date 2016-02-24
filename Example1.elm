module Main (main) where

import Drag exposing (..)
import Signal exposing (foldp)
import Html exposing (Html)
import Svg exposing (Svg)
import Svg.Events
import Svg.Attributes


hover : Signal.Mailbox Bool
hover =
    Signal.mailbox False


box : (Float,Float) -> Svg
box (x,y) =
    Svg.text'
        [ Svg.Events.onMouseOver (Signal.message hover.address True)
        , Svg.Events.onMouseOut (Signal.message hover.address False)
        , Svg.Attributes.x <| toString x
        , Svg.Attributes.y <| toString y
        ]
        [ Svg.text "drag me around" ]


moveBy : (Int,Int) -> (Float,Float) -> (Float,Float)
moveBy ( dx, dy ) ( x, y ) =
    ( x + toFloat dx, y + toFloat dy )


update : Maybe Action -> (Float,Float) -> (Float,Float)
update m =
    case m of
        Just (MoveBy ( dx, dy )) ->
            moveBy ( dx, dy )

        _ ->
            identity


main : Signal Html
main =
    Signal.map
        (\p -> Svg.svg
                [ Svg.Attributes.height "200"
                , Svg.Attributes.width "200"
                , Svg.Attributes.viewBox "0 0 200 200"
                ]
                [ box p ]
        )
        (foldp update ( 100, 100 ) (track False hover.signal))