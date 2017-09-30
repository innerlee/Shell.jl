module Shell

import Base.run

export
    useshell,
    run

SHELL = "zsh"

function run(cmd::AbstractString; shell=SHELL)
    file = tempname()
    open(f -> println(f, cmd), file, "w")
    run(`$shell $file`)
end

function useshell(shell::AbstractString)
    global SHELL
    SHELL = shell
end

end # module
