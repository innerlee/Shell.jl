module Shell

SHELL = is_windows() ? "cmd" : "zsh"

"""
    run(cmd::AbstractString; shell=SHELL, capture_output=false)

Run your command string in shell.

* To capture output, set `capture_output=true`.
* To avoid escaping `\$` everytime, you can use raw string, like `raw"echo \$PATH"`
* You can change the default shell (`zsh` in linux and `cmd` in windows) using `useshell("other_shell")`.
* In Windows, shell should be `cmd` or `powershell`.
"""
function run(cmd::AbstractString; shell=SHELL, capture_output=false)
    if is_windows()
        if shell == "cmd"
            file = "$(tempname()).bat"
            open(f -> println(f, cmd), file, "w")
            if capture_output
                readstring(`chcp 65001`)
                return readstring(`$file`)
            else
                return Base.run(`$file`)
            end
        elseif shell == "powershell"
            file = "$(tempname()).ps1"
            open(f -> println(f, cmd), file, "w")
            if capture_output
                readstring(`chcp 65001`)
                return readstring(`powershell -command $file`)
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
            return readstring(`$shell $file`)
        else
            return Base.run(`$shell $file`)
        end
    end
end

function useshell(shell::AbstractString)
    global SHELL
    SHELL = shell
end

end # module
