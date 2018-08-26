using Shell
using Test

@testset "ls" begin
    if Sys.iswindows()
        @test Shell.run("dir") == nothing
        @test split(Shell.run("cd", capture=true))[end] == pwd()
        Shell.setchomp(false)
        @test endswith(Shell.run("echo love", capture=true), "\n")

        Shell.setshell("powershell")
        Shell.setchomp(true)
        @test Shell.run("ls") == nothing
        @test Shell.run("(Get-Item -Path . -Verbose).FullName", capture=true) == pwd()
        Shell.setchomp(false)
        @test endswith(Shell.run("pwd", capture=true), "\n")
        @test !endswith(Shell.run("(Get-Item -Path . -Verbose).FullName", capture=true, chomp=true), "\n")
    else
        Shell.setshell("bash")
        @test Shell.run("ls") == nothing
        @test Shell.run("pwd", capture=true) == pwd()
        Shell.setchomp(false)
        @test endswith(Shell.run("pwd", capture=true), "\n")
        @test !endswith(Shell.run("pwd", capture=true, chomp=true), "\n")

        file = "temp file 0"
        @test esc`$file` == "'temp file 0'"
        files = ["temp file 1", "temp file 2"]
        filelist = esc`$files.txt`
        @test filelist == "'temp file 1.txt' 'temp file 2.txt'"
        @test Shell.run("touch $filelist") == nothing
        @test Shell.run("rm $filelist") == nothing
    end
end
