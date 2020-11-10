

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

(c::Chain)(x) = [
    h(c.body(x))
    for h in c.heads
]


(c::Chain)(x, y) = [
    @diff h.lossF(p, y)
    for (h, y, p) in zip(c.heads, y, c(x))
]



(c::Chain)(data::Data) =
    sum(
        [
            l[i]
            for l in
                [
                    c(d...)
                    for d in data
                ],
            i in 1:4
        ], dims=1
        ) / length(data)
