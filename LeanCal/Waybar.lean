/-
 - Created in 2024 by Gaëtan Serré
 -/

import LeanCal.Calendar

/-- Get the current day using `date` syscall. -/
def get_day : IO String :=
  let format_date (s : String) :=
    pure (s.replace "\n" "")
  sys_call "date" #["+%y-%m-%d"] >>= format_date

def format_events (el : List Event) : String :=
  match el with
    | [] => ""
    | [e] =>
      s!"🕛 <b>{e.hour}</b> : {e.event}"
    | e::tl =>
      s!"🕛 <b>{e.hour}</b> : {e.event}\\n" ++ format_events tl

/-- Get all events of a specific date. -/
def get_date_events (d : Date) (el : List Event) : List Event :=
  let rec aux (el acc : List Event) :=
    match el with
      | [] => acc
      | e::tl =>
        aux tl (if e.date == d then e::acc else acc)
  aux el []

/-- Recover all today's events and format the output for Waybar. -/
def get_waybar_events (fevents fpast_events : String) := do
  read_lines fevents >>=
    fun el ↦ read_lines fpast_events >>= fun past_el ↦ do
      let events := el.map construct_event ++ past_el.map construct_event
      let io_today ← get_day
      let today := construct_date io_today
      let today_events := get_date_events today events
      let tomorrow_events := get_date_events (add_days today 1) events

      let tooltip :=
        -- Display today's events if any.
        (if 0 < today_events.length then
          "🗓️ <b>Today</b>\\n" ++ (format_events today_events)
        else "")
        ++
        -- Display tomorrow's events if any. Newlines if today's events nonempty.
        (if 0 < tomorrow_events.length then
          (if 0 < today_events.length then "\\n\\n" else "")
          ++ "🗓️ <b>Tomorrow</b>\\n" ++ (format_events tomorrow_events)
        else "")

      pure (
        "{" ++ s!"\"text\": \"{today_events.length}\","
        ++ "\"tooltip\": \""
        ++ tooltip
        ++ "\"}"
      )
