


function tensormult4!(X, A, Y, T, dim)
    @assert size(X, dim) == size(A, 2)
    Tmax = last(CartesianIndices(T))
    m, n = size(A)
    @simd for k in 1:n
        fill!(T, zero(eltype(T)))
        @simd for I in CartesianIndices(X)
            @inbounds T[min(Tmax, I)] += A[k, I[dim]] * X[I]
        end
        @simd for I in CartesianIndices(Y)
            if I[dim] == k  # remove this?
                @inbounds Y[I] = T[min(Tmax, I)]
            end
        end
    end
    return Y
end




x = rand(1000, 4, 1, 100)
p = rand(100, 100)
w = rand(25, 4, 1, 64)
y = similar(x)
t = sum(x, dims=4)

tensormult4!(x, p, y, t, 4)






x = rand(Float32, (699,4,1,100));
y1 = rand(Float32, (699,1,2,100));
y2 = rand(Float32, (1,1,2, 100));

y = [y1,y2,y1,y2];


data = minibatch(x, y; batchsize=Int32(10));

c = bpnet
for (i, (x, y)) in enumerate(data)
    print(summary.((x,y)))
    println("epoch start")
    J = @diff c(c.body(x), y)
    print(params(J) |> collect)
    for p in params(J)
        println("parameter sum before:",sum(p))
        ∇p = grad(J, p)
        update!(p, ∇p)
        println("parameter sum after:",sum(p))
    end
    println("epoch end")
    println()
end


c(c.body(x), y)

c.bottleneck = c.body(x)
(c::Chain)(x, y) = sum([
    h.lossF(h(c.bottleneck), yi)
    for (h, yi) in zip(c.heads, y)
])

J = @diff c(nothing, y)
params(J) |> collect



##############################




for (h,yn) in zip(bpnet.heads, y)
    J = h.lossF(h(bpnet.body(x)), yn)
    println(J)
end

#############################333


c = bpnet



J = [Float32(0.0) for n in 1:c.n]

for (j, (x, y)) in enumerate(dTst)
    println("epoch start")
    for (hIdx, (h, yi)) in enumerate(zip(c.heads, y))
        J[hIdx] += h.lossF(h(c.body(x)), yi)
    end
end
