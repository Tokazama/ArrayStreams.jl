module ArrayStreams

using ImageMetadata
import AxisArrays
using AxisArrays: AxisArray, axisnames, permutation
using GeometryTypes: Triangle, Point
using Rotations: Quat

export AbstractArrayStream, ArrayStream, stream

function fixendian(A::AbstractArray, needswap::Bool)
    if needswap
        return mappedarray((ntoh, hton), A)
    else
        return A
    end
end

expand2indices(A::AbstractArray{T,NA}, idx::Tuple{Vararg{<:Any,NI}}) where {T,NA,NI} =
    to_indices(A,(idx..., ntuple(i->Colon(), NA-NI)...))
expand2indices(A::AbstractArray{T,N}, idx::Tuple{Vararg{<:Any,N}}) where {T,N} =
    to_indices(A,idx)

include("iotypes/iotypes.jl")
incldue("abstractarraystream.jl")
incldue("arraystream.jl")

# TODO: would it be better to use AbstractArrayStream here?
const AxisStream{S,T,N,I,Ax} = AxisArray{T,N,ArrayStream{S,T,N,I},Ax}
const MetaStream{S,T,N,I} = ImageMeta{T,N,ArrayStream{S,T,N,I}}
const MetaAxisStream{S,T,N,I,Ax} = ImageMeta{T,N,AxisStream{S,T,N,I,Ax}}
const MetaAxis{T,N,D,Ax} = ImageMeta{T,N,AxisArray{T,N,D,Ax}}
const AbstractMetaStream{S,T,N,I} = Union{MetaStream{S,T,N,I},MetaAxisStream{S,T,N,I,Ax}} where {Ax}
const AbstractStreamContainer = Union{AbstractMetaStream, AxisStream}

BitTypes = Union{Integer,AbstractFloat}


include("imagemeta.jl")
include("axisarray.jl")

# TODO
# - iterators for chunkedstream
# - constructors for chunkedstream
# - colortypes readers
# - distribution read/write

end
