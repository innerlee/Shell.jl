# Shell

[![Build Status](https://travis-ci.org/innerlee/Shell.jl.svg?branch=master)](https://travis-ci.org/innerlee/Shell.jl)
[![Build status](https://ci.appveyor.com/api/projects/status/v545p6s5rbiwtx2y?svg=true)](https://ci.appveyor.com/project/innerlee/shell-jl)

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
