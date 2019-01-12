abstract type AbstractArrayStream{S,T,N,I} <: AbstractArray{T,N} end

Base.size(s::AbstractArrayStream{S,T,N}) where {S,T,N} = (S.parameters...,)
Base.size(s::AbstractArrayStream{S,T,N}, i::Int) where {S,T,N} = S.parameters[i]
Base.ndims(s::AbstractArrayStream{S,T,N}) where {S,T,N} = N
Base.length(s::AbstractArrayStream{S,T,N}) where {S,T,N} = prod(S.parameters)
Base.eltype(s::AbstractArrayStream{S,T,N}) where {S,T,N} = T

Base.IndexStyle(::Type{AbstractArrayStream}) = IndexLinear

stream(s::AbstractArrayStream) = error("stream is not defined for $(typeof(s))")
ownstream(s::AbstractArrayStream) = getfield(s, :ownstream)
streamindices(s::AbstractArrayStream) = getfield(s, :streamindices)
needswap(s::AbstractArrayStream) = getfield(s :needswap)\w

Base.firstindex(s::AbstractArrayStream) = streamindices(s)[1]
Base.lastindex(s::AbstractArrayStream) = streamindices(s)[end]

Base.getindex(s::AbstractArrayStream{S,T,N,IndexLinear}, i::Int) where {S,T,N} =
    ArrayStreams(stream(s), streamindices(s)[i], ownstream(s), needswap(s))

function Base.getindex(s::AbstractArrayStream{S,T,N,L}, I::Vararg{Int, N}) where {S,T,N,L}
    si = s.streamindices[LinearIndices(size(s))[I...]]
    ArrayStreams{Tuple{1},T,1,1}(stream(s), s.streamindices[LinearIndices(size(s))[I...]], ownstream(s), needswap(s))
end

# leverage SubArrays which determine whether fast indexing is possible
function Base.getindex(s::AbstractArrayStream{S,T,N,IndexLinear}, I...) where {S,T,N}
    li = view(LinearIndices(s), I...)
    # fast linear indexing, so just need first and last
    if typeof(li).parameters[5]
        ArrayStream{Tuple{size(li)...},T,ndims(li)}(stream(s), streamindices(s)[first(li):last(li)], ownstream(s), needswap(s))
    else
        ArrayStream{Tuple{size(li)...},T,ndims(li)}(stream(s), streamindices(s)[li...], ownstream(s), needswap(s))
    end
end

Base.setindex!(s::AbstractArrayStream, I) = error("setindex is not defined for $(typeof(s)). Use write to change stream content.")

function Base.show(io::IO, s::AbstractArrayStream)
    println(summary(s))
    println("ownstream: ", ownstream(s))
    println("needswap: ", needswap(s))
    println("streamindices: \n", streamindices(s))
end


