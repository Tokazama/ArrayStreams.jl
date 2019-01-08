module ArrayStreams

using ImageMetadata
using GeometryTypes: Triangle, Point
using Rotations: Quat

abstract type AbstractArrayStream{S,T,N,I} end

Base.size(s::AbstractArrayStream{S,T,N}) where {S,T,N} = (S.parameters...,)
Base.size(s::AbstractArrayStream{S,T,N}, i::Int) where {S,T,N} = S.parameters[i]
Base.ndims(s::AbstractArrayStream{S,T,N}) where {S,T,N} = N
Base.length(s::AbstractArrayStream{S,T,N}) where {S,T,N} = prod(S.parameters)
Base.eltype(s::AbstractArrayStream{S,T,N}) where {S,T,N} = T

"""
julia> io = IOBuffer();

julia> write(io, [1:10...])
80

julia> seek(io, 0)
IOBuffer(data=UInt8[...], readable=true, writable=true, seekable=true, append=false, size=80, maxsize=Inf, ptr=1, mark=-1)

julia> as = ArrayStream{Tuple{2,5},Int,2}(io,0:80,true,false)
"""
mutable struct ArrayStream{S,T,N,Ax} <: AbstractArrayStream{S,T,N,I}
    s::IO
    axes::Ax
    offset::Int
    ownstream::Bool
    needswap::Bool
    properties::Dict{String,Any}
end

"""
    ArrayStream(A::AbstractArray; kwargs...)

`kwargs` is passed to IOBuffer within the function.
"""
function ArrayStream(A::AbstractArray{T,N}; kwargs...)
    ind = to_indices(A, axes(A))
    ArrayStream{Tuple{size(A)...},T,N,typeof(ind)}(IOBuffer([A...]; kwargs...),ind,0, true)
end

ownstream(s::ArrayStream) = s.ownstream
offset(s::ArrayStream) = s.offset
needswap(s::ArrayStream) = s.needswap

Base.seek(s::ArrayStream, n::Integer) = seek(stream(s), n)
Base.position(s::ArrayStream) = position(stream(s))
Base.skip(s::ArrayStream, n::Integer) = skip(stream(s), n)
Base.close(s::ArrayStream) = close(stream(s))
Base.eof(s::ArrayStream) = eof(stream(s))
Base.isopen(s::ArrayStream) = isopen(stream(s))

ImageMetadata.properties(s::ArrayStream) = s.properties

mutable struct ChunkedStream{S,T,N,Ax} <: AbstractArrayStream{S,T,N,I}
    s::AbstractVector{<:ArrayStream}
    axes::Ax
    nitr::Int
    itr::Int
    properties::Dict{String,Any}
end

stream(s::ChunkedStream) = s[s.itr]

include("structview.jl")
include("indexing.jl")
include("read.jl")
include("write.jl")

end
