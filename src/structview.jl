drop1dims(A::AbstractArray) = dropdims(a, dims = tuple(findall(size(a) .== 1)...))


expand2indices(A::AbstractArray{T,NA}, idx::Tuple{Vararg{<:Any,NI}}) where {T,NA,NI} =
    to_indices(A,(idx..., ntuple(i->Colon(), NA-NI)...))

expand2indices(A::AbstractArray{T,N}, idx::Tuple{Vararg{<:Any,N}}) where {T,N} =
    to_indices(A,idx)

extractview(T::Type, A::AbstractArray{T}) where {T} = A

function streamto!(s::ArrayStream{S,Tr,N,I}, sink::AbstractArray{Ts,N}; mmap::Bool=false) where {S,Tr,Ts<:Union{Color3,ColorAlpha},N,I}
    perm = AxisArrays.permutation((:colordim, setdiff(axisnames(s), :colordim)...,), axisnames(s))
    return drop1dims(colorview(Ts,PermutedDimsArray(read!(s; mmap=mmap), perm)))
end


# fall back if sink type and stream type are same
structview(T::Type, A::AbstractArray{T}) where {T} = drop1dims(s, A)

# Array of Triangles
extracttriangle(a::Triangle) = (a.data...,)
function triangleview(::Type{Triangle}, A::AbstractArray)
    if size(img, 1) != 3
        @error "Selected dimension, $i, must be of size 3"
    else
        return mappedarray(Quat, extracttriangle,
                           A[expand2indices(A,(1,))...],
                           A[expand2indices(A,(2,))...],
                           A[expand2indices(A,(3,))...])
    end
end

# Array of Quaternions
extractquat(a::Quat) = (a.w, a.x, a.y, a.z)
function quatview(A::AbstractArray)
    if size(img, 1) != 4
        @error "Selected dimension, $i, must be of size 4"
    else
        return mappedarray(Quat, extractquat,
                           A[expand2indices(A,(1,))...],
                           A[expand2indices(A,(2,))...],
                           A[expand2indices(A,(3,))...],
                           A[expand2indices(A,(4,))...])
    end
end

# Array of Points
extractpoint(a::Point) = (a.data...,)
function pointview(::Type{Point}, A::AbstractArray)
    @assert size(A,1) == 3 "First dimension must be of size 3."
    mappedarray(Point, extractpoint,
                A[expand2indices(A,(1,))...],
                A[expand2indices(A,(2,))...],
                A[expand2indices(A,(3,))...])
end

# Array of Matrices
function matview(A::AbstractArray{T,N}) where {T,N}
    n = size(A,1)
    m = size(A,2)
    L = n*m
    tmpsize = (L, map(i->size(A,i),3:N)...,)
    drop1dims(reinterpret(SArray{Tuple{n,m},T,2,L}, reshape(A,(tmpsize))))
end

# Array of Vectors
function vecview(A::AbstractArray{T,N}) where {T,N}
    drop1dims(reinterpret(SVector{size(A,1),T},A))
end

extractvec(s::SVector) = [s.data...]

"""
# Array of Statistics
"""
const StatP1 = Union{TDist,Chi,Chisq,Poisson}
const StatP2 = Union{FDist,Beta,Binomial,Gamma,Normal,NoncentralT,NoncentralChisq,Logistic,Uniform}
const StatP3 = Union{NoncentralF,GeneralizedExtremeValue}
extractstat(d::D) where {D<:Distribution} = values(map(i->getfield(d,i), fieldnames(D)))
statview(::Type{D}, extractstat, A::AbstractArray) where {D<:StatP1} = mappedarray(D, A)
function statview(::Type{D}, A::AbstractArray) where {D<:StatP2}
    mappedarray(D, extractstat,
                A[expand2indices(A,(1,))...],
                A[expand2indices(A,(2,))...])
end
function statview(::Type{D}, A::AbstractArray) where {D<:StatP3}
    mappedarray(D, extractstat,
                A[expand2indices(A,(1,))...],
                A[expand2indices(A,(2,))...],
                A[expand2indices(A,(3,))...])
end
