# Shell

Now you can run string commands!

```julia
julia> using Shell

julia> run("echo bufan")
bufan

julia> run(raw"echo $PATH")
/usr/local/sbin:/usr/local/bin
```

### Notes

* Change default shell by calling `useshell("powershell")`.
* Supports `cmd` and `powershell` in Windows.
* In Windows, the code page would be changed to 65001 after running.
