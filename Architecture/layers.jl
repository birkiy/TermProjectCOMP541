



# Define convolution layer:

struct Conv
    w
    b
    f
    pDrop
    padding
    dilation
end

(c::Conv)(x) =
    c.f.(
        conv4(
            c.w,
            dropout(x, c.pDrop),
            padding=c.padding,
            dilation=c.dilation
        )
    )



Conv(w1::Int, w2::Int, cx::Int, cy::Int, f=relu;
    pDrop=
        0,
    padding=
        0,
    dilation=
        1,
    dType=
        Float32,
    scale=
        0.01
    ) = Conv(
            Param(rand(dType, w1,w2,cx,cy) .* dType(scale), Adam()),
            Param(zeros(dType, 1,1,cy,1), Adam()),
            f,
            pDrop,
            padding,
            dilation
        )
#########################


# Define a deconvolution layer:

struct DeConv
    w
    b
    padding
end


DeConv(w1::Int, w2::Int, cx::Int, cy::Int;
    padding=
        0,
    dType=
        Float32,
    scale=
        0.01
    ) = DeConv(
            Param(rand(dType, w1,w2,cx,cy) .* dType(scale), Adam()),
            Param(zeros(dType, 1,1,cy,1), Adam()),
            padding
        )



(dC::DeConv)(x) =
    deconv4(
        dC.w,
        x,
        padding=dC.padding
    )


#######################


# Define dense layer:

struct Dense
    w
    b
    f
    window
end

Dense(i,o;
    f=
        identity,
    window=
        1,
    dType=
        Float32,
    scale=
        0.01
    ) =
        Dense(
            Param(rand(dType, o,i) .* dType(scale), Adam()),
            Param(zeros(dType, o), Adam()),
            f,
            window
        )

(d::Dense)(x) =
    d.f.(
        d.w *
            mat(
                pool(x; window=d.window)
            ) .+ d.b
        )
