module Shell

import Base.run

export
    useshell,
    run

SHELL = "zsh"

"""
    run(cmd::AbstractString; shell=SHELL, capture_output=false)

Run your command string in shell.

* To capture output, set `capture_output=true`.
* To avoid escaping `\$` everytime, you can use raw string, like `raw"echo \$PATH"`
* You can change the default shell (`zsh`) using `useshell("other_shell")`.
"""
function run(cmd::AbstractString; shell=SHELL, capture_output=false)
    file = tempname()
    open(f -> println(f, cmd), file, "w")
    if capture_output
        return readstring(`$shell $file`)
    else
        run(`$shell $file`)
    end
end

function useshell(shell::AbstractString)
    global SHELL
    SHELL = shell
end

end # module
