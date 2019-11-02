open Card
open Dogma

type stack = {
  color : Dogma.stack_color;
  splay : Dogma.splay_direction;
  cards : Card.t list;
}

type t = {
  id : int;
  hand : Card.t list;
  board : stack list;
  score : Card.t list;
  achievements : int list;  
}

let init_stack color = {
  color = color;
  splay = No;
  cards = [];
}

let update_stack_cards stack cards = {
  color = stack.color;
  splay = stack.splay;
  cards = cards;
}

let init_player id = {
  id = id;
  hand = [];
  board = List.map (init_stack) [Red; Purple; Blue; Green; Yellow];
  score = [];
  achievements = [];
}

let map_color_to_int = function
  | Red -> 0
  | Purple -> 1
  | Blue -> 2
  | Green -> 3
  | Yellow -> 4


let compare_player player1 player2 = 
  Stdlib.compare player1.id player2.id

let compare_stack stack1 stack2 = 
  Stdlib.compare (map_color_to_int stack1.color) (map_color_to_int stack2.color)

let update_hand hand player = {
  id = player.id;
  hand = hand;
  board = player.board;
  score = player.score;
  achievements = player.achievements;
}

let update_board board player= {
  id = player.id;
  hand = player.hand;
  board = board;
  score = player.score;
  achievements = player.achievements;
}

let get_hand player =
  player.hand

let add_hand player card = 
  update_hand (card::player.hand) player

(** Remove the [i]th element of [lst]. *)
let remove_ith_card lst i = 
  let ith = List.nth lst i in
  List.filter (fun x -> not (Card.equal x ith)) lst

let get_ith_stack player i = 
  List.nth player.board i
(* 
let rec help_check_color lst c =
  match lst with 
  | [] -> false
  | x :: t -> x.color = c || help_check_color t c *)

(* update the ith stack with [new_s] in the stack list**)
let update_stack_list s_lst i new_s = 
  let ith = List.nth s_lst i in
  let rec update' acc = function
    | [] -> failwith "ith stack not in the list"
    | x::xs -> begin match compare_stack ith x with
        | 0 -> new_s::acc @ xs
        | _ -> update' (x::acc) xs
      end in 
  update' [] s_lst |> List.sort compare_stack

let pop_card i lst = 
  match lst with
  | [] -> failwith "cannot pop element from empty list"
  | x::xs -> let ith = List.nth lst i  in
    (List.filter (fun x -> not (Card.equal x ith)) lst), ith

let pop_stack i stack = 
  let cards = stack.cards in
  match cards with
  | [] -> failwith "cannot pop element from empty list"
  | x::xs -> let ith = List.nth cards i  in
    let updated_cards, ele = (List.filter (fun x -> Card.equal x ith) cards), ith in
    (update_stack_cards stack updated_cards), ith

let add_card_to_stack card stack = {
  color = stack.color;
  splay = stack.splay;
  cards = card::stack.cards;
}

let add_stack player hand_idx = 
  let updated_hand, card_to_add = pop_card hand_idx player.hand  in
  let color = card_to_add |> Card.get_color in
  let card_c_idx = color |> map_color_to_int in
  let stack_to_update = add_card_to_stack card_to_add (List.nth player.board card_c_idx) in
  let updated_stack_list = update_stack_list player.board card_c_idx stack_to_update in
  player |> update_hand updated_hand |> update_board updated_stack_list


(*remove the top element from a stack with color [color], return the updated stack and the card removed*)
let remove_stack player color = 
  let int_of_color = color |> map_color_to_int in
  let rest, ele = int_of_color |> get_ith_stack player |> pop_stack 0 in 
  let updated_board = rest |> update_stack_list player.board int_of_color in
  (update_board updated_board player), ele

let get_score_cards player = 
  player.score

let get_score player =
  List.fold_left (fun acc ele -> Card.get_value ele) 0 player.score

let update_score player score = {
  id = player.id;
  hand = player.hand;
  board = player.board;
  score = score;
  achievements = player.achievements
}

let update_achievements player a = {
  id = player.id;
  hand = player.hand;
  board = player.board;
  score = player.score;
  achievements = a;
}


let add_score player score_card = 
  score_card::player.score |> update_score player 

let get_achievements player = 
  player.achievements

let add_achievement player era = 
  era::player.achievements |> update_achievements player




