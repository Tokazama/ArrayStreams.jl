function write(s::ArrayStream{S,T,N,I}, A::AbstractArray{Triangle}) where {S,T,N,I}
    av = mappedview(extracttriangle, Triangle, A)
    write(s, PermutedDimsArray(av, AxisArrays.permutation(axisnames(s), axisnames(av))))
end

function write(A::AbstractArray{Quat{T}}, s::ArrayStream{S,T,N,I}) where {T}
    av = mappedview(extractquat, Quat, A)
    write(s, PermutedDimsArray(av, AxisArrays.permutation(axisnames(s), axisnames(av))))
end

function write(A::AbstractArray{Point}, s::ArrayStream{S,T,N,I}) where {T}
    av = mappedview(extracttriangle, Point, A)
    write(s, PermutedDimsArray(av, AxisArrays.permutation(axisnames(s), axisnames(av))))
end

function write(A::AbstractArray{Point}, s::ArrayStream{S,T,N,I}) where {T}
    n = size()
    av = mappedview(x->[x...], A)
    write(s, PermutedDimsArray(av, AxisArrays.permutation(axisnames(s), axisnames(av))))
end

