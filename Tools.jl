include("Graph.jl")

using Random
using SparseArrays
using LinearAlgebra
using Statistics

function PowerLaw(n; alp = 2.5, xmin = 1, fixed = 1)
    Random.seed!(round(Int, time() * 10000))
    x = rand(n)
    for i = 1 : n
        x[i] = xmin * ((1 - x[i])^(-1.0/(alp - 1.0)))
    end
    if fixed==0
        x ./= (maximum(x)/100)
    elseif fixed==1
        x .-= mean(x)
    end
    return x
end

function Uniform(n)
    Random.seed!(round(Int, time() * 10000))
    x = rand(n)
    x .*= 2
    x .-= 1
    return x
end

function Exponential(n; lmd = 1, xmin = 1)
    Random.seed!(round(Int, time() * 10000))
    x = rand(n)
    for i = 1 : n
        x[i] = xmin - (1.0/lmd)*log(1-x[i])
    end
    x .-= mean(x)
    return x
end

function Normal(n)
    Random.seed!(round(Int, time() * 10000))
    x = randn(n)
    x .-= mean(x)
    return x
end

function generateK(n)
    return Diagonal(PowerLaw(n, fixed=0))
end

function getL(G)
	L = zeros(G.n, G.n)
	for (ID, u, v, w) in G.E
		L[u, u] += w
		L[v, v] += w
		L[u, v] -= w
		L[v, u] -= w
	end
	return L
end

function getSparseL(G)
    d = zeros(G.n)
    for (ID, u, v, w) in G.E
        d[u] += w
        d[v] += w
    end
    Is = zeros(Int32, G.m*2+G.n)
    Js = zeros(Int32, G.m*2+G.n)
    Vs = zeros(G.m*2+G.n)
    for (ID, u, v, w) in G.E
        Is[ID] = u
        Js[ID] = v
        Vs[ID] = -w
        Is[ID + G.m] = v
        Js[ID + G.m] = u
        Vs[ID + G.m] = -w
    end
    for i = 1 : G.n
        Is[G.m + G.m + i] = i
        Js[G.m + G.m + i] = i
        Vs[G.m + G.m + i] = d[i]
    end
    return sparse(Is, Js, Vs, G.n, G.n)
end
