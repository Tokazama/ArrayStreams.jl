"""
IteratorStyle

Construction and reading of a ChunkedStream is facilitated by the IteratorStyle.
* DefinedIterator: assumes all iterators are defined at construction
* ConstructOnIterator: assumes that each chunk is defined upon iteration which
    entails appending the `chunks` field with the

If ConstructOnIterator is specified then the user must define an iterator function
that constructs subsequent iterations (i.e., appends the `chunks` field with each
subsequent `ImageStream`.
"""
abstract type IteratorStyle end
struct DefinedIterator <: IteratorStyle end  # all iterators are defined before streaming begins
struct ConstructOnIterator <: IteratorStyle end  # iteration leads to construction of next ImageStream

mutable struct ChunkedStream{S,T,N,I} <: AbstractArrayStream{S,T,N,I}
    chunks::AbstractVector{<:ArrayStream}
    nitr::Int
    itr::Int
end

getchunk(s::ChunkedStream) = s.chunks[s.itr]
stream(s::ChunkedStream) = stream(getchunk(s))
streamindices(s::ChunkedStream) = streamindices(getchunk(s))
needswap(s::ChunkedStream) = needswap(getchunk(s))
ownstream(s::ChunkedStream) = ownstream(getchunk(s))

function chunk(s::ImageStream{S,T,N,Ax}, dim::Int) where {S,T,N,Ax}
    ncolon = ntuple(i->Colon(), dim-1)
    chunk_indices = CartesianIndices(map(i->length(axes(s,i)), dim:N))
    ChunkedStream([s[ncolon..., i.I...] for i in chunk_indices], length(chunk_indices), 1)
end

########
# Read #
########
function Base.read!(s::ChunkedStream, sink::A; kwargs...) where {A<:AbstractArray}
    read!(getchunk(s), A)
    iterate(s)
end

function Base.read(s::ChunkedStream)
    ret = read(getchunk(s))
    iterate(s)
    return ret
end

#########
# Write #
#########
Base.write(s::ChunkedStream, sink::A) where {A<:AbstractArray} = write(getchunk(s), sink)

