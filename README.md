# Shell

**WARN**
The implementation basically put the string into a script file and run that file.
So it is **error prone** because you have to deal with all the subtle stuff like escaping spaces, quotes, etc.
See the discussions [here](https://discourse.julialang.org/t/a-small-package-to-run-string-as-shell-command/6163).
(You can use `` esc`your argmuments` `` to take advantage of the built-in escaping of `Cmd` objects, though.)
The correct way is to learn the `Cmd` object and perhaps the `Glob.jl` package as pointed out [here](https://discourse.julialang.org/t/a-small-package-to-run-string-as-shell-command/6163/5).
So, it is good for running simple things like `ls`, `echo`, etc.
But **do not** use this in your scripts unless you know exactly what this package does and not-does.

[![Build Status](https://travis-ci.org/innerlee/Shell.jl.svg?branch=master)](https://travis-ci.org/innerlee/Shell.jl)
[![Build status](https://ci.appveyor.com/api/projects/status/v545p6s5rbiwtx2y?svg=true)](https://ci.appveyor.com/project/innerlee/shell-jl)

Now you can run string commands!

Supports `cmd` and `powershell` in Windows!

### Installation

```julia
julia> Pkg.clone("https://github.com/innerlee/Shell.jl")
```

### Usage
```julia
julia> using Shell

julia> Shell.run(raw"echo $SHELL", capture_output=true)
"/usr/bin/zsh"

julia> Shell.run(raw"for i in bu fan; do echo $i; done")
bu
fan

julia> files = ["temp file 1", "temp file 2"]
2-element Array{String,1}:
 "temp file 1"
 "temp file 2"

julia> filelist = esc`$files.txt`
"'temp file 1.txt' 'temp file 2.txt'"

julia> Shell.run("touch $filelist")

julia> Shell.run("touch $(esc`$files.$["txt","md"]`)", dryrun=true)
"touch 'temp file 1.txt' 'temp file 1.md' 'temp file 2.txt' 'temp file 2.md'"

julia> Shell.run("ls > 'temp file 0.txt'")

julia> Shell.run("cat 'temp file 0.txt' | grep temp")
temp file 0.txt
temp file 1.txt
temp file 2.txt

julia> Shell.run("rm 'temp file'*")
```

### Notes

* use `` esc`your string` `` to help you escape (not working for `cmd` in Windows).
* use `dryrun=true` to check the command to be run without actually running.
* Change default shell by calling `Shell.useshell("powershell")`.
* The output chomps by default. Change this by calling `Shell.setchomp(false)`.
* In Windows, the code page may be changed to 65001 after running.
