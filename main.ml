open Game
open State
open Player
open Dogma
open Command
open Printf
open Frontend
open Ai

let total_era = 1

(** [game_init f] is the the initial game state after the json file is loaded. *)
let game_init f =
  let json = f |> Yojson.Basic.from_file in 
  List.rev (Game.all_cards json total_era)|> State.init_state 

(** [input_number act] is the index of card a player selected to perform the 
    action [act]. *)
let input_number act = 
  print_endline 
    ("Please enter the index of the card you want to" ^ act ^ ". \n");
  print_endline ">";
  let str = read_line () in
  match Command.parse str with
  | Number int -> int
  | _ -> print_endline 
           ("This is not a number. It's automatically set to 0"); 0

(** [rec_return state] is the state after trying to return the card of a player
    from hand, and the state is the original state if return is impossible. *)
let rec rec_return state = 
  try 
    let i = input_number "" in
    State.return state (State.current_player state) i
  with _ -> rec_return state

(** [transfer_helper state id cp1 cp2] is the state after the card with index 0 of
    the current player's card pile [cp1] is transferred to the top of the [id]th 
    player's card pile [cp2]. *)
let transfer_helper state id cp1 cp2= 
  let other = State.get_player state id in
  let myself = State.current_player state in 
  State.transfer state myself other cp1 cp2 0 true

(** [dogma_effect state dogma] is the state after executing the
    effects of a dogma. If there is a choice involved, it is the
    the specific effects of the dogma will be specified by the 
    player's input. *)
let dogma_effect (state: State.t) (dogma : Dogma.effect) : State.t = 
  match dogma with
  | Draw x -> if (x<0) then let i = input_number " draw" in
      State.draw state (State.current_player state) i
    else State.draw state (State.current_player state) x 
  | Meld x -> if (x<0) then let i = input_number " meld" in
      State.meld state (State.current_player state) i
    else State.meld state (State.current_player state) x 
  | Tuck x -> if (x<0) then let i = input_number " tuck"  in
      State.tuck state (State.current_player state) i 
    else State.tuck state (State.current_player state) x
  | Return x -> if (x<0) then let i = input_number " return" in
      let temp = State.return state (State.current_player state) i in
      temp else State.return state (State.current_player state) x
  | Score x -> if (x<0) then let i = input_number " score" in
      State.score state (State.current_player state) i 
    else State.score state (State.current_player state) x 
  | Transfer (cp1, cp2, id) -> 
    transfer_helper state id cp1 cp2
  | Splay (dir,color) -> 
    State.splay state (State.current_player state) color dir
  | _ -> print_string "Need to be completed \n"; state

(** [go_through_effects state dogma] is state after executing one 
    dogma. *)
let rec go_through_effects (state: State.t) (dogma: Dogma.t) : State.t =
  match dogma with 
  | [] -> state
  | x :: t -> let new_state = dogma_effect state x in
    go_through_effects new_state t

(** [execute_dogmas state dogmas] is the state after executing the 
    dogmas of a card. *)
let execute_dogmas state dogmas = 
  match dogmas with 
  | x :: y :: [] -> let state_after_x = go_through_effects state x in 
    go_through_effects state_after_x y
  | _ -> failwith "impossible"

(** [check_win] is a tuple representing the game result. The first entry 
    of the tuple is the winning player's id, and the second entry is the 
    final score of this player. The tuple is (-1, -1) if no one wins. *)
let check_win state = 
  let cards = get_era_cards state in
  let win = List.for_all (fun lst -> List.length lst = 0) cards in
  if win then
    let rec get_max_score = function
      | p :: ps -> let (prev_id, prev_score) = get_max_score ps in
        let new_score = Player.get_score p in
        if new_score > prev_score then (Player.get_id p, new_score)
        else (prev_id, prev_score)
      | [] -> (-1, -1) in
    get_max_score (State.get_players state)
  else (-1, -1)

(** [print_help state] prints instructions of the game in the terminal. *)
let print_help state = 
  Printf.printf "    You are player %d.\n
      Now it's your turn.\n
      Here're a few possible commands you could try.\n
      🌟 draw [era_num]: draw a card from era [era_num], starting from 0.\n
      🌟 meld [hand_idx]: meld a card with index [hand_idx] from your hand cards, 
      starting from 0.\n
      🌟 board [player_idx]: display the player [player_idx]'s board cards, 
      [player_idx] ranges from 0 to 3.\n
      🌟 hand [player_idx]: display the player [player_idx]'s hand cards, 
      [player_idx] ranges from 0 to 3.\n
      🌟 score: display current player's scores.\n
      🌟 dogma [color]: use the dogma effect on stack with color [color]. 
      Colors are red, purple, blue, green, yellow.\n" 
    (State.get_current_player state)

(** [run_game_1 state] is the state after a player performs its first action
    in its round. *)
let rec run_game_1 state = 
  let (id,score) = state |> check_win in
  if (id <> -1) && (score <> -1) 
  then (print_string ("Game ends!"); Printf.printf "Player %d wins" id;
        print_string "\n"; exit 0)
  else
    print_string "> ";
  match read_line () with
  | exception End_of_file -> state
  | str -> try run_parse state str true
    with 
    | Empty_list str -> print_string (str ^ "\n"); 
      run_game_1 state
    | Malformed str -> 
      print_string str;
      run_game_1 state
    | Failure str -> print_string (str ^ "\n"); 
      run_game_1 state
    | _ -> run_game_1 state

(** [run_game_2 state] is the state after a player performs its second action
    in its round. *)
and run_game_2 state = 
  let (id,score) = state |> check_win in
  if (id <> -1) && (score <> -1) 
  then (print_string ("Game ends!"); 
        Printf.printf "Player %d wins" id;
        print_string "\n"; exit 0)
  else
    print_string "> ";
  match read_line () with
  | exception End_of_file -> state
  | str -> try run_parse state str false
    with 
    | Empty_list str -> print_string (str ^ "\n"); 
      run_game_2 state
    | Malformed str -> 
      print_string str;
      run_game_2 state
    | Failure str -> print_string (str ^ "\n"); 
      run_game_2 state

(** [run_parse staet str is_first] is the state after executing the action 
    specified by [str]. If [is_first] is true then the function runs as the
    first action, and it runs as the second action if otherwise. *)
and run_parse state str is_first = 
  let game_func = 
    if is_first then run_game_1 else run_game_2 in
  match Command.parse str with
  | exception Empty -> 
    print_string "You didn't type in any command! \n";
    game_func state
  | exception Malformed str -> 
    print_string str; game_func state
  | Meld x -> 
    State.meld state (State.current_player state) x 
  | Draw x -> 
    State.draw state (State.current_player state) x
  | Achieve _ -> 
    State.achieve state (State.current_player state) 
  | Hand -> run_hand state true
  | Board x -> run_board state x true
  | Score -> 
    let score = State.get_current_player_score state in
    printf "Score: %d\n" score;
    game_func state
  | Help -> print_help state;
    game_func state
  | Dogma col -> run_dogma state col
  | _ -> print_string "You didn't type in any command! \n";
    game_func state

(** [run_hand state is_first] prints all hand cards of the current
    player. *)
and run_hand state is_first = 
  let str = State.print_hand state in
  Frontend.display state;
  printf "Hand: %s\n" str;
  if is_first then run_game_1 state
  else run_game_2 state

(** [run_board state x is_first] prints the board of the [x]th player. *)
and run_board state x is_first = 
  let str = State.print_player_board state x in
  printf "Board of %d:\n %s" x str;
  Frontend.display state;
  if is_first then run_game_1 state
  else run_game_2 state

(** [run_score state is_first] prints the score of the current player. *)
and run_score state is_first = 
  let score = State.get_current_player_score state in
  printf "Score: %d\n" score;
  if is_first then run_game_1 state
  else run_game_2 state

(** [run_dogma state col] is the state after executing the dogmas of 
    the top card on the current player's stack with color [col]. *)
and run_dogma state col = 
  let num = Player.map_color_to_int col in
  let stack = Player.get_ith_stack (State.current_player state) 
      num in
  let card = Player.get_top_card stack in
  let dogma = Card.get_dogma card in
  execute_dogmas state dogma

(** [play_game state] plays the game in the terminal. If a winning condition 
    is matched, the the game engine will be stopped. *)
let rec play_game state =
  Frontend.display state; 
  print_string "\n\n";
  printf "It's player %d's first turn!\n" (State.get_current_player state);
  let state_after_1 = run_game_1 state in
  if state_after_1 = state then (print_string " \n"; exit 0)
  else Frontend.display state_after_1;
  let winner1 = state_after_1 |> check_win in
  if fst winner1 > 0 
  then let () = Printf.printf 
           "The game's winner is player %d and the score is %d" 
           (fst winner1) (snd winner1) in (Stdlib.exit 0)
  else print_string "\n\n"; printf "It's player %d's second turn!\n" 
    (State.get_current_player state_after_1);
  let state_after_2 = run_game_2 state_after_1 in
  if state_after_1 = state then (print_string " \n"; exit 0)
  else let winner2 = state_after_2 |> check_win in
    winner_2 winner2 state_after_2

(** [winner_2 winner state] checks the winning condition, and if the game 
    game should continue to play, it plays, or else the game engine will
    be stopped. *)
and winner_2 winner state = 
  if fst winner > 0 
  then let () = Printf.printf 
           "The game's winner is player %d and the score is %d" 
           (fst winner) (snd winner) in (Stdlib.exit 0)
  else let next_player_state = State.next_player state in
    play_game next_player_state

(** [play_game_ai state] plays the game in AI mode. The human player will first
    perform actions, followed by rounds of three ai players. If a winning 
    condition is matched, the the game engine will be stopped.*)
let rec play_game_ai state = 
  try (
    Frontend.display state;
    print_string "\n\n";
    printf "It's player %d's first turn!\n" (State.get_current_player state);
    let state_after_1 = run_game_1 state in
    Frontend.display state_after_1;
    print_string "\n\n";
    printf "It's player %d's second turn!\n" 
      (State.get_current_player state_after_1);
    let state_after_2 = run_game_2 state_after_1 in
    let next_player_state = State.next_player state_after_2 in
    let state_after_ai = (Ai.ai_play_deterministic 1 0 next_player_state) in 
    play_game_ai state_after_ai
  )
  with 
  | Win s -> print_endline(s); 
    let (id,score) = state |> check_win in
    if (id <> -1) && (score <> -1) 
    then (print_string ("Game ends!"); 
          Printf.printf "Player %d wins" id;
          print_string "\n"; exit 0)
    else (print_string ("Game ends! No one Wins! \n");)
  | Empty_list s -> print_endline(s)
  | Failure s -> print_endline(s)

let game_rule = "Game Rules:\n
    Meld: put card from your hand to your board, on top of the stack of matching color. 
    Continue a spaly if one is present.\n
    Draw: Take a card of value equal to your highest top card from the supply piels. 
    If empty, draw from the next higher pile.\n
    Dogma/take action: Pick a top card on your board, and execute each effect on it in order. 
    Effects are mandatory unless “You may” precedes them.\n"

(** [main ()] prompts for the game to play, then starts it. *)
let main () =
  ANSITerminal.(print_string [red]
                  "\n\nWelcome to the Innovation engine.\n");
  print_string "Do you want to play with AI? (y/n)";
  match read_line() with
  | "y" -> 
    ANSITerminal.(print_string [green] game_rule);
    "innov.json" |> game_init |> play_game_ai
  | "n" -> 
    ANSITerminal.(print_string [green] game_rule);
    "innov.json" |> game_init |> play_game
  | _ -> ()

let () = main ()