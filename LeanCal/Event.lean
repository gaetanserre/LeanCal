/-
 - Created in 2024 by Gaëtan Serré
 -/

import LeanCal.Utils
import LeanCal.Date

/-- Inductive type for recurrent Event. -/
inductive Time where
  | Day (n : Nat) : Time
  | Month (n : Nat) : Time
  | Year (n : Nat) : Time
  | None : Time

open Time

def construct_time (s : String) : Time :=
  if s == "" then None
  else
    let s_splitted := s.splitOn "-"
    let n := (s_splitted[0]!).toNat!
    match s_splitted[1]! with
      | "d" => Day n
      | "m" => Month n
      | "y" => Year n
      | _ => None

inductive Hour where
  | AllDay : Hour
  | Specific (h : Nat × Nat) : Hour

def Hour.fst (h : Hour) : Nat :=
  match h with
    | Hour.AllDay => 0
    | Hour.Specific hh => hh.1

def Hour.snd (h : Hour) : Nat :=
  match h with
    | Hour.AllDay => 0
    | Hour.Specific hh => hh.2

structure Event where
  date : Date
  hour : Hour
  event : String
  recu : Time

namespace Event

def format_minute (e : Event) : String :=
  match e.hour with
  | Hour.AllDay => "All Day"
  | Hour.Specific h =>
    if h.2 < 10 then
      s!"{h.1}:0{h.2}"
    else
      s!"{h.1}:{h.2}"

def format_hour_minute (e : Event) : String :=
  match e.hour with
  | Hour.AllDay => "All Day"
  | Hour.Specific h =>
    if h.1 < 10 then
      if h.2 < 10 then
        s!"0{h.1}:0{h.2}"
      else
        s!"0{h.1}:{h.2}"
    else
      if h.2 < 10 then
        s!"{h.1}:0{h.2}"
      else
        s!"{h.1}:{h.2}"

instance : ToString Event where
  toString := fun e ↦
    match e.recu with
    | None => s!"{e.date}_{e.format_minute}^{e.event}"
    | Day n =>
      s!"{e.date}_{e.format_minute}^{e.event}^{n}-d"
    | Month n =>
      s!"{e.date}_{e.format_minute}^{e.event}^{n}-m"
    | Year n =>
      s!"{e.date}_{e.format_minute}^{e.event}^{n}-y"

instance : BEq Event where
  beq := fun e1 e2 ↦ toString e1 == toString e2

/-- Construct an event given a String of form `yy-mm-dd_hh-mm^Event description^[n-{d|m|y}]` -/
def construct_event (event_str : String) : Event :=
  let date_event_recu := event_str.splitOn "^"
  let day_hour := (date_event_recu[0]!).splitOn "_"
  let recu :=
    if date_event_recu.length == 3 then
      construct_time (date_event_recu[2]!)
    else None
  let hour :=
    if day_hour[1]! == "All Day" then
      Hour.AllDay
    else
      Hour.Specific (
        (((day_hour[1]!).splitOn ":")[0]!).toNat!,
        (((day_hour[1]!).splitOn ":")[1]!).toNat!
      )

  ⟨ construct_date (day_hour[0]!),
    hour,
    date_event_recu[1]!,
    recu  ⟩

def toNat (e : Event) : Nat :=
  let d_nat := e.date.toNat
  d_nat * 10000 + e.hour.fst * 100 + e.hour.snd

instance : LE Event where
  le e₁ e₂ := e₁.toNat ≤ e₂.toNat

instance : DecidableLE Event := by
  intro a b
  simp only [instLE]
  infer_instance

end Event
