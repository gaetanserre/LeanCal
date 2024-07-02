import Lake
open Lake DSL

package «LeanCal» where
  -- add package configuration options here

lean_lib «LeanCal» where
  -- add library configuration options here

@[default_target]
lean_exe «leancal» where
  root := `Main
