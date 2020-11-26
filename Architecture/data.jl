


#
# seq = "GGCAGTCCGAGCTGGGCCTGGGAGGGTGGGCAGGGCCGCCACAGGCCTCTGGGCTGGGGGCTGGGGCTGAGCCTTGCTGAGGGAGCACAGGTACAGCCACACCATAGGCCTGGCTGGAGGGGCCACCTCAGGCCAGTGAGGCCATCAGATGCTACCTGGGGAGGCTACCTGGGCACTGCAGGGGGGGGTGGATGGGCCCCCCAACTCCGCCCCACTACTGACTCCGCCAGGTCCCTTCCCCAACTGGAAGCTCAGCCCCTCCACCAAGCCAGCCCCTTTCACACAAGGATACACAAGGATGTGCACCTACGGTAAACAAAGGGCTATTTTTATAGCCTCATTGTTTCCTCTGGCAGCTTCCTAACTCCCCAGCCAAGGTACACCTCAGTCCTCCCTCCGGGCACACTGCAGACCTCCAGCTCTGCAGGCTCTGCAGGCTCCGCCCTGCCAGGTGCTGGCAGCTCGGGACTCCACCACCCCTCAGGGGCTGCGCAGAGGAGGCCAGGGCCTAGGGTGCAGCCAGGGCCCAAGGTGAGGAGCTGTGGCCTCTTCCTGTTCTGCAGATGGAGGCCTGAGGCTGGGAAGCGGCACTGAGGGGTCACGGGGCATCACCCACTGCCATGGGGGCATCTCTCAGCTGGGCCCACCTAGACCTATGTCCTGAGTCAGCAGCCTGGCCTCTTGCCCAAAGATGTCAAG"


using PyCall
using JLD2



#
# ln95AR7m = bw.open("/home/user/Ders/Comp541/ARsyntax/bigwig/LN95.AR-V7.merged.-.5end.bigWig")
# ln95AR7p = bw.open("/home/user/Ders/Comp541/ARsyntax/bigwig/LN95.AR-V7.merged.+.5end.bigWig")
#
#
# global seqEncode = Dict(
#     'A' => Float32[1,0,0,0],
#     'T' => Float32[0,1,0,0],
#     'G' => Float32[0,0,1,0],
#     'C' => Float32[0,0,0,1],
#     'N' => Float32[0,0,0,0],
#     )


global seqEncode = Dict(
    'A' => 1,
    'T' => 2,
    'G' => 3,
    'C' => 4
    )




# function seqEncoder(seq)
#     encode = seqEncode[uppercase(first(seq))]'
#     for base in  seq[2:end]
#         encode = vcat(encode, seqEncode[uppercase(base)]')
#     end
#     # encode = vcat(encode,zeros(21, length(seq)))
#     return reshape(encode, size(encode)..., 1,1)
# end





path="/groups/lackgrp/ll_members/berkay/TermProjectComp541/ARsyntax/results"


# x = []

union = readlines(joinpath(path, "fasta", string("all", ".fasta")))

#
# for line in readlines(joinpath(path, "fasta", string("all", ".fasta")))
#     name, seq = split(line, "\t")
#     push!(x, seqEncoder(seq))
# end
#
# max(first.(size.(x))...)

xZ = zeros(Float32, 1000,4,1,82646);

for (i, line) in enumerate(union)
    name, seq = split(line, "\t")
    for (j, base) in enumerate(seq)
        base = uppercase(base)
        haskey(seqEncode, base) ? xZ[j,seqEncode[base],1,i] = 1 : nothing
    end
end


save "x.jld2" xZ



heads = first.(
    split.(
        collect(
            walkdir("/groups/lackgrp/ll_members/berkay/TermProjectComp541/ARsyntax/results/fasta")
            )[1][3], ".fasta"
        )
    )

heads = ["22RV1.AR-C19", "22RV1.AR-V7"]
heads= ["LNCaP.dht.AR", "LNCaP.veh.AR"]

heads= ["22RV1.HOXB13", "LN95.AR-C19", "LN95.AR-V7", "LN95.HOXB13", "malignant.1.AR", "malignant.2.AR", "malignant.3.AR", "malignant.4.AR", "non-malignant.1.AR", "non-malignant.2.AR"]



bw = pyimport("pyBigWig")
np = pyimport("numpy")


# y = []
for head in heads
    yProfile = zeros(Float32, 1000,1,2,82646)
    yCount = zeros(Float32, 1,1,2,82646)
    p = bw.open(
        joinpath(
            path, "bigwig", string(head, ".merged.+.5end.bigWig")
            )
        )
    m = bw.open(
        joinpath(
            path, "bigwig", string(head, ".merged.-.5end.bigWig")
            )
        )
    for (i, line) in enumerate(union)
        name, seq = split(line, "\t")
        chr, pos = split(name, ":")
        startC, endC = parse.(Int, split(pos, "-"))
        signalP = np.nan_to_num(
            np.array(
            p.values(
                chr, startC, endC
                )
            ), 0
        )
        signalM = np.nan_to_num(
            np.array(
                m.values(
                    chr, startC, endC
                )
            ), 0
        )
        yProfile[:,1,1,i] = signalP
        yProfile[:,1,2,i] = signalM
        yCount[:,:,:,i] = sum(yProfile[:,:,:,i], dims=1)

    end
    println("head done")
    push!(y, yProfile, yCount)
end

yI = [ _ for _ in y]


N = 82646
splitN = Int(floor(N*0.5))


xTrn, xTst = x[:,:,:,1:splitN], x[:,:,:,Int(splitN+1):end];


yTrn = [y[i][:,:,:,1:splitN] for i in 1:28];
yTst = [y[i][:,:,:,Int(splitN+1):end] for i in 1:28];

dTrn = minibatch(xTrn, yTrn; batchsize=Int32(100));
dTst = minibatch(xTst, yTst; batchsize=Int32(100));



using HDF5

fid = h5open("data.hdf5", "w")

create_group(fid, "xRaw")
fid["xRaw"]["x"] = x;

create_group(fid, "yRaw")
for i in 1:28
    fid["yRaw"][string(i)] = yI[i]
end


create_group(fid, "minibatch")
fid["minibatch"]["dTrn"] = [dTrn]
fid["minibatch"]["dTst"] = [dTst]


################################################################################



##########################3

function minibatch(
    x, y; batchsize::Int32=100, shuffle::Bool=false, dtype::Type=Array{Float32})
    # Your code here
    etype = eltype(dtype)
    x = etype.(x)
    y = [etype.(yi) for yi in y]
    n = size(x)[end]
    Data(x,y, batchsize, shuffle, n, 1:n)
end


mutable struct Data
    x
    y
    batchsize::Int32
    shuffle::Bool
    n::Int32
    indices::Vector{Int32}
end

import Base: length, iterate, eltype, HasEltype

function length(d::Data)
    # Your code here
    Int(ceil(d.n / d.batchsize))
end



function iterate(d::Data, state=(0)) # here the start point of state is 0
    if state == 0 && d.shuffle
        d.indices = randperm(d.n)
    end

    if state >= d.n
        return nothing
    end
    i = state + 1 # here the beginning of the current slice
    j = state + d.batchsize # here the end of the current slice

    idx = d.indices[i:j]
    xbatch = d.x[:,:,:,i:j]
    ybatch = [y[:,:,:,i:j] for y in d.y]

    return ((xbatch, ybatch), j) # here it returns the batch and the next state of the iteration
end


################################################################################






function collectData(;path="/groups/lackgrp/ll_members/berkay/TermProjectComp541/ARsyntax/results")

    for (i, head) in enumerate(heads)
        p = bw.open(
            joinpath(
                path, "bigwig", string(head, ".merged.+.5end.bigWig")
                )
            )
        m = bw.open(
            joinpath(
                path, "bigwig", string(head, ".merged.-.5end.bigWig")
                )
            )

        for line in union
            name, seq = split(line, "\t")
            chr, pos = split(name, ":")
            startC, endC = parse.(Int, split(pos, "-"))
            signalP = np.nan_to_num(
                np.array(
                    p.values(
                        chr, startC, endC
                    )
                ), 0
            )
            signalM = np.nan_to_num(
                np.array(
                    m.values(
                        chr, startC, endC
                    )
                ), 0
            )
            push!(yP, signalP)
            push!(yM, signalM)
        end
        yH = cat(cat(yP...,dims=4),cat(yM...,dims=4),dims=3)
        push(y, yH, sum(yH, dims=1))
    end

end



################################################################################
p = BW.open(
    joinpath(
        path, "bigwig", string(heads[1], ".merged.+.5end.bigWig")
        )
    )
m = BW.open(
    joinpath(
        path, "bigwig", string(heads[1], ".merged.-.5end.bigWig")
        )
    )
    return (x, cat(cat(yP...,dims=4),cat(yM...,dims=4),dims=3))




function getSignal4head(head, p, m, path)
    yP = []
    yM = []
    x = []
    for line in readlines(joinpath(path, "fasta", string(head, ".fasta")))
        name, seq = split(line, "\t")
        push!(x, seqEncoder(seq))
        chr, pos = split(name, ":")
        startC, endC = parse.(Int, split(pos, "-"))
        signalP = np.nan_to_num(
            np.array(
                p.values(
                    chr, startC, endC
                )
            ), 0
        )
        signalM = np.nan_to_num(
            np.array(
                m.values(
                    chr, startC, endC
                )
            ), 0
        )
        push!(yP, signalP)
        push!(yM, signalM)
    end
    return (x, cat(cat(yP...,dims=4),cat(yM...,dims=4),dims=3))
end

x = cat(x..., dims=4)


getSignal(heads[1], p, m, path)


x, y = collectData()



for (root, dir, filesBW) in walkdir("/groups/lackgrp/ll_members/berkay/TermProjectComp541/ARsyntax/results/bigwig/")
    for fileBW in filesBW
        bw = BW.open(
            joinpath(root, fileBW)
            )
    getSignal4head.(bw)
end



    fileBW
    for line in readlines(joinpath(path, "fasta", string(head, ".fasta")))
        name, seq = split(line, "\t")
        push!(x, seqEncoder(seq))
        chr, pos = split(name, ":")
        startC, endC = parse.(Int, split(pos, "-"))
        signalP = np.nan_to_num(
            np.array(
                p.values(
                    chr, startC, endC
                )
            ), 0
        )



for seq in readlines(joinpath(path, "fasta", string(head, ".fasta")))
    for bw in bws
        p = bw.open(
            joinpath(
                path, "bigwig", string(head, ".merged.+.5end.bigWig")
                )
            )
        m = bw.open(
            joinpath(
                path, "bigwig", string(head, ".merged.-.5end.bigWig")
                )
            )


function collectHead(head, path, i)

    p = bw.open(
        joinpath(
            path, "bigwig", string(head, ".merged.+.5end.bigWig")
            )
        )
    m = bw.open(
        joinpath(
            path, "bigwig", string(head, ".merged.-.5end.bigWig")
            )
        )
    for line in readlines(joinpath(path, "fasta", string(head, ".fasta")))
        name, seq = split(line, "\t")
        push!(x, seqEncoder(seq))
        chr, pos = split(name, ":")
        startC, endC = parse.(Int, split(pos, "-"))
        signalP = np.nan_to_num(
            np.array(
                p.values(
                    chr, startC, endC
                )
            ), 0
        )
        signalM = np.nan_to_num(
            np.array(
                m.values(
                    chr, startC, endC
                )
            ), 0
        )
        push!(yP, signalP)
        push!(yM, signalM)
    end
    return (x, yP, yM)
end




x, yP, yM = collectHead("22RV1.AR-V7", "/groups/lackgrp/ll_members/berkay/TermProjectComp541/ARsyntax/results", 1)




function collectHead(head, path, i)
    yP = []
    yM = []
    x = []
    p = bw.open(
        joinpath(
            path, "bigwig", string(head, ".merged.+.5end.bigWig")
            )
        )
    m = bw.open(
        joinpath(
            path, "bigwig", string(head, ".merged.-.5end.bigWig")
            )
        )
    for line in readlines(joinpath(path, "fasta", string(head, ".fasta")))
        name, seq = split(line, "\t")
        push!(x, seqEncoder(seq))
        chr, pos = split(name, ":")
        startC, endC = parse.(Int, split(pos, "-"))
        signalP = np.nan_to_num(
            np.array(
                p.values(
                    chr, startC, endC
                )
            ), 0
        )
        signalM = np.nan_to_num(
            np.array(
                m.values(
                    chr, startC, endC
                )
            ), 0
        )
        push!(yP, signalP)
        push!(yM, signalM)
    end
    return (x = cat(x..., dims=4), cat(cat(yP...,dims=4),cat(yM...,dims=4),dims=3))
end




x, yP, yM = collectHead("22RV1.AR-V7", "/groups/lackgrp/ll_members/berkay/TermProjectComp541/ARsyntax/results", 1)




for (root, dirs, files) in walkdir("$path/fasta")
    for file in files
        println(, 1)
    end
end

for (root, dirs, files) in walkdir("$path/bigwig")
    for file in files
        println(joinpath(root, file), 1)
    end
end

end
f = open("/home/user/github/TermProjectCOMP541/fasta/LN95.AR-V7.fasta", "r")


for line in readlines(f)
    name, seq = split(line, "\t")
    push!(x, seqEncoder(seq))
    chr, pos = split(name, ":")
    startC, endC = parse.(Int, split(pos, "-"))
    signal = np.nan_to_num(
        np.array(
            ln95AR7m.values(
                chr, startC, endC
            )
        ), 0
    )
    push!(y, signal)
    return (x = cat(x..., dims=4), y = cat(y..., dims=4))
end
