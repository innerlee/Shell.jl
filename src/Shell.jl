module Shell

export @esc_cmd

SHELL   = Sys.iswindows() ? "cmd" :
          Sys.isapple()   ? get(ENV, "SHELL", "bash") :
          readchomp(pipeline(`getent passwd $(get(ENV, "LOGNAME", "root"))`, `cut -d: -f7`))
CHOMP   = true
SOURCE  = false
CAPTURE = false
DRYRUN  = false

"""
    run(cmd::AbstractString; shell=SHELL, capture=CAPTURE, chomp=CHOMP,
        dryrun=DRYRUN, source=SOURCE)

Run your command string in shell.

# Examples
```jldoctest
julia> using Shell

julia> Shell.run(raw"echo \$SHELL", capture=true)
"/bin/zsh"

julia> Shell.run(raw"for i in bu fan; do echo \$i; done")
bu
fan

julia> files = ["temp file 1", "temp file 2"]
2-element Array{String,1}:
 "temp file 1"
 "temp file 2"

julia> filelist = esc`\$files.txt`
"'temp file 1.txt' 'temp file 2.txt'"

julia> Shell.run("touch \$filelist")

julia> Shell.run("ls > 'temp file 0.txt'")

julia> Shell.run("cat 'temp file 0.txt' | grep temp")
temp file 0.txt
temp file 1.txt
temp file 2.txt

julia> Shell.run("rm 'temp file'*")
```

* You should properly escape all special characters manually.
* use `dryrun=true` to check the command to be run without actually running.
* To capture output, set `capture=true`.
* To avoid escaping `\$` everytime, you can use raw string,
  like `raw"echo \$PATH"`
* You can change the default shell (`zsh` in linux and `cmd` in windows)
  using `setshell("other_shell")`.
* In Windows, shell should be `cmd` or `powershell`.
"""
function run(cmd::AbstractString; shell=SHELL, capture=CAPTURE,
             chomp=CHOMP, dryrun=DRYRUN, source=SOURCE)
    result = nothing
    file = tempname()
    pre_script = ""
    command = ``
    if Sys.iswindows()
        if shell == "cmd"
            file = "$file.bat"
            pre_script = "@echo off\nchcp 65001 >nul"
            command = `$file`
        elseif shell == "powershell"
            file = "$file.ps1"
            pre_script = raw"chcp 65001 >$null"
            command = `powershell -command $file`
        elseif shell == "wsl"
            wslshell = split(readchomp(`wsl getent passwd \$LOGNAME`), ":")[end]
            file = "$file.sh"
            source && (pre_script = shell_source(wslshell))
            ffile = replace(file, "\\" => "\\\\")
            wslfile = readchomp(`wsl wslpath $ffile`)
            command = `wsl $wslshell $wslfile`
        else
            @error("Only support cmd/powershell/wsl in Windows.")
        end
    else
        source && (pre_script = shell_source(shell))
        command = `$shell $file`
    end

    open(file, "w") do f
        println(f, pre_script)
        println(f, cmd)
    end

    if dryrun
        result = println(strip(read(file, String)))
    elseif capture
        result = chomp ? readchomp(command) : read(command, String)
    else
        Base.run(command)
    end
    rm(file)
    return result
end

shell_source(shell) =
    (endswith(shell, "/zsh") || shell == "zsh") ? "[ -f ~/.zshrc ] && source ~/.zshrc >/dev/null" :
    (endswith(shell, "/bash") || shell == "bash") ? "[ -f ~/.bashrc ] && source ~/.bashrc" :
    (endswith(shell, "/fish") || shell == "fish") ? "[ -f ~/.config/fish/config.fish ] && source ~/.config/fish/config.fish" :
    (@warn("Please make a PR to support source your awesome `$shell` shell!"); "")

"""
    setshell(shell::AbstractString)

Specify which shell to use (Windows defaults to `cmd`, and `zsh` otherwise).
"""
function setshell(shell::AbstractString)
    global SHELL
    SHELL = shell
end

"""
    setchomp(chomp::Bool)

Set whether chomp the output (default is true).
"""
function setchomp(chomp::Bool)
    global CHOMP
    CHOMP = chomp
end

"""
    setissource(source::Bool)

Whether source the rc file (e.g. `.zshrc`) before run script (default is true).
"""
function setissource(source::Bool)
    global SOURCE
    SOURCE = source
end

"""
    setisdryrun(dryrun::Bool)

Whether dryrun the rc file (e.g. `.zshrc`) before run script (default is true).
"""
function setisdryrun(dryrun::Bool)
    global DRYRUN
    DRYRUN = dryrun
end

"""
    setiscapture(capture::Bool)

Whether capture the rc file (e.g. `.zshrc`) before run script (default is true).
"""
function setiscapture(capture::Bool)
    global CAPTURE
    CAPTURE = capture
end

"""
    @esc_str -> String

Help you escape special characters for the shell.

# Examples
```jldoctest
julia> files = ["temp file 1", "temp file 2"]
2-element Array{String,1}:
 "temp file 1"
 "temp file 2"

julia> filelist = esc`\$files.txt`
"'temp file 1.txt' 'temp file 2.txt'"

julia> Shell.run("touch \$filelist")

julia> Shell.run("rm \$filelist")
```

Be careful, the escape treat space separated terms individually.
Put them into a varible to get properly escaped.

# Examples
```jldoctest
julia> esc`temp file 0.txt`
"temp file 0.txt"

julia> file = "temp file 0.txt"
"temp file 0.txt"

julia> esc`\$file`
"'temp file 0.txt'"
```

* Not working for `cmd` in Windows because it treats single quotes differently.
"""
macro esc_cmd(cmd)
    esc(:(join(map((@cmd $cmd).exec) do arg
        replace(sprint() do io
            Base.print_shell_word(io, arg, Base.shell_special)
        end, '`' => "\\`")
    end, ' ')))
end

end # module
