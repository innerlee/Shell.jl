module Shell

export @esc_cmd, @s_cmd

SHELL = Sys.iswindows() ? "cmd" : "zsh"
CHOMP = true

"""
    run(cmd::AbstractString; shell=SHELL, capture_output=false)

Run your command string in shell.

# Examples
```jldoctest
julia> using Shell

julia> Shell.run(raw"echo \$SHELL", capture_output=true)
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
* To capture output, set `capture_output=true`.
* To avoid escaping `\$` everytime, you can use raw string,
  like `raw"echo \$PATH"`
* You can change the default shell (`zsh` in linux and `cmd` in windows)
  using `useshell("other_shell")`.
* In Windows, shell should be `cmd` or `powershell`.
"""
function run(cmd::AbstractString; shell=SHELL, capture_output=false, chomp=CHOMP)
    if Sys.iswindows()
        if shell == "cmd"
            file = "$(tempname()).bat"
            open(f -> println(f, cmd), file, "w")
            if capture_output
                read(`chcp 65001`, String)
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
                               read(`powershell -command $file`, String)
            else
                return Base.run(`powershell -command $file`)
            end
        else
            error("Only support `cmd` and `powershell` in Windows.")
        end
    else
        file = tempname()
        open(f -> println(f, cmd), file, "w")

        if capture_output
            return chomp ? readchomp(`$shell $file`) : read(`$shell $file`, String)
        else
            return Base.run(`$shell $file`)
        end
    end
end

"""
    useshell(shell::AbstractString)

Specify which shell to use (Windows defaults to `cmd`, and `zsh` otherwise).
"""
function useshell(shell::AbstractString)
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
