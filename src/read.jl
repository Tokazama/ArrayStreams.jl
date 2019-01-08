# TODO
# - applytransforms
# - updateproperties!
# - updateaxes!
function fixendian(A::AbstractArray, needswap::Bool)
    if needswap
        return mappedarray((ntoh, hton), A)
    else
        return A
    end
end

#########
# Array #
#########
# TODO: differentiate if struct is first dimensions for trait dispatch
Base.read(s::ArrayStream{S,T,N,I}; mmap::Bool=false) where {S,T,N,I} =
    read!(s, ImageMeta(AxisArray(Array{T,N}(undef,size(s)), axisparams(s)),  properties(s)))

function Base.read!(s::ArrayStream{S,T,N,I}, sink::Array{T,N}) where {S,T,N,I}
    seek(s, offset(s))
    fixendian(read!(stream(s), sink), needswap(s))
end

# Triangle
function Base.read!(s::ArrayStream{S,T,N,I}, sink::Array{Triangle}; kwargs...) where {S,T,N,I}
    seek(s, offset(s))
    perm = AxisArrays.permutation((:triangledim, setdiff(axisnames(s), :triangledim)...,), axisnames(s))
    return fill!(sink, triangleview(permutedims(read!(stream(s), Array{T,N}(undef, size(s))), perm)))
end
@inline function Base.read(io::IO, Triangle{T}) where {T}
    elements = Ref{NTuple{length(3),T}}()
    read!(io, elements)
    Triangle(elements[])
end
@inline function read!(io::IO, a::Triangle{T}) where {T}
    unsafe_read(io, Base.unsafe_convert(Ptr{T}, a), sizeof(a))
    a
end
Base.read!(s::ArrayStream{S,T,N,Tuple{Axis{:triangledim}, Axis}}, sink::Array{Triangle,N}; kwargs...) where {S,T,N} =
    read!(stream(s), sink)

# Quaternion
function Base.read!(s::ArrayStream{S,T,N,I}, sink::Array{Quat}; kwargs...) where {S,T,N,I}
    seek(s, offset(s))
    perm = AxisArrays.permutation((:quatdim, setdiff(axisnames(s), :quatdim)...,), axisnames(s))
    return fill!(sink, quatview(permutedims(read!(stream(s), Array{T,N}(undef, size(s))), perm)))
end
@inline function Base.read(io::IO, Quat{T}) where {T}
    elements = Ref{NTuple{length(4),T}}()
    read!(io, elements)
    Quat(elements[])
end
@inline function read!(io::IO, a::Quat{T}) where {T}
    unsafe_read(io, Base.unsafe_convert(Ptr{T}, a), sizeof(a))
    a
end
Base.read!(s::ArrayStream{S,T,N,Tuple{Axis{:quatdim}, Axis}}, sink::Array{Quat,N}; kwargs...) where {S,T,N} =
    read!(stream(s), sink)


# Point
function Base.read!(s::ArrayStream{S,T,N,I}, sink::Array{Point}; kwargs...) where {S,T,N,I}
    seek(s, offset(s))
    perm = AxisArrays.permutation((:pointdim, setdiff(axisnames(s), :pointdim)...,), axisnames(s))
    return fill!(sink, pointview(permutedims(read!(stream(s), Array{T,N}(undef, size(s))), perm)))
end
@inline function Base.read(io::IO, Point{T}) where {T}
    elements = Ref{NTuple{length(3),T}}()
    read!(io, elements)
    Triangle(elements[])
end
@inline function read!(io::IO, a::Point{T}) where {T}
    unsafe_read(io, Base.unsafe_convert(Ptr{T}, a), sizeof(a))
    a
end
Base.read!(s::ArrayStream{S,T,N,Tuple{Axis{:pointdim}, Axis}}, sink::Array{Point,N}; kwargs...) where {S,T,N} =
    read!(stream(s), sink)

# Matrix
function Base.read!(s::ArrayStream{S,T,N,I}, sink::Array{SMatrix}; kwargs...) where {S,T,N,I}
    seek(s, offset(s))
    perm = AxisArrays.permutation((:matdim1, :matdim2, setdiff(axisnames(s), (:matdim1,:matdim2))...,), axisnames(s))
    return fill!(sink, matview(permutedims(read!(stream(s), Array{T,N}(undef, size(s))), perm)))
end

# Vector
function Base.read!(s::ArrayStream{S,T,N,I}, sink::Array{SVector}; kwargs...) where {S,T,N,I}
    seek(s, offset(s))
    perm = AxisArrays.permutation((:vecdim, setdiff(axisnames(s), :vecdim)...,), axisnames(s))
    return fill!(sink, vecview(permutedims(read!(stream(s), Array{T,N}(undef, size(s))), perm)))
end

# Distribution
function Base.read!(s::ArrayStream{S,Tr,N,I}, sink::AbstractArray{Ts}) where {S,Tr,Ts<:Distribution,N,I}
    seek(s, offset(s))
    perm = AxisArrays.permutation((:statdim, setdiff(axisnames(s), :statdim)...,), axisnames(s))
    return fill!(sink, statview(permutedims(read!(stream(s), Array{T,N}(undef, size(s))), perm)))
end

#############
# ImageMeta #
#############
function Base.read!(s::ArrayStream, sink::A; kwargs...) where {A<:ImageMeta}
    read!(s, getfield(sink, :data); kwargs...)
    updateproperties!(s, sink)
    return sink
end

function updateproperties!()
end

#############
# AxisArray #
#############
function Base.read!(s::ArrayStream, sink::A; kwargs...) where {A<:AxisArray}
    read!(s, getfield(sink, :data); kwargs...)
    updateaxes!(s, sink)
end

function updateaxes!(s, sink)
end

function Base.read!(s::ChunkedStream, sink::A; kwargs...) where {A<:AbstractArray}
    read!(s, getfield(sink, :data); kwargs...)
    iterate(s)
    return ret
end
