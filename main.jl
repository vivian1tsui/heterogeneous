include("Graph.jl")
include("Tools.jl")
include("Algorithm.jl")

function runExperiments(ARGS)
    # Read Graph
    buf = split(ARGS[1], ',')
    fileName = string("data/", buf[1], ".txt")
    networkType = "unweighted"
    if size(buf, 1) > 1
        networkType = buf[2]
    end
    G = readGraph(fileName, networkType)

    # Open Log File
    lg = open("log.txt", "a")
    println(lg, buf[1])
    println(lg, G.n, " ", G.m)
    println(lg)
    D_func = Dict("uniform"=>Uniform, 
                  "powerlaw"=>PowerLaw, 
                  "norm"=>Normal, 
                  "exp"=>Exponential)
    D_log = Dict("uniform"=>"Uniform Distribution", 
                 "powerlaw"=>"Power-law Distribution", 
                 "norm"=>"Normal Distribution", 
                 "exp"=>"Exponential Distribution")
    
    K = generateK(G.n)
    s = D_func[ARGS[2]](G.n)

    println(lg, D_log[ARGS[2]])
    G.n<60000 ? doExp(G, s, K, lg) : doLarge(G, s, K, lg)
    println(lg)
    close(lg)
end

runExperiments(ARGS)