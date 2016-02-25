module Main (main) where

import Dict
import Drag exposing (..)
import Graphics.Input
import Signal exposing (foldp, merge)
-- import Text exposing (fromString)
import Graphics.Element exposing (color, down, flow, layers, leftAligned, sizeOf)
-- import Graphics.Collage exposing (collage, outlined, rect, solid, toForm)
-- import Color exposing (black, orange, yellow)
import Html exposing (Html)
import Svg exposing (Svg)
import Svg.Events
import Svg.Attributes
import Html.Events exposing (onClick)

add : Signal.Mailbox ()
add =
    Signal.mailbox ()


button : Graphics.Element.Element
button =
    Graphics.Input.button (Signal.message add.address ()) "add a draggable box"


hover : Signal.Mailbox (Maybe Int)
hover =
    Signal.mailbox Nothing


-- makeBox : Int -> Graphics.Element.Element
-- makeBox i =
--     Graphics.Input.hoverable
--         (Signal.message hover.address
--             << \h ->
--                 if h then
--                     Just i
--                 else
--                     Nothing
--         )
--         (putInBox (leftAligned (fromString (toString i))))


box : Int -> (Float,Float) -> Svg
box id (x,y) =
    Svg.text'
        [ Svg.Events.onMouseOver (Signal.message hover.address (Just id) )
        , Svg.Events.onMouseOut (Signal.message hover.address Nothing)
        , Svg.Attributes.x <| toString x
        , Svg.Attributes.y <| toString y
        ]
        [ Svg.text (toString id) ]


-- putInBox e =
--     let
--         ( sx, sy ) = sizeOf e
--     in
--         layers [ e, collage sx sy [ outlined (solid black) (rect (toFloat sx) (toFloat sy)) ] ]


moveBy : (Int, Int) -> (Float,Float) -> (Float,Float)
moveBy ( dx, dy ) ( x, y ) =
    ( x + toFloat dx, y + toFloat dy )


type Event
    = Add Int
    | Track (Maybe ( Int, Action ))


update : Event -> Dict.Dict Int (Float,Float) -> Dict.Dict Int (Float,Float)
update event =
    case event of
        Add i ->
            Dict.insert i ( ( 100, 100 ) )

        -- Track (Just ( i, Lift )) ->
        --     Dict.update i (Maybe.map (\( p, b ) -> ( p, color orange b )))

        Track (Just ( i, MoveBy ( dx, dy ) )) ->
            Dict.update i (Maybe.map (moveBy ( dx, dy ) ))

        -- Track (Just ( i, Release )) ->
        --     Dict.update i (Maybe.map (\( p, b ) -> ( p, color yellow b )))

        _ ->
            identity


main : Signal Html
main =
    Signal.map
        (\dict ->
            Html.div []
                [ Html.button
                  [ onClick add.address () ]
                  [ Html.text "foo"]
                , Svg.svg
                    [ Svg.Attributes.height "200"
                    , Svg.Attributes.width "200"
                    , Svg.Attributes.viewBox "0 0 200 200"
                    ]
                    (List.map (uncurry box) (Dict.toList dict))
                ]
        )
        (foldp
            update
            Dict.empty
            (merge
                (Signal.map Add (foldp (\_ t -> t + 1) 0 add.signal))
                (Signal.map Track (trackMany Nothing hover.signal))
            )
        )
