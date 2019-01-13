ArrayStream.jl

This is an attempt to make a more convenient way to read/write Arrays in Julia.
My initial focus is on images but if this is found to be useful to others it
could proabably be adapted to any sort of array structure in Julia.

ArrayStreams.jl is not a registered package. If there is enough interest in this
project I'd be happy to register it. If there's another infrastructure out there
that's just better but could benefit from this sort of functionality I'd also be
willing to assist in porting this sort of functionality elsewhere.

# Usage

The main workhorse of this package is `ArrayStream`. It is a subtype of `AbstractArrayStream`
which is an AbstractArray. An `ArrayStream` gains most of it's utility by
containing an `IO` field that has some fairly basic indexing behavior being wrapped
by other types that require an AbstractArray (especially AxisArrays). This results
in several key contributions beyond just convenient syntax (almost identical to
base).

* Reading to a sink. This is similar to `Base.read!`, but allows `AxisArray` and
  `ImageMeta` to be overwritten.
* Axis based interpolation of how to read struct elements. If you're familiar
  with Images.jl you may be aware of the `colorview` function and Axis traits
  that can detect which dimension is responsible for color. Leveraging AxisArrays
  allows reading in arrays where the desired sink eltype is a struct but this isn't
  containing in the stream elementwise but represented as one of the dimensions
  (e.g., the last dimension of a Float32 array represents each channel of an RGB
  struct). More on this below.
* Data may be read and written in chunks.

# Basics

If an `ArrayStream` is  constructed from an Array, an `IOBuffer` will be created
that contains the contents of the arrays.

```julia
A = rand(3,4)
s = ArrayStream(A)
```

Once an `ArrayStream` is constructed it contains all the necessary information to
construct an array from the underlying `IO`.
```julia
A2 = read(s)
```

An `ArrayStream` may also be treated similarly to any `IO` object.
```julia
position(s)
eof(s)
isopen(s)
seek(s, 0)
```

An `ArrayStream` also has the ability to read to a sink.
```julia
B = rand(3,4)
read!(s, B)
B == A
```

# Sinks
TODO

```julia
io = IOBuffer()
s = ArrayStream{Tuple{2,5},Int,2}(io,0:80,true,false)
write(s, rand(2,5))
```

# ChunkedStream
TODO


