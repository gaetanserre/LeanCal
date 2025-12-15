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

structure Event where
  date : Date
  hour : Nat × Nat
  event : String
  recu : Time

namespace Event

def format_minute (e : Event) : String :=
  if e.hour.2 < 10 then
    s!"{e.hour.1}:0{e.hour.2}"
  else
    s!"{e.hour.1}:{e.hour.2}"

def format_hour_minute (e : Event) : String :=
  if e.hour.1 < 10 then
    if e.hour.2 < 10 then
      s!"0{e.hour.1}:0{e.hour.2}"
    else
      s!"0{e.hour.1}:{e.hour.2}"
  else
    if e.hour.2 < 10 then
      s!"{e.hour.1}:0{e.hour.2}"
    else
      s!"{e.hour.1}:{e.hour.2}"

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
  let hour := (day_hour[1]!).splitOn ":"
  let recu :=
    if date_event_recu.length == 3 then
      construct_time (date_event_recu[2]!)
    else None
  ⟨construct_date (day_hour[0]!),
  ((hour[0]!).toNat!, (hour[1]!).toNat!),
  date_event_recu[1]!,
  recu⟩

def toNat (e : Event) : Nat :=
  let d_nat := e.date.toNat
  d_nat * 10000 + e.hour.1 * 100 + e.hour.2

instance : LE Event where
  le e₁ e₂ := e₁.toNat ≤ e₂.toNat

instance : DecidableLE Event := by
  intro a b
  simp only [instLE]
  infer_instance

end Event
