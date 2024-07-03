/-
 - Created in 2024 by Gaëtan Serré
 -/

import LeanCal.Calendar
import LeanCal.Date

def main (argv : List String) : IO Unit := do
  match argv with
    | [] => calendar_run "LeanCal_HOME/events.txt" "LeanCal_HOME/past_events.txt"
    | ["--clean"] | ["-c"] =>
      clean_events "LeanCal_HOME/events.txt" "LeanCal_HOME/past_events.txt"
    | _ => IO.println "Error!"
