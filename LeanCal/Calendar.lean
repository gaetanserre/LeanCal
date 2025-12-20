/-
 - Created in 2024 by Gaëtan Serré
 -/

import LeanCal.Event

/-- Get date from syscall. -/
def get_date : IO String :=
  let format_date (s : String) :=
    pure (s.replace "\n" "")
  sys_call "date" #["+%y-%m-%d%H:%M"] >>= format_date

def compare_dates (d₁ d₂ : String) : Bool :=
  let i_d₁ := ((d₁.replace "-" "").replace ":" "").toNat!
  let i_d₂ := ((d₂.replace "-" "").replace ":" "").toNat!
  i_d₁ ≤ i_d₂

/-- Send a notification for Event `e` if `e` ∉ `past_events`. -/
def notify_event (e : Event) (past_events : List Event) : IO Bool :=
  match e.hour with
    | Hour.AllDay => get_date >>= fun d₂ ↦ pure <|
      compare_dates (toString e.date ++ "00:00") d₂ ∧ ¬(past_events.contains e)
    | Hour.Specific _ =>
      let d_event := toString e.date ++ e.format_hour_minute
      get_date >>= fun d₂ ↦
        if compare_dates d_event d₂ ∧ ¬(past_events.contains e) then
          send_notification s!"{e.format_minute} - {e.event}"
        else pure false

/-- Send a notification for each due event and returns the list of such events. -/
def notify_events (events past_events : List Event) : IO (List Event) := do
  let rec notify_each_event (el past_el notified_el : List Event) : IO (List Event) := do
    match el with
      | [] => pure notified_el
      | e::tl =>
        notify_event e past_el >>= fun b ↦
          if b then notify_each_event tl past_el (e::notified_el)
          else notify_each_event tl past_el notified_el
  notify_each_event events past_events []

/-- For each due recurrent events, create the next one. -/
def create_new_recurrent_events (events : List Event) : List Event :=
  let rec aux (l acc : List Event) :=
    match l with
      | [] => acc
      | e :: tl =>
        match e.recu with
          | Time.None => aux tl acc
          | Time.Day n =>
            aux tl
              <| ({event:=e.event, hour:=e.hour, recu:=e.recu, date := e.date.add_days n} :: acc)
          | Time.Month n =>
            aux tl
              <| ({event:=e.event, hour:=e.hour, recu:=e.recu, date := e.date.add_months n} :: acc)
          | Time.Year n =>
            aux tl ({
                event:=e.event,
                hour:=e.hour,
                recu:=e.recu,
                date := {day:=e.date.day, month:=e.date.month, year:=e.date.year + n}
              } :: acc)
  aux events []

/--
  Main loop.
  1. Read recorded events and past events
  2. Notify due events
  3. Create new recurrent events
  4. Update files
  5. Sleep
  6. Step 1
-/
def calendar_run (fevents fpast_events : String) := do
  while true do
    read_lines fevents >>= fun el ↦
      read_lines fpast_events >>= fun past_el ↦
        let events := (el.map Event.construct_event)
        let past_events := (past_el.map Event.construct_event)
        notify_events events past_events >>= fun due_events ↦
          let new_recu_events := create_new_recurrent_events due_events
          (if 1 <= due_events.length then do
            IO.FS.writeFile fpast_events
              <| (past_events ++ due_events).foldr (fun e acc ↦ (toString e) ++ "\n" ++ acc) ""
            IO.FS.writeFile fevents
              <| ((events.diff due_events) ++ new_recu_events).foldr
                 (fun e acc ↦ (toString e) ++ "\n" ++ acc) ""
          else pure ());
          IO.sleep 60000

def clean_events (fpast_events events : String) : IO Unit := do
  IO.FS.writeFile events "";
  IO.FS.writeFile fpast_events ""
