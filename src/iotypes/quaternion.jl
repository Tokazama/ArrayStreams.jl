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
# although Quat is a StaticArray subtype, it acts as length == 3, but takes 4 arguments
# so this has to be defined separately
@inline function Base.read(io::IO, ::Type{Quat{T}}) where {T}
    elements = Ref{NTuple{4,T}}()
    read!(io, elements)
    Quat(elements[])
end

@inline write(io::IO, q::Quat{T}) where {T} = write(io, Ref(a.data))

