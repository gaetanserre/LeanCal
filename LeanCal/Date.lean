/-
 - Created in 2024 by Gaëtan Serré
 -/

import Init.Data.Order.ClassesExtra

structure Date where
  day : Nat
  month : Nat
  year : Nat

def construct_date (s : String) : Date :=
  let s_splitted := s.splitOn "-"
  {
    year := (s_splitted[0]!).toNat!,
    month := (s_splitted[1]!).toNat!,
    day := (s_splitted[2]!).toNat!
  }

namespace Date

instance : ToString Date where
  toString := fun d ↦
    let format := fun n ↦ if 9 < n then toString n else "0" ++ toString n
    s!"{format d.year}-{format d.month}-{format d.day}"

instance : BEq Date where
  beq := fun d₁ d₂ ↦ d₁.day == d₂.day ∧ d₁.month == d₂.month ∧ d₁.year == d₂.year

def add_months (d : Date) (n : Nat) : Date :=
  let months := d.month + n
  {
    day := d.day,
    year := d.year + if 12 < months then Nat.div months 12 else 0,
    month := if months ≤ 12 then months else months % 12
  }

def get_nb_day (m y : Nat) : Nat :=
  match m with
  | 1 => 31
  | 2 => if y % 4 == 0 then 29 else 28
  | 3 => 31
  | 4 => 30
  | 5 => 31
  | 6 => 30
  | 7 => 31
  | 8 => 31
  | 9 => 30
  | 10 => 31
  | 11 => 30
  | 12 => 31
  | _ => 0

def add_days (d : Date) (n : Nat) : Date :=
  let days := d.day + n
  let nb_days := (get_nb_day d.month d.year)
  let d_tmp : Date := {
    year := d.year,
    month := d.month,
    day := if days ≤ nb_days then days else days % nb_days
  }
  if nb_days < days then
    add_months d_tmp 1
  else
    d_tmp

def toNat (d : Date) : Nat :=
  d.year * 10000 + d.month * 100 + d.day

end Date
