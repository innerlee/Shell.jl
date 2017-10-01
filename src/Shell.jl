module Shell

export @esc_cmd

SHELL   = is_windows() ? "cmd" : "zsh"
CHOMP   = true
SOURCE  = true
DRYRUN  = false
CAPTURE = false

"""
    run(cmd::AbstractString; shell=SHELL, capture_output=CAPTURE, chomp=CHOMP,
        dryrun=DRYRUN, source=SOURCE)

Run your command string in shell.

# Examples
```jldoctest
julia> using Shell

julia> Shell.run(raw"echo \$SHELL", capture_output=true, source=false)
"/usr/bin/zsh"

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
* To capture output, set `capture_output=true`.
* To avoid escaping `\$` everytime, you can use raw string,
  like `raw"echo \$PATH"`
* You can change the default shell (`zsh` in linux and `cmd` in windows)
  using `setshell("other_shell")`.
* In Windows, shell should be `cmd` or `powershell`.
"""
function run(cmd::AbstractString; shell=SHELL, capture_output=CAPTURE,
             chomp=CHOMP, dryrun=DRYRUN, source=SOURCE)
    dryrun && return cmd
    if is_windows()
        if shell == "cmd"
            file = "$(tempname()).bat"
            open(f -> println(f, cmd), file, "w")
            if capture_output
                readstring(`chcp 65001`)
                return chomp ? readchomp(`$file`) : readstring(`$file`)
            else
                return Base.run(`$file`)
            end
        elseif shell == "powershell"
            file = "$(tempname()).ps1"
            open(f -> println(f, cmd), file, "w")
            if capture_output
                readstring(`chcp 65001`)
                return chomp ? readchomp(`powershell -command $file`) :
                               readstring(`powershell -command $file`)
            else
                return Base.run(`powershell -command $file`)
            end
        else
            error("Only support `cmd` and `powershell` in Windows.")
        end
    else
        file = tempname()
        open(file, "w") do f
            if source
                SHELL == "zsh"  ? println(f, "source ~/.zshrc") :
                SHELL == "bash" ? println(f, "source ~/.bashrc") :
                warn("Please make a PR to support source your shell!")
            end
            println(f, cmd)
        end

        if capture_output
            return chomp ? readchomp(`$shell $file`) : readstring(`$shell $file`)
        else
            return Base.run(`$shell $file`)
        end
    end
end

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

# """
#     @esc_str -> String

# Help you escape special characters for the shell.

# # Examples
# ```jldoctest
# julia> files = ["temp file 1", "temp file 2"]
# 2-element Array{String,1}:
#  "temp file 1"
#  "temp file 2"

# julia> filelist = esc`\$files.txt`
# "'temp file 1.txt' 'temp file 2.txt'"

# julia> Shell.run("touch \$filelist")

# julia> Shell.run("rm \$filelist")
# ```

# Be careful, the escape treat space separated terms individually.
# Put them into a varible to get properly escaped.

# # Examples
# ```jldoctest
# julia> esc`temp file 0.txt`
# "temp file 0.txt"

# julia> file = "temp file 0.txt"
# "temp file 0.txt"

# julia> esc`\$file`
# "'temp file 0.txt'"
# ```

# * Not working for `cmd` in Windows because it treats single quotes differently.
# """
macro esc_cmd(cmd)
    esc(:(join(map((@cmd $cmd).exec) do arg
        replace(sprint() do io
            Base.print_shell_word(io, arg, Base.shell_special)
        end, '`', "\\`")
    end, ' ')))
end

end # module
