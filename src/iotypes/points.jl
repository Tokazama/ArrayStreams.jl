extractpoint(a::Point) = (a.data...,)
function pointview(::Type{Point}, A::AbstractArray)
    @assert size(A,1) == 3 "First dimension must be of size 3."
    mappedarray(Point, extractpoint,
                A[expand2indices(A,(1,))...],
                A[expand2indices(A,(2,))...],
                A[expand2indices(A,(3,))...])
end
