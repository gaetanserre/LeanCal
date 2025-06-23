/-
 - Created in 2024 by Gaëtan Serré
 -/

import LeanCal.Calendar

/-- Get the current day using `date` syscall. -/
def get_day : IO String :=
  let format_date (s : String) :=
    pure (s.replace "\n" "")
  sys_call "date" #["+%y-%m-%d"] >>= format_date

/-- Get date from syscall. -/
def get_day_and_hour : IO String :=
  let format_date (s : String) :=
    pure (s.replace "\n" "")
  sys_call "date" #["+%d/%m-%H:%M"] >>= format_date

def format_events (clock_symbol : String) (el : List Event) : String :=
  match el with
    | [] => ""
    | [e] =>
      s!"{clock_symbol} <b>{e.hour}</b> : {e.event}"
    | e::tl =>
      s!"{clock_symbol} <b>{e.hour}</b> : {e.event}\\n" ++ format_events clock_symbol tl

/-- Get all events of a specific date. -/
def get_date_events (d : Date) (el : List Event) : List Event :=
  let rec aux (el acc : List Event) :=
    match el with
      | [] => acc
      | e::tl =>
        aux tl (if e.date == d then e::acc else acc)
  aux el []

def display_text (n_events : Nat) (calendar_symbol clock_symbol day_hour : String) : String :=
  let day_hour := day_hour.splitOn "-"
  let text := s!"{clock_symbol} {day_hour[1]!}   {calendar_symbol} {day_hour[0]!}"
  if n_events == 0 then text
  else text ++ s!" ({n_events})"

def display_events (today_events tomorrow_events : List Event)
    (calendar_symbol clock_symbol day_hour : String) (complex_text : Bool) : String :=
  let tooltip :=
    -- Display today's events if any.
    (if 0 < today_events.length then
      s!"{calendar_symbol} <b>Today</b>\\n" ++ (format_events clock_symbol today_events)
    else "")
    ++
    -- Display tomorrow's events if any. Newlines if today's events nonempty.
    (if 0 < tomorrow_events.length then
      (if 0 < today_events.length then "\\n\\n" else "")
      ++ s!"{calendar_symbol} <b>Tomorrow</b>\\n" ++ (format_events clock_symbol tomorrow_events)
    else "")

  "{\"text\":"
  ++ (if complex_text then
        s!"\"{display_text today_events.length calendar_symbol clock_symbol day_hour}\","
      else s!"\"{today_events.length}\",")
  ++ "\"tooltip\": \""
  ++ tooltip
  ++ "\"}"

/-- Recover all today's events and format the output for Waybar. -/
def get_waybar_events (calendar_symbol clock_symbol fevents fpast_events : String)
    (complex_text : Bool := false) : IO String := do
  read_lines fevents >>=
    fun el ↦ read_lines fpast_events >>= fun past_el ↦ do
      let events := el.map construct_event ++ past_el.map construct_event
      let io_today ← get_day
      let today := construct_date io_today
      let today_events := get_date_events today events
      let tomorrow_events := get_date_events (add_days today 1) events
      let day_hour ← get_day_and_hour
      pure (display_events
            today_events
            tomorrow_events
            calendar_symbol
            clock_symbol
            day_hour
            complex_text
          )
