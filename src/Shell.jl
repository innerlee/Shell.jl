module Shell

import Base.run

export
    useshell,
    run

SHELL = is_windows() ? "cmd" : "zsh"

"""
    run(cmd::AbstractString; shell=SHELL, capture_output=false)

Run your command string in shell.

* To capture output, set `capture_output=true`.
* To avoid escaping `\$` everytime, you can use raw string, like `raw"echo \$PATH"`
* You can change the default shell (`zsh`) using `useshell("other_shell")`.
* In Windows, shell should be `cmd`.
"""
function run(cmd::AbstractString; shell=SHELL, capture_output=false)
    file = "$(tempname()).bat"
    open(f -> println(f, cmd), file, "w")
    if is_windows()
        if shell != "cmd"
            error("Only support `cmd` in Windows currently...")
        else
            if capture_output
                return readstring(`$file`)
            else
                return run(`$file`)
            end
        end
    end
    if capture_output
        return readstring(`$shell $file`)
    else
        return run(`$shell $file`)
    end
end

function useshell(shell::AbstractString)
    global SHELL
    SHELL = shell
end

end # module
