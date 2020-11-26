

mutable struct Conv
    w
    b
    f
    pDrop
    padding
    dilation
    nParameters
end



(c::Conv)(x) =
    c.f.(
        conv4(
            c.w,
            dropout(x, c.pDrop),
            padding=c.padding,
            dilation=c.dilation
        ) .+ c.b
    )



Conv(w1::Int, w2::Int, cx::Int, cy::Int;
    f=
        relu,
    pDrop=
        0,
    padding=
        0,
    dilation=
        1,
    xType=
        Array{Float32},
    scale=
        0.01
    ) = Conv(
            Param(xType(rand(w1,w2,cx,cy)) .* eltype(xType)(scale), Adam()),
            Param(xType(zeros(1,1,cy,1)), Adam()),
            f,
            pDrop,
            padding,
            dilation,
            (w1*w2*cx +1)*cy
        )

################################################################################
struct Pool
    wSize
    nParameters
end

(p::Pool)(x) = pool(x; window=p.wSize)
Pool(x) = Pool(x, 0)
################################################################################
mutable struct BatchNorm
    moments
    params
    nParameters
end

(b::BatchNorm)(x) = batchnorm(x, b.moments, b.params)

BatchNorm(C) = BatchNorm(bnmoments(), arrayType(bnparams(C)), 0)

################################################################################

struct Dense
    w
    b
    f
    pDrop
    window
    nParameters
end

Dense(i,o;
    f=
        identity,
    window=
        1,
    xType=
        Array{Float32},
    scale=
        0.01,
    pDrop=
        0
    ) =
        Dense(
            Param(xType(rand(o,i)) .* eltype(xType)(scale), Adam()),
            Param(xType(zeros(o)), Adam()),
            f,
            pDrop,
            window,
            (i+1)*o
        )

(d::Dense)(x) =
    d.f.(
        d.w *
            mat(
                dropout(x, d.pDrop),
            ) .+ d.b
        )


################################################################################


# Define a deconvolution layer:

struct DeConv
    w
    b
    padding
    nParameters
end


DeConv(w1::Int, w2::Int, cx::Int, cy::Int;
    padding=
        0,
    xType=
        Array{Float32},
    scale=
        0.01
    ) = DeConv(
            Param(xType(rand(w1,w2,cx,cy)) .* eltype(xType)(scale), Adam()),
            Param(xType(zeros(1,1,cy,1)), Adam()),
            padding,
            (w1*w2*cx)*cy
        )



(dC::DeConv)(x) =
    deconv4(
        dC.w,
        x,
        padding=dC.padding
    ) .+ b
################################################################################
