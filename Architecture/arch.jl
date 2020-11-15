

# Define a body (up to bottleneck)
mutable struct Body
    layers
    Body(layers...) = new(layers)
end


function addLayer!(b::Body, l)
    b.layers = (
        b.layers...,
        l
    )
end


(b::Body)(x) = (for l in b.layers;x = l(x);end;x)


##################################

# Define Head structure

mutable struct Head
    layers
    lossF
    Head(layers...; lossF=identity) = new(layers, lossF)
end

(h::Head)(x) = (for l in h.layers;x = l(x);end;x)



###########################


mutable struct Chain
    body
    heads
    n
    bottleneck
    Chain(body, heads...; n=0, bottleneck=nothing) = new(body, heads..., n, bottleneck)
end

Chain(b::Body) = Chain(b, []; n=0)
(c::Chain)(h::Head...) = addHead!(c, h...)

function addHead!(c::Chain, h...)
    c.heads = vcat(c.heads..., h...)
    c.n = length(c.heads)
end

##########################################


function meanLoss(c::Chain, d::Data)
    J = [Float32(0) for n in 1:c.n]
    for (j, (x, y)) in enumerate(d)
        for (hIdx, (h, yi)) in enumerate(zip(c.heads, y))
            J[hIdx] += h.lossF(h(c.body(x)), yi)
        end
    end
    J ./ length(d)
end


every(n,itr) = (x for (i,x) in enumerate(itr) if i%n == 0)

function train!(c::Chain, dTrn::Data, dTst::Data; iters=50, period=10)
    lossTrn, lossTst = [], []
    for i=1:period:iters
        println("epoch start")
        push!(lossTrn, meanLoss(c, dTrn))
        push!(lossTst, meanLoss(c, dTst))
        for (x, y) in every(period, dTrn)
            for (h, yi) in zip(c.heads, y)
                J = @diff h.lossF(h(c.body(x)), yi)
                println(J)
                for p in params(J)
                    ∇p = grad(J, p)
                    update!(p, ∇p)
                end
            end
        end
        println(sum.(lossTrn), sum.(lossTst))
        println("epoch end")
        println()
    end
    return (lossTrn, lossTst)
end
