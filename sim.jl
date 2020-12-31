using ArgParse
using ProgressMeter
import JSON


function parse_commandline()
    settings = ArgParseSettings()
    settings.description = "Run simulation and write list of civs (with origin position and origin time) to a .json file."

    @add_arg_table settings begin
        "-N"
            help = "the number of samples to use."
            arg_type = Int
            default = 4000
        "-D"
            help = "the effective dimension of space"
            arg_type = Int
            default = 3
        "-n"
            help = "the number of hard try-try steps"
            arg_type = Int
            default = 10
        "--speed", "-s"
            help = "the speed of expanding GCs (in units of c)"
            arg_type = Float64
            default = 0.125
        "--dir"
            help = "directory to save output (json) to"
            arg_type = String
            default = pwd()
        "--quiet", "-q"
            help = "don't display progress to stdout, only create file"
            action = :store_true
    end

    return parse_args(settings)
end


function hypertorus_distance(i, j)
    a = abs.(i.origin .- j.origin)
    mask = a .< 0.5
    diff = mask .* a .+ (1 .- mask).*(1 .- a)
    return sqrt(sum(diff .* diff))
end;


function prevents(i; prevents, speed)
    a = i.t + hypertorus_distance(i, prevents) / speed
    return prevents.t > a
end;


function main()
    parsed_args = parse_commandline()
    N = parsed_args["N"]
    D = parsed_args["D"]
    n = parsed_args["n"]
    s = parsed_args["speed"]
    filestr = string("N", N, "D", D, "n", n, "s", s, "-v1.json")
    outputf = joinpath(parsed_args["dir"], filestr)
    quiet = parsed_args["quiet"]

    if !quiet
        println("Initializing candidate GCs...")
    end
    GCs = [(origin=rand(D), t=rand()^(1 / (1 + n))) for _=1:N];
    sort!(GCs, by=GC->GC.t);

    C = []
    if !quiet
        pbar = Progress(N, desc="Pruning GCs...")
    end
    while !isempty(GCs)
        i = popfirst!(GCs) # the youngest civ
        push!(C, i)
        GCs = [j for j in GCs if !prevents(i, prevents=j, speed=s)]
        if !quiet
            ProgressMeter.update!(pbar, N - length(GCs))
        end
    end
    if !quiet
        println(length(C), "GCs arose in our simulation")
    end

    open(outputf, "w") do io
        write(io, JSON.json(C, 4))
    end
    println("Wrote civ list to ", outputf)

end

main()