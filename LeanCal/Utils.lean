/-
 - Created in 2024 by Gaëtan Serré
 -/


def sys_call (cmd : String) (args : Array String) (cwd : Option String := none) : IO String :=
  IO.Process.run {cmd := cmd, args := args, cwd := cwd}

def IO_string_to_true (_ : String) : IO Bool := pure true

def read_lines (fname : String) : IO (List String) :=
  let remove_last_endline (a : Array String) : List String :=
    if a.size == 0 then a.toList
    else if a[a.size - 1]! == "" then
      a.toList.dropLast
    else a.toList
  IO.FS.lines fname >>= fun a ↦ pure (remove_last_endline a)

namespace List
/-- Given two lists `l₁` `l₂` construct [e | e ∈ l₁ ∧ e ∉ l₂] -/
def diff {α : Type} [BEq α] (l₁ l₂ : List α) : List α :=
  let rec aux (l acc : List α) :=
    match l with
    | [] => acc
    | hd::tl =>
      if l₂.contains hd then aux tl acc
      else aux tl (hd::acc)
  aux l₁ []

end List

def send_notification (s : String) : IO Bool := do
  sys_call "notify-send" #[s, "-t", "10000", "-i", "/home/gserre/.LeanCal/calendar.png"]
    >>= IO_string_to_true
