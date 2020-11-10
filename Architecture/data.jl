


seq = "GGCAGTCCGAGCTGGGCCTGGGAGGGTGGGCAGGGCCGCCACAGGCCTCTGGGCTGGGGGCTGGGGCTGAGCCTTGCTGAGGGAGCACAGGTACAGCCACACCATAGGCCTGGCTGGAGGGGCCACCTCAGGCCAGTGAGGCCATCAGATGCTACCTGGGGAGGCTACCTGGGCACTGCAGGGGGGGGTGGATGGGCCCCCCAACTCCGCCCCACTACTGACTCCGCCAGGTCCCTTCCCCAACTGGAAGCTCAGCCCCTCCACCAAGCCAGCCCCTTTCACACAAGGATACACAAGGATGTGCACCTACGGTAAACAAAGGGCTATTTTTATAGCCTCATTGTTTCCTCTGGCAGCTTCCTAACTCCCCAGCCAAGGTACACCTCAGTCCTCCCTCCGGGCACACTGCAGACCTCCAGCTCTGCAGGCTCTGCAGGCTCCGCCCTGCCAGGTGCTGGCAGCTCGGGACTCCACCACCCCTCAGGGGCTGCGCAGAGGAGGCCAGGGCCTAGGGTGCAGCCAGGGCCCAAGGTGAGGAGCTGTGGCCTCTTCCTGTTCTGCAGATGGAGGCCTGAGGCTGGGAAGCGGCACTGAGGGGTCACGGGGCATCACCCACTGCCATGGGGGCATCTCTCAGCTGGGCCCACCTAGACCTATGTCCTGAGTCAGCAGCCTGGCCTCTTGCCCAAAGATGTCAAG"



function seqEncoder(seq)
    seqEncode = Dict(
        'A' => Float32[1,0,0,0],
        'T' => Float32[0,1,0,0],
        'G' => Float32[0,0,1,0],
        'C' => Float32[0,0,0,1],
        )
    encode = seqEncode[first(seq)]'
    for base in  seq[2:end]
        encode = vcat(encode, seqEncode[base]')
    end
    # encode = vcat(encode,zeros(21, length(seq)))
    return reshape(encode, size(encode)..., 1,1)
end



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
