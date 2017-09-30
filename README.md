# Shell

**WARN**
* The package is doing type piracy (extend Base.run), which is a bad practise.
* And DO NOT write buggy code like this!

Now you can run string commands!
Supports `cmd` and `powershell` in Windows!

```julia
julia> using Shell

julia> run("echo bufan")
bufan

julia> run(raw"echo $SHELL", capture_output=true)
"/usr/bin/zsh\n"
```

### Notes

* Change default shell by calling `useshell("powershell")`.
* In Windows, the code page may be changed to 65001 after running.
