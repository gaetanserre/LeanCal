/-
 - Created in 2024 by Gaëtan Serré
 -/

import LeanCal.Calendar
import LeanCal.Date
import LeanCal.Waybar

def main (argv : List String) : IO Unit := do
  let LeanCal_home := "LeanCal_HOME"
  let fevents := s!"{LeanCal_home}/events.txt"
  let fpast_events := s!"{LeanCal_home}/past_events.txt"
  match argv with
    | [] => calendar_run fevents fpast_events
    | ["-w"] | ["--waybar"] => get_waybar_events fevents fpast_events >>= IO.println
    | ["--clean"] | ["-c"] =>
      clean_events fevents fpast_events
    | _ => IO.println "Error!"
