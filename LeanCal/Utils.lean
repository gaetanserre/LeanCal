/-
 - Created in 2024 by Gaëtan Serré
 -/


def sys_call (cmd : String) (args : Array String) (cwd : Option String := none) : IO String :=
  IO.Process.run {cmd := cmd, args := args, cwd := cwd}

def string_to_true (_ : String) : IO Bool := pure true

def read_lines (fname : String) : IO (List String) :=
  IO.FS.lines fname >>= fun a ↦ pure a.data
