/-
 - Created in 2024 by Gaëtan Serré
 -/

import LeanCal.Calendar
import LeanCal.Date
import LeanCal.Waybar

def print_list {α : Type} [ToString α] (l : List α) := do
  match l with
    | [] => pure ()
    | hd :: tl =>
      IO.println hd
      print_list tl

def get_symbol (l : List String) (id : String) (default_sym : String) : String :=
  match l with
    | [] => default_sym
    | _ :: [] => default_sym
    | hd :: (hdd :: tl) =>
      if hd == id then hdd
      else get_symbol tl id default_sym

def main (argv : List String) : IO Unit := do
  let LeanCal_home := "/home/gserre/.LeanCal"
  let fevents := s!"{LeanCal_home}/events.txt"
  let fpast_events := s!"{LeanCal_home}/past_events.txt"

  if argv.isEmpty then
    calendar_run fevents fpast_events
  else if argv.contains "-w" || argv.contains "--waybar" then
    let calendar_symbol := get_symbol argv "--cal_sym" "🗓️"
    let clock_symbol := get_symbol argv "--clock_sym" "🕛"
    if argv.contains "-co" || argv.contains "--complex_output" then
      get_waybar_events calendar_symbol clock_symbol fevents fpast_events true >>= IO.println
    else
      get_waybar_events calendar_symbol clock_symbol fevents fpast_events >>= IO.println
  else if argv.contains "-c" || argv.contains "--clean" then
    clean_events fevents fpast_events
  else
    throw <| IO.userError "Unrecognized argument!"
