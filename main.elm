module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Random
import Basics
import Bootstrap.CDN as CDN
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Bootstrap.Form.Input as Input
import Bootstrap.Button as Button


main =
    Html.program
        { init = init, view = mainContent, update = update, subscriptions = subscriptions }



-- MODEL


type alias Model =
    { minNumber : Int
    , maxNumber : Int
    , randomNumber : Int
    , guessNumber : Int
    , page : Page
    , numberOfGames : Int
    }


type Page
    = GameSetup
    | GameInProgress
    | GameOver


init : ( Model, Cmd Msg )
init =
    Model 1 10 0 1 GameSetup 1 ! []



-- UPDATE


type Msg
    = RandomNumber Int
    | Play
    | GoLower
    | GoHigher
    | NewGame
    | MinNumber String
    | MaxNumber String
    | Correct


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        RandomNumber number ->
            { model | randomNumber = number } ! []

        Play ->
            ( { model | page = GameInProgress }, generateRandomNumberBetween model.minNumber model.maxNumber )

        GoLower ->
            endGame model True

        GoHigher ->
            endGame model False

        NewGame ->
            let
                gameCount =
                    model.numberOfGames + 1
            in
                ({ model
                    | page = GameSetup
                    , minNumber = 1
                    , maxNumber = 10 * gameCount
                    , guessNumber = 1
                    , numberOfGames = gameCount
                 }
                )
                    ! []

        MinNumber number ->
            { model | minNumber = String.toInt number |> Result.withDefault 1 } ! []

        MaxNumber number ->
            { model | maxNumber = String.toInt number |> Result.withDefault 10 } ! []

        Correct ->
            { model | page = GameOver } ! []


generateRandomNumberBetween : Int -> Int -> Cmd Msg
generateRandomNumberBetween min max =
    Random.generate RandomNumber <| Random.int min max


endGame : Model -> Bool -> ( Model, Cmd Msg )
endGame model lower =
    let
        minNumber =
            if not lower then
                Basics.min model.maxNumber <| model.randomNumber + 1
            else
                model.minNumber

        maxNumber =
            if lower then
                Basics.max model.minNumber <| model.randomNumber - 1
            else
                model.maxNumber

        page =
            if minNumber == maxNumber then
                GameOver
            else
                GameInProgress

        guessNumber =
            model.guessNumber + 1
    in
        ( { model
            | minNumber = minNumber
            , maxNumber = maxNumber
            , guessNumber = guessNumber
            , page = page
          }
        , generateRandomNumberBetween minNumber maxNumber
        )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


rowStyle : Attribute Msg
rowStyle =
    style [ ( "margin", "20px 0" ) ]


buttonPadding : Attribute Msg
buttonPadding =
    style [ ( "margin", "5px" ) ]


view : Model -> Html Msg
view model =
    div [] [ mainContent model ]


mainContent : Model -> Html Msg
mainContent model =
    Grid.container
        [ style
            [ ( "text-align", "center" ) ]
        ]
        [ CDN.stylesheet
        , case model.page of
            GameSetup ->
                setupView model

            GameInProgress ->
                gameView model

            GameOver ->
                gameOverView model
        ]


setupView : Model -> Html Msg
setupView model =
    Grid.container []
        [ Grid.row [ Row.attrs [ rowStyle ] ]
            [ Grid.col [] [ h3 [] [ text "Think of a number between" ] ] ]
        , Grid.row [ Row.attrs [ style [ ( "justify-content", "center" ) ], rowStyle ] ]
            [ Grid.col [ Col.xs1 ]
                [ Input.text
                    [ Input.attrs [ value <| toString <| model.minNumber, onInput MinNumber ] ]
                ]
            , Grid.col [ Col.xs1 ]
                [ h3 []
                    [ text
                        " and "
                    ]
                ]
            , Grid.col [ Col.xs1 ]
                [ Input.text
                    [ Input.attrs [ value <| toString <| model.maxNumber, onInput MaxNumber ] ]
                ]
            ]
        , Grid.row
            [ Row.attrs [ rowStyle ] ]
            [ Grid.col []
                [ Button.button
                    [ Button.outlineSuccess
                    , Button.attrs [ onClick Play ]
                    ]
                    [ text "Start game!" ]
                ]
            ]
        ]


gameView : Model -> Html Msg
gameView model =
    Grid.container []
        [ Grid.row [ Row.attrs [ rowStyle ] ]
            [ Grid.col []
                [ h3 [] [ text "It is number" ] ]
            ]
        , Grid.row
            [ Row.attrs [ rowStyle ] ]
            [ Grid.col []
                [ h1 [] [ text <| toString model.randomNumber ++ "?" ]
                ]
            ]
        , Grid.row
            [ Row.attrs [ rowStyle ] ]
            [ Grid.col []
                [ Button.button
                    [ Button.outlineWarning
                    , Button.attrs [ buttonPadding, onClick GoLower ]
                    ]
                    [ text "Go lower" ]
                , Button.button
                    [ Button.outlineSuccess
                    , Button.attrs [ buttonPadding, onClick Correct ]
                    ]
                    [ text "Correct!" ]
                , Button.button
                    [ Button.outlinePrimary
                    , Button.attrs [ buttonPadding, onClick GoHigher ]
                    ]
                    [ text "Go higher" ]
                ]
            ]
        ]


gameOverView : Model -> Html Msg
gameOverView model =
    Grid.container []
        [ Grid.row [ Row.attrs [ rowStyle ] ]
            [ Grid.col []
                [ h3 [] [ text "Good game!" ] ]
            ]
        , Grid.row [ Row.attrs [ rowStyle ] ]
            [ Grid.col []
                [ text <| "Guessed it after " ++ toString model.guessNumber ++ " turns" ]
            ]
        , Grid.row [ Row.attrs [ rowStyle ] ]
            [ Grid.col []
                [ Button.button
                    [ Button.outlineSuccess
                    , Button.attrs [ onClick NewGame ]
                    ]
                    [ text "Increase difficulty" ]
                ]
            ]
        ]
