

function aproxLogFact(n)
    """
    Approximation for log n!
    """
    Float32(n * log(n) - n  + log(n * (1 + 4n * (1 + 2n)))/6 + log(π)/2)
end


function multinomial_nll(ypred, ytrue)
    pV = ypred ./ sum(ypred, dims=1)
    logPV = log.(pV)
    pS = sum(logPV .* ytrue, dims=1)
    n = sum(ytrue, dims=1)
    nS = (aproxLogFact.(n) .- sum(aproxLogFact.(ytrue), dims=1))
    logP = pS .+ nS
    loss = sum(logP) / prod(size(logP))
end

function mse(ypred, ytrue)
    λ = Float32(0.5) * sum(ypred) / size(ypred, 1)
    C = λ * abs2.(log.(1 .+ sum(ypred)) .- log.(1 .+ ytrue)) ./ size(ypred, 1)
    sum(C) / prod(size(C))
end
