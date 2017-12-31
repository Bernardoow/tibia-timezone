port module Main exposing (..)

import Html exposing (Html, text, div, h1, label, select, option, input, p, button, br)
import Html.Attributes exposing (class, for, id, placeholder, type_)
import Html.Events exposing (onInput, onClick, on, targetValue)
import AlertTimerMessage
import Json.Decode as Json


---- MODEL ----


type alias Model =
    { tz_list : List String
    , tz_preference : Maybe String
    , search : Maybe String
    , current_tz_selected : Maybe String
    , alert_messages : AlertTimerMessage.Model
    }


init : ( Model, Cmd Msg )
init =
    let
        model =
            Model [] Nothing Nothing Nothing AlertTimerMessage.modelInit
    in
        ( model, Cmd.batch [ get_timezones "", get_tz_preference "" ] )



---- UPDATE ----


port get_timezones : String -> Cmd msg


port get_tz_preference : String -> Cmd msg


port save_tz_preference : String -> Cmd msg


type Msg
    = SearchInput String
    | Timezones (List String)
    | TimezonePreference String
    | TimezonePreferenceReturn Bool
    | AlertTimer AlertTimerMessage.Msg
    | SaveTzPreference
    | SelectChanged String


onSelect : (String -> msg) -> Html.Attribute msg
onSelect msg =
    on "change" (Json.map msg targetValue)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SearchInput str ->
            { model | search = Just str } ! []

        Timezones list ->
            { model | tz_list = list } ! []

        TimezonePreference preference ->
            { model | tz_preference = Just preference } ! []

        TimezonePreferenceReturn return ->
            let
                newMsg =
                    AlertTimerMessage.AddNewMessage 3 <| div [] [ text "Your preference was saved with success." ]

                ( updateModal, subCmd ) =
                    AlertTimerMessage.update newMsg model.alert_messages
            in
                { model | alert_messages = updateModal, current_tz_selected = Nothing, tz_preference = model.current_tz_selected } ! [ Cmd.map AlertTimer subCmd ]

        AlertTimer msg ->
            let
                ( updateModal, subCmd ) =
                    AlertTimerMessage.update msg model.alert_messages
            in
                { model | alert_messages = updateModal } ! [ Cmd.map AlertTimer subCmd ]

        SaveTzPreference ->
            case model.current_tz_selected of
                Nothing ->
                    let
                        newMsg =
                            AlertTimerMessage.AddNewMessage 3 <| div [] [ text "Choose your timezone." ]

                        ( updateModal, subCmd ) =
                            AlertTimerMessage.update newMsg model.alert_messages
                    in
                        { model | alert_messages = updateModal } ! [ Cmd.map AlertTimer subCmd ]

                Just preference ->
                    model ! [ save_tz_preference preference ]

        SelectChanged selected ->
            { model | current_tz_selected = Just selected } ! []



-- SUBSCRIPTIONS


port timezones : (List String -> msg) -> Sub msg


port timezone_preference : (String -> msg) -> Sub msg


port save_tz_preference_return : (Bool -> msg) -> Sub msg


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ timezones Timezones
        , timezone_preference TimezonePreference
        , save_tz_preference_return TimezonePreferenceReturn
        ]



---- VIEW ----


view : Model -> Html Msg
view model =
    let
        mount_options : List String -> List (Html Msg)
        mount_options list =
            List.map (\item -> option [] [ text item ]) list

        options =
            case model.search of
                Nothing ->
                    mount_options model.tz_list

                Just search ->
                    List.filter (\item -> String.toLower item |> String.contains search) model.tz_list
                        |> mount_options
    in
        div []
            [ h1 [] [ text "Tibia Timezone" ]
            , Html.map AlertTimer (AlertTimerMessage.view model.alert_messages)
            , case model.tz_preference of
                Nothing ->
                    p [] []

                Just preference ->
                    let
                        msg =
                            "Your preference: " ++ preference
                    in
                        p [] [ text msg ]
            , div []
                [ div [ class "form-group" ]
                    [ label [ for "searchField" ]
                        [ text "Timezone" ]
                    , input [ onInput SearchInput, class "form-control", id "searchField", placeholder "Search for you timezone.", type_ "text" ]
                        []
                    ]
                , div [ class "form-group" ] [ select [ class "form-control", onSelect SelectChanged ] options ]
                , button [ class "btn btn-primary btn-block", onClick SaveTzPreference ] [ text "Save preference" ]
                , p [ class "center-block" ] [ text "Almost all images on this site are from the game Tibia." ]
                , p [ class "center-block" ] [ text "Please note that the only official website is Tibia.com." ]
                , p [ class "center-block" ] [ text "The game Tibia and the website Tibia.com are copyrighted by CipSoft GmbH." ]
                ]
            ]



---- PROGRAM ----


main : Program Never Model Msg
main =
    Html.program
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }
