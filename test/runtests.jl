using Shell
using Base.Test

@testset "ls" begin
    if is_windows()
        @test Shell.run("dir") == nothing
        @test split(Shell.run("cd", capture_output=true))[end] == pwd()
        Shell.setchomp(false)
        @test endswith(Shell.run("pwd", capture_output=true), "\n")

        Shell.useshell("powershell")
        Shell.setchomp(true)
        @test Shell.run("ls") == nothing
        @test Shell.run("(Get-Item -Path . -Verbose).FullName", capture_output=true) == pwd()
        Shell.setchomp(false)
        @test endswith(Shell.run("pwd", capture_output=true), "\n")
        @test !endswith(Shell.run("(Get-Item -Path . -Verbose).FullName", capture_output=true, chomp=true), "\n")
    else
        Shell.useshell("bash")
        @test Shell.run("ls") == nothing
        @test Shell.run("pwd", capture_output=true) == pwd()
        Shell.setchomp(false)
        @test endswith(Shell.run("pwd", capture_output=true), "\n")
        @test !endswith(Shell.run("pwd", capture_output=true, chomp=true), "\n")
    end
end
