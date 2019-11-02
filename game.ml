open Yojson.Basic.Util
open Card
open Dogma

let json_to_dogmas (json : Yojson.Basic.t) : Dogma.t list = 
  let eff1_lst = json |> member "dogmas" |> member "effect1" |> to_list |> List.map to_string in
  let eff2_lst = json |> member "dogmas" |> member "effect2" |> to_list |> List.map to_string in 
  let matching st = 
    match st |> String.split_on_char ' ' with 
    | eff :: content :: [] -> match eff with
      | "Draw" -> Dogma.Draw (int_of_string content)
      | "Meld" -> Dogma.Meld (int_of_string content)
      | "Tuck" -> Dogma.Tuck (int_of_string content)
      | "Return" -> Dogma.Return (int_of_string content)
      | "Score" -> Dogma.Score (int_of_string content)
      | "Splay" -> 
        let dir = match content with
          | "Up" -> Dogma.Up
          | "Left" -> Dogma.Left
          | "Right" -> Dogma.Right in Dogma.Splay dir
      | "Tranfer" -> 


        (        let helper1 str = 
                   match str with 
                   | "Red" -> Dogma.Red
                   | "Purple" -> Dogma.Purple
                   | "Blue" -> Dogma.Blue
                   | "Green" -> Dogma.Green
                   | "Yellow" -> Dogma.Yellow 
                   | i -> int_of_string i in
                 m_json (json : Yojson.Basic.t) : Card.t = 

                                                  | pile :: x :: [] -> match pile with 
                 | "SelfHand" -> Dogma.SelfHand (helper1 x)
                 | "OthersHand" -> Dogma.OthersHand (helper1 x)
                 | "SelfStack" -> Dogma.SelfStack (helper1 x)
                 | "OthersStack" -> Dogma.OthersStack (helper1 x) in
  piles |> List.map helper2)