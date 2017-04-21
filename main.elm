module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Random
import Basics


main =
    Html.program
        { init = init, view = view, update = update, subscriptions = subscriptions }



-- MODEL


type alias Model =
    { minNumber : Int
    , maxNumber : Int
    , randomNumber : Int
    , guessNumber : Int
    , lower : Bool
    , inPlay : Bool
    }


init : ( Model, Cmd Msg )
init =
    Model 1 10 0 0 False False ! []



-- UPDATE


type Msg
    = NumberSelect Int
    | Play
    | Lower
    | Higher
    | NewGame
    | MinNumber String
    | MaxNumber String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NumberSelect number ->
            { model | randomNumber = number } ! []

        Play ->
            ( { model | inPlay = True }, generateNumber model.minNumber model.maxNumber )

        Lower ->
            let
                newMaxNumber =
                    Basics.max model.minNumber <| model.randomNumber - 1
            in
                ( { model
                    | maxNumber = newMaxNumber
                    , guessNumber = incrementGuessNumber model
                  }
                , generateNumber model.minNumber newMaxNumber
                )

        Higher ->
            let
                newMinNumber =
                    Basics.min model.maxNumber <| model.randomNumber + 1
            in
                ( { model
                    | minNumber = newMinNumber
                    , guessNumber = incrementGuessNumber model
                  }
                , generateNumber newMinNumber model.maxNumber
                )

        NewGame ->
            ({ model
                | inPlay = False
                , minNumber = 1
                , maxNumber = 10
                , guessNumber = 0
             }
            )
                ! []

        MinNumber number ->
            { model | minNumber = String.toInt number |> Result.withDefault 1 } ! []

        MaxNumber number ->
            { model | maxNumber = String.toInt number |> Result.withDefault 10 } ! []


generateNumber : Int -> Int -> Cmd Msg
generateNumber min max =
    Random.generate NumberSelect <| Random.int min max


incrementGuessNumber : Model -> Int
incrementGuessNumber model =
    if model.minNumber == model.maxNumber then
        model.guessNumber
    else
        model.guessNumber + 1



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    if model.inPlay then
        view2 model
    else
        view1 model


view1 : Model -> Html Msg
view1 model =
    div []
        [ div []
            [ text "Think of a number between" ]
        , div
            []
            [ input
                [ value <| toString <| model.minNumber, onInput MinNumber ]
                []
            , text
                " and "
            , input
                [ value <| toString <| model.maxNumber, onInput MaxNumber ]
                []
            ]
        , div
            []
            [ button [ onClick Play ] [ text "Play" ] ]
        ]


view2 : Model -> Html Msg
view2 model =
    div []
        [ text "Is your number"
        , div []
            [ h1 [] [ text <| toString model.randomNumber ++ "?" ]
            , button [ onClick NewGame ] [ text "Yes" ]
            ]
        , div []
            [ text <| toString model.guessNumber ++ " guessed count" ]
        , div []
            [ button [ onClick Lower ] [ text "lower" ]
            , button [ onClick Higher ] [ text "higher" ]
            ]
        ]
