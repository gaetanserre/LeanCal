/-
 - Created in 2024 by Gaëtan Serré
 -/

import LeanCal.Calendar
import LeanCal.Date
import LeanCal.Waybar

def main (argv : List String) : IO Unit := do
  let LeanCal_HOME := "LeanCal_HOME"
  let fevents := s!"{LeanCal_HOME}/events.txt"
  let fpast_events := s!"{LeanCal_HOME}/past_events.txt"
  match argv with
    | [] => calendar_run fevents fpast_events
    | ["-w"] | ["--waybar"] => get_waybar_events fevents >>= IO.println
    | ["--clean"] | ["-c"] =>
      clean_events fevents fpast_events
    | _ => IO.println "Error!"
