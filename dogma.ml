
(** [splay_direction] is the direction of splaying of a stack on board. *)
type splay_direction = No | Up | Left | Right

(** [stack_color] is the color of cards and stacks in the game. *)
type stack_color = Red | Purple | Blue | Green | Yellow

(** [card_pile] is type of cards pile in the game. *)
type card_pile = 
  | Self_hand of int 
  | Other_hand of int 
  | Self_stack of stack_color 
  | Other_stack of stack_color
  | Self_score of int 
  | Other_score of int (*dont use this int*)

(** [effect] is the dogma effects in the game. *)
type effect = 
  | Draw of int
  | Meld of int 
  | Tuck of int
  | Splay of splay_direction * stack_color
  | Return of int
  | Score of int
  | Transfer of card_pile * card_pile * int
  | Demand of effect list

(** [t] is the dogma representation. *)
type t = effect list

(** [map_effect_string] is the string representing the effects. *)
let map_effect_string = function
  | Draw _ -> "Draw"
  | Meld _ -> " Meld"
  | Tuck _ -> "Tuck"
  | Splay _ -> "Splay"
  | Return _ -> "Return"
  | Score _ -> "Score"
  | Transfer _ -> "Transfer"
  | Demand _ -> "Demand"

(** [print_effects] prints out the effect list. *)
let rec print_effects = function
  | x::xs -> Printf.printf "%s" (map_effect_string x); print_effects xs
  | [] -> ()