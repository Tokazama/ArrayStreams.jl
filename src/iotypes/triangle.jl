extracttriangle(a::Triangle) = (a.data...,)
function triangleview(::Type{Triangle}, A::AbstractArray)
    if size(img, 1) != 3
        @error "Selected dimension, $i, must be of size 3"
    else
        return mappedarray(Triangle, extracttriangle,
                           A[expand2indices(A,(1,))...],
                           A[expand2indices(A,(2,))...],
                           A[expand2indices(A,(3,))...])
    end
end
