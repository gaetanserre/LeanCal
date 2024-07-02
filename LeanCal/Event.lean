/-
 - Created in 2024 by Gaëtan Serré
 -/

import LeanCal.Utils


structure Event where
  day : String
  hour : String
  event : String

instance : ToString Event where
  toString := fun e ↦ s!"{e.day}_{e.hour}  {e.event}"

instance : BEq Event where
  beq := fun e1 e2 ↦ toString e1 == toString e2

def construct_event (event_str : String) : Event :=
  let date_event := (event_str.splitOn "  ")
  let day_hour := (date_event.get! 0).splitOn "_"
  {day := day_hour.get! 0, hour := day_hour.get! 1, event := date_event.get! 1}
