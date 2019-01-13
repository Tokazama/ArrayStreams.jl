module ArrayStreams

using ImageMetadata, ImageCore, StaticArrays, Distributions, ColorTypes
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
BitTypes = Union{Integer,AbstractFloat}

include("iotypes/iotypes.jl")
include("abstractarraystream.jl")
include("arraystream.jl")
include("imagemeta.jl")
include("axisarray.jl")

# TODO
# - write IOBuffer (i.e. write(s) where there's not Array parameters but buffer contains
# - documentation
#   - write should be explained in the context of sinks because ArrayStream acts as the sink in this case
# - check extractquat for proper output shape
#   - Distributions, Quat, SArray
# - iterators for chunkedstream
# - constructors for chunkedstream
# - Impliment Colors
# - append! operations (maybe, as ArrayStreams are more like StaticArrays)

end
