# Shell

Now you can run string commands!

```julia
julia> using Shell

julia> run("echo bufan")
bufan

julia> run(raw"echo $PATH")
/usr/local/sbin:/usr/local/bin
```
