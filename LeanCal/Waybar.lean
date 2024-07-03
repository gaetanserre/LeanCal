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

/-- Recover all today's events and format the output for Waybar. -/
def get_waybar_events (fevents fpast_events : String) := do
  read_lines fevents >>=
    fun el ↦ read_lines fpast_events >>= fun past_el ↦ do
      let events := el.map construct_event ++ past_el.map construct_event
      let io_today ← get_day
      let today := construct_date io_today
      let rec aux (el acc : List Event) :=
        match el with
          | [] => acc
          | e::tl =>
            aux tl (if e.date == today then e::acc else acc)
      let today_events := aux events []
      pure (
        "{"
        ++ s!"\"text\": \"{today_events.length}\","
        ++ "\"tooltip\": \""
        ++ "🗓️ <b>Today\\n</b>"
        ++ (format_events today_events) ++ "\"}"
      )
