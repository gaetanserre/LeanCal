/-
 - Created in 2024 by Gaëtan Serré
 -/

import LeanCal.Event

def get_date : IO String :=
  let format_date (s : String) :=
    pure (s.replace "\n" "")
  sys_call "date" #["+%y-%m-%d%H-%M"] >>= format_date

def compare_dates (d1 d2 : String) : Bool :=
  let i_d1 := (d1.replace "-" "").toNat!
  let i_d2 := (d2.replace "-" "").toNat!
  i_d1 ≤ i_d2

def check_if_past (e : Event) (past_events : List Event) : Bool :=
  match past_events with
    | [] => false
    | he::tl =>
      if e == he then true
      else check_if_past e tl

def notify_event (e : Event) (past_events : List Event) : IO Bool :=
  let d_event := toString e.date ++ e.hour
  get_date >>= fun d2 ↦
    if compare_dates d_event d2 ∧ ¬(check_if_past e past_events) then
      send_notification s!"{e.hour.replace "-" ":"} : {e.event}"
    else pure false

def notify_events (events past_events : List Event) := do
  let rec notify_each_event (el past_el notified_el : List Event) : IO (List Event) := do
    match el with
      | [] => pure notified_el
      | e::tl =>
        notify_event e past_el >>= fun b ↦
          if b then notify_each_event tl past_el (e::notified_el)
          else notify_each_event tl past_el notified_el
  notify_each_event events past_events []

def create_new_recurrent_events (events : List Event) : List Event :=
  let rec aux (l acc : List Event) :=
    match l with
      | [] => acc
      | e :: tl =>
        match e.recu with
          | Time.None => aux tl acc
          | Time.Day n =>
            aux tl
              <| ({event:=e.event, hour:=e.hour, recu:=e.recu, date := add_days e.date n} :: acc)
          | Time.Month n =>
            aux tl
              <| ({event:=e.event, hour:=e.hour, recu:=e.recu, date := add_months e.date n} :: acc)
          | Time.Year n =>
            aux tl ({
                event:=e.event,
                hour:=e.hour,
                recu:=e.recu,
                date := {day:=e.date.day, month:=e.date.month, year:=e.date.year + n}
              } :: acc)
  aux events []

def cal_run (fevents fpast_events : String) := do
  while true do
    read_lines fevents >>= fun el ↦
      read_lines fpast_events >>= fun past_el ↦
        let events := (el.map construct_event)
        let past_events := (past_el.map construct_event)
        notify_events events past_events >>= fun notified_el ↦
          let new_recu_events := create_new_recurrent_events notified_el
          (if 1 <= notified_el.length then do
            IO.FS.writeFile fpast_events
              <| (past_events ++ notified_el).foldr (fun e acc ↦ (toString e) ++ "\n" ++ acc) ""
            IO.FS.writeFile fevents
              <| ((events.diff notified_el) ++ new_recu_events).foldr
                 (fun e acc ↦ (toString e) ++ "\n" ++ acc) ""
          else pure ());
          IO.sleep 1000

def clean_events (fpast_events events : String) : IO Unit := do
  IO.FS.writeFile events "";
  IO.FS.writeFile fpast_events ""
