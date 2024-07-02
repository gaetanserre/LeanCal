/-
 - Created in 2024 by Gaëtan Serré
 -/

import LeanCal.Calendar
import LeanCal.Date

def main (argv : List String) : IO Unit := do
  let d : Date := {day:=3, month:=11, year:=2024}
  IO.println s!"{d} {add_months d 18}"
  /- match argv with
    | [] => cal_run "events.txt" "past_events.txt"
    | ["--clean"] | ["-c"] => clean_events "events.txt" "past_events.txt"
    | _ => IO.println "Error!" -/

  /- let event := "02-07-2024_15-20  Envoyer mail séminaire"
  let events := (IO.FS.lines "events.txt") >>= fun l ↦ pure <| l.map construct_event
  -- IO.sleep 1000
  notify_event <| construct_event event -/
