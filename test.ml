open OUnit2
open Dogma
open Game
open State
open Player
open Dogma
open Command
open Printf
open Frontend
open Yojson.Basic.Util

let innov = Yojson.Basic.from_file "innov.json"
let test = Yojson.Basic.from_file "test.json"
let test1 = Yojson.Basic.from_file "test1.json"

let get_all_cards json = Game.all_cards json 1
let init_state json = State.init_state (get_all_cards json)
let player0 json = State.get_player (init_state json) 0
let player1 json = State.get_player (init_state json) 1
let player2 json = State.get_player (init_state json) 2
let player3 json = State.get_player (init_state json) 3

let make_init_state_test 
    (name : string) 
    (test_name: Yojson.Basic.t) 
    (expected_output : int) : test = 
  name >:: (fun _ -> 
      assert_equal expected_output 
        ((get_all_cards test_name)|>State.init_state|>get_current_player))

let make_player_test 
    (name : string) 
    (test_name: Yojson.Basic.t) 
    (player_num: int) 
    (expected_output : int) : test = 
  name >:: (fun _ -> 
      assert_equal expected_output 
        ((State.get_player 
            ((get_all_cards test_name)|>State.init_state) player_num)
         |> Player.get_id)
    )

let old_state_draw = (get_all_cards test)|>State.init_state
let new_state_draw = 
  State.draw old_state_draw 
    (old_state_draw|>current_player) 0

let new_state_draw_two = 
  (* print_int(let x = State.draw new_state_draw 
                (new_state_draw|>current_player) 0 in get_hand_size_by_id x 0); *)
  State.draw new_state_draw 
    (new_state_draw|>current_player) 0

let make_before_draw_test 
    (name : string) 
    (state: State.t)
    (expected_output : string) : test = 
  name >:: (fun _ -> 
      let str = (Player.print_hand (state|>current_player)) in 
      (* Printf.printf "%s/n" str; *)
      assert_equal expected_output str
    )


let make_after_draw_test 
    (name : string) 
    (state: State.t)
    (expected_output : string) : test = 
  name >:: (fun _ -> 
      let card = (Player.get_ith_hand (state|>current_player) 0) in 
      (* Printf.printf "%s/n" str; *)
      assert_equal expected_output (card|>Card.get_title)
    )

let old_state_meld = 
  new_state_draw 

let new_state_meld = State.meld old_state_meld 
    (old_state_meld|>current_player) 0

(* let make_before_meld_test 
    (name : string) 
    (state: State.t)
    (expected_output : string) : test = 
   name >:: (fun _ -> 
      let str = (Player.print_board (state|>current_player)) in 
      Printf.printf "%s/n" str;
      assert_equal expected_output str
    ) *)

let make_after_meld_test 
    (name : string) 
    (state: State.t)
    (expected_output : string) : test = 
  name >:: (fun _ -> 
      (* let card = (Player.get_ith_stack (state|>current_player) 0) in  *)
      (* Printf.printf "%s/n" str; *)
      let card_name = Player.get_top_card_name 
          (new_state_meld|>State.current_player) 0 in
      assert_equal expected_output card_name
    )

(* let new_state_dogma = 
   let stack = Player.get_ith_stack (new_state_meld|>current_player) 0 in
   let card = Player.get_top_card stack in
   Main.execute_dogmas new_state_meld (card|>Card.get_dogma) *)

(* let make_after_dogma_test
    (name : string) 
    (state: State.t)
    (expected_output : string) : test = 
   name >:: (fun _ -> 
      (* let card = (Player.get_ith_stack (state|>current_player) 0) in  *)
      (* Printf.printf "%s/n" str; *)
      let card = Player.get_ith_hand (state|>current_player) 0 in
      assert_equal expected_output (card|>Card.get_title)
    ) *)

let make_transfer_test
    (name : string)
    (state : State.t)
    (myself : Player.t)
    (other : Player.t)
    (card_pile1: Dogma.card_pile) 
    (card_pile2: Dogma.card_pile) 
    (idx: int) 
    (top: bool)
    (expected_output : State.t) : test = 
  name >:: (fun _ -> 
      let state_after_transfer = 
        State.transfer state myself other card_pile1 card_pile2 idx top in
      assert_equal expected_output (state_after_transfer)
    )

(** hand to hand start *)
let init_state_hh = init_state test1
let init_player0_hh = player0 test1
let input_state_hh = State.draw init_state_hh init_player0_hh 0
let myself_hh = State.get_player input_state_hh 0
let other_hh = State.get_player input_state_hh 1
let card_pile1_hh = Dogma.Self_hand 0
let card_pile2_hh = Dogma.Other_hand 1
let idx_hh = 0
let top_hh = false
let expected_output_hh = State.draw init_state_hh other_hh 0
(** hand to hand end*)

(** hand to board start *)
let init_state_hb = init_state test1
let init_player0_hb = player0 test1
let input_state_hb = State.draw init_state_hb init_player0_hb 0
let myself_hb = State.get_player input_state_hb 0
let other_hb = State.get_player input_state_hb 1
let card_pile1_hb = Dogma.Self_hand 0
let card_pile2_hb = Dogma.Other_stack Red
let idx_hb = 0
let top_hb = true
let middle_state = State.draw init_state_hb other_hb 0
let player1_for_output = State.get_player middle_state 1
let expected_output_hb = State.meld middle_state player1_for_output 0
(** hand to board end*)

(** board to hand start *)
(* let init_state_bh = init_state test1
   let init_player0_bh = player0 test1
   let init_player1_bh = player1 test1
   let middle_state = State.draw init_state_bh init_player0_bh 0
   let input_state_bh = State.meld middle_state init_player0_bh 0

   let myself_bh = State.get_player input_state_bh 0
   let other_bh = State.get_player input_state_bh 1
   let card_pile1_bh = Dogma.Self_stack Red
   let card_pile2_bh = Dogma.Other_hand 0
   let idx_bh = 0
   let top_bh = false

   let expected_output_bh = State.draw init_state_bh init_player1_bh 0 *)
(** board to hand end*)

(** hand to board start *)
(* let init_state_hb = init_state test1
   let init_player0_hb = player0 test1
   let input_state_hb = State.draw init_state_hb init_player0_hb 0
   let myself_hb = State.get_player input_state_hb 0
   let other_hb = State.get_player input_state_hb 1
   let card_pile1_hb = Dogma.Self_hand 0
   let card_pile2_hb = Dogma.Other_stack Red
   let idx_hb = 0
   let top_hb = true
   let middle_state = State.draw init_state_hb other_hb 0
   let player1_for_output = State.get_player middle_state 1
   let expected_output_hb = State.meld middle_state player1_for_output 0 *)
(** hand to board end*)

let make_return_test
    (name: string)
    (state: State.t) 
    (player: Player.t) 
    (hand_idx: int)
    (expected_output : State.t) : test = 
  name >:: (fun _ -> 
      let state_after_return = State.return state player hand_idx in
      assert_equal expected_output (state_after_return)
    )

(** return one start *)
let init_state_ro = init_state test1
let init_player0_ro = player0 test1
let input_state_ro = State.draw init_state_ro init_player0_ro 0
let player_ro = State.get_player input_state_ro 0
let hand_idx_ro = 0
let expected_output_ro = init_state_ro
(** end *)

let make_score_test
    (name: string)
    (st: State.t)
    (hand_index: int)
    (expected_output: int) : test = 
  name >:: (fun _ ->
      let new_state = State.score st (st |> State.current_player) 
          hand_index in
      assert_equal expected_output 
        (State.get_score_by_id (new_state) 0)
    )


let test_tests = 
  [
    make_init_state_test "start player" test 0;

    make_player_test "player1" test 1 1;

    make_before_draw_test "before draw card" old_state_draw "";

    make_after_draw_test "after draw card" new_state_draw "Archery";

    (* make_before_meld_test "before meld card" old_state_meld ""; *)

    make_after_meld_test "after meld card" old_state_meld "Archery";

    (* make_after_dogma_test "after dogma" new_state_dogma "Masonry"; *)

    make_transfer_test "hand to hand" input_state_hh myself_hh other_hh card_pile1_hh card_pile2_hh idx_hh top_hh expected_output_hh; 

    make_transfer_test "hand to board" input_state_hb myself_hb other_hb card_pile1_hb card_pile2_hb idx_hb top_hb expected_output_hb;

    (* make_return_test "return one" input_state_ro player_ro hand_idx_ro expected_output_ro; *)

    make_score_test "score" new_state_draw 0 1;
  ]

let suite = 
  "test suite for final project"  >::: List.flatten [
    test_tests;
  ]


let _ = run_test_tt_main suite