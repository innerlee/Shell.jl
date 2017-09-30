# Shell

**WARN**
The implementation basically put the string into a script file and run that file.
So it is **error prone** because you have to deal with all the subtle stuff like escaping spaces, quotes, etc.
See the discussions [here](https://discourse.julialang.org/t/a-small-package-to-run-string-as-shell-command/6163).
The correct way is to learn the `Cmd` object and perhaps the `Glob.jl` package as pointed out [here](https://discourse.julialang.org/t/a-small-package-to-run-string-as-shell-command/6163/5). So, it is good for running simple things like `ls`, `echo`, etc. But **do not** use this in your scripts, and **do not** write buggy code like this.

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

### Installation

```julia
julia> Pkg.clone("https://github.com/innerlee/Shell.jl")
```

### Notes

* Change default shell by calling `Shell.useshell("powershell")`.
* The output chomps by default. Change this by calling `Shell.setchomp(false)`.
* In Windows, the code page may be changed to 65001 after running.
