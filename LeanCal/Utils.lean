/-
 - Created in 2024 by Gaëtan Serré
 -/


def sys_call (cmd : String) (args : Array String) (cwd : Option String := none) : IO String :=
  IO.Process.run {cmd := cmd, args := args, cwd := cwd}

def string_to_true (_ : String) : IO Bool := pure true

def read_lines (fname : String) : IO (List String) :=
  let remove_last_endline (a : Array String) : List String :=
    if a.size == 0 then a.data
    else if a.get! (a.size - 1) == "" then
      a.data.dropLast
    else a.data
  IO.FS.lines fname >>= fun a ↦ pure (remove_last_endline a)

namespace List

def diff {α : Type} [BEq α] (l1 l2 : List α) : List α :=
  let rec aux (l acc : List α) :=
    match l with
    | [] => acc
    | hd::tl =>
      if l2.contains hd then aux tl acc
      else aux tl (hd::acc)
  aux l1 []

end List

def send_notification (s : String) : IO Bool := do
  sys_call "notify-send" #[s, "-t", "10000", "-i", "LeanCal_HOME/calendar.jpg"] >>= string_to_true
