

BPnet model architecture:

Architecture:
  arch.jl => Parts of network "Body", "Head", "Chain"
  data.jl => Data type iteration, and sequence encoding to one-hot
  layers.jl => Layers of network.
    (1D convolution, dilated convolutions, deconvolution, dense)
  loss.jl => Loss functions for different heads (multinomial_nll, mse)
  model.jl => Main script where model initiation runs. 
