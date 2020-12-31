using ArgParse
using ProgressMeter
using Random
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
        "--seed"
            help = "random seed"
            arg_type = Int
            default = 0
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


function wait_until(i; meets, speed)
    j = meets
    if i == j
        return Inf
    end
    d = hypertorus_distance(i, j)
    return ((d/speed) - (i.t - j.t)) / 2
end;


function civs_visible_from(i; C, speed)
    C_i = []
    for j in C
        d_ij = hypertorus_distance(i, j)
        o_ij = j.t + d_ij
        if i.t > o_ij
            push!(C_i, j)
        end
    end
    return C_i
end


function visible_angle(i; looking_at, speed)
    j = looking_at
    if i == j
        return -Inf
    end
    d_ij = hypertorus_distance(i, j)
    o_ij = j.t + d_ij
    return 2*speed*(i.t - o_ij)/d_ij
end


function main()
    parsed_args = parse_commandline()
    N = parsed_args["N"]
    D = parsed_args["D"]
    n = parsed_args["n"]
    s = parsed_args["speed"]
    seed = parsed_args["seed"]
    filestr = string("N", N, "D", D, "n", n, "s", s, "rs", seed, "-v1.json")
    outputf = joinpath(parsed_args["dir"], filestr)
    quiet = parsed_args["quiet"]

    Random.seed!(seed)

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

    if !quiet
        println("Computing wait times...")
    end
    for i in 1:length(C)
        w_ij = minimum(GC->wait_until(C[i], meets=GC, speed=s), C)
        with_w = (origin=C[i].origin, t=C[i].t, w=w_ij)
        C[i] = with_w
    end

    if !quiet
        println("Computing visible civs and visible angles...")
    end
    for ix in 1:length(C)
        C_i = civs_visible_from(C[ix], C=C, speed=s)
        if length(C_i) > 0
            max_b = maximum(GC->visible_angle(C[ix], looking_at=GC, speed=s), C_i)
        else
            max_b = -Inf
        end
        with_values = (origin=C[ix].origin, t=C[ix].t, w=C[ix].w, C=length(C_i), b=max_b)
        C[ix] = with_values
    end

    open(outputf, "w") do io
        write(io, JSON.json(C, 4))
    end
    if !quiet
        println("Wrote civ list (C) to ", outputf)
    end

end

main()