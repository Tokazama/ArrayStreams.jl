function matview(A::AbstractArray{T,N}) where {T,N}
    n = size(A,1)
    m = size(A,2)
    L = n*m
    reinterpret(SArray{Tuple{n,m},T,2,L}, reshape(A, (L, map(i->size(A,i),3:N)...,)))
end

extractmat(A::AbstractArray{SMatrix{N,M,T}}) where {N,M,T} =
    reshape(reinterpret(T, A), (N,M, size(A)...,))

# Array of Vectors
vecview(A::AbstractArray{T,N}) where {T,N} =
    reinterpret(SVector{size(A,1),T},A)
extractvec(A::AbstractArray{SVector{L,T}}) where {L,T} =
    reshape(reinterpret(T, A), (L, size(A)...,))
