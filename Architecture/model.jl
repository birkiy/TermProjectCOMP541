

using Knet: conv4, param, param0, dropout, deconv4, pool, mat, relu, Adam, KnetArray, Param, nll

using AutoGrad: @diff

include("data.jl")
include("loss.jl")
include("arch.jl")
include("layers.jl")





x = rand(Float32, (699,4,1,1000));
y1 = rand(Float32, (699,1,2,1000));
y2 = rand(Float32, (1,1,2, 1000));

y = [y1,y2,y1,y2];


data = minibatch(x, y; batchsize=Int32(100));

seqLen = size(x, 1)
tasks = ["LNCaP.dht.AR", "LNCaP.veh.AR"]


bpnetBody = Body(
    Conv(25,4,1,64, padding=(12, 0)) # Int(max((cx - 1) * s1 + w1 - cx, 0)/2)
)

nLayer = 9

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


bpnet(data)
