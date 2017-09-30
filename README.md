# Shell

Now you can run string commands!
Supports `cmd` and `powershell` in Windows!

```julia
julia> using Shell

julia> Shell.run("echo bufan")
bufan

julia> Shell.run(raw"echo $SHELL", capture_output=true)
"/usr/bin/zsh"
```

### Notes

* Change default shell by calling `Shell.useshell("powershell")`.
* The output chomps by default. Change this by calling `Shell.setchomp(false)`.
* In Windows, the code page may be changed to 65001 after running.
