

using Knet: conv4, param, param0, dropout, deconv4, pool, mat, relu, Adam, KnetArray, Param, nll, adam!, progress!, update!

using AutoGrad: @diff, params, grad

include("data.jl")
include("loss.jl")
#include("arch.jl")
include("layers.jl")





x = rand(Float32, (699,4,1,1000));
y1 = rand(Float32, (699,1,2,1000));
y2 = rand(Float32, (1,1,2, 1000));

y = [y1,y2,y1,y2];


dTrn = minibatch(x, y; batchsize=Int32(100));

seqLen = size(x, 1)
tasks = ["LNCaP.dht.AR", "LNCaP.veh.AR"]


bpnetBody = Body(
    Conv(25,4,1,64, padding=(12, 0)) # Int(max((cx - 1) * s1 + w1 - cx, 0)/2)
)

nLayer = 2

for i=1:nLayer
    rate = 2^i
    addLayer!(bpnetBody,
        Conv(3,1,64,64, padding=(rate, 0), dilation=(rate, 0))
    )
end


bpnet = Chain(bpnetBody)


for task in tasks
    profileHead = Head(
        DeConv(25,1,2,64, padding=(12,0));
        lossF=
            multinomial_nll
    )
    println("profileHead")
    countHead = Head(
        Dense(64,2, window=(seqLen,1));
        lossF=
            mse
    )
    println("countHead")
    bpnet(profileHead, countHead)
end




x = rand(Float32, (699,4,1,300));
y1 = rand(Float32, (699,1,2,300));
y2 = rand(Float32, (1,1,2, 300));

y = [y1,y2,y1,y2];


dTst = minibatch(x, y; batchsize=Int32(100));



train!(bpnet, dTrn, dTst)
































bpnet(first(data)...)

@diff bpnet(x, y)

progress!(adam!(bpnet, data))


bpnet.bottleneck = bpnet.body(x)
@diff bpnet(x, y)

import .Iterators: cycle, Cycle, take

function mytrain!(model::Chain, train_data::Data,
                  period::Int=10, iters::Int=50)
    # Your code here
    train_loss, test_loss = [], []

    for i=1:period:iters
        push!(train_loss, model(train_data))
        # push!(test_loss, model(test_data))
        training = adam!(model,take(cycle(train_data),period))
    end

    push!(train_loss, model(train_data))
    # push!(test_loss, model(test_data))
    return 0:period:iters, train_loss#, test_loss
end


function mytrain!(c::Chain, train_data::Data,
    period::Int=10, iters::Int=50)


    for (h, y, p) in zip(c.heads, y, c(x))


mytrain!(bpnet, data)


a = Conv(25,4,1,64, padding=(12, 0))



for (x, y) in zip(x, y1)
    @diff multinomial_nll(o, y1)



@primitive log(x),dy,y  (dy .* (1 ./ x))

(c::Chain)(x) =
    c.heads[1](c.body(x))




@diff multinomial_nll()

epoch = 5
lr = 0.001
gradfun = grad(multinomial_nll)
for r in 1:epoch
    g = gradfun(bpnet(x), y1)
    for i in 1:length(w)
        bpnet.w[i] -= lr * g[i]
        println(sum(bpnet.w))
    end
end
