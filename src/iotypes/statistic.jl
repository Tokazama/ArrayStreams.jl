#const StatP1{T} = Union{TDist{T},Chi{T},Chisq{T},Poisson{T}}
#const StatP2 = Union{FDist,Beta,Binomial,Gamma,Normal,NoncentralT,NoncentralChisq,Logistic,Uniform}
#const StatP3 = Union{NoncentralF,GeneralizedExtremeValue}
for D in (TDist,Chi,Chisq,Poisson,FDist,Beta,Binomial,Gamma,Normal,NoncentralT,
          NoncentralChisq,Logistic,Uniform,NoncentralF,GeneralizedExtremeValue)
    fn = fieldnames(D)
    L = length(fn)

    @eval begin
        extractstat(d::$D) = map(i->getfield(d,i), $fn)
        extractstat(A::AbstractArray{$D}) = extractstat.(A)
        statview(::Type{$D}, A::AbstractArray{T,N}) where {T,N} =
            mappedarray($D, extractstat, ntuple(i->A[expand2indices(A,(i,))...], $L)...)
        @inline function Base.read(io::IO, ::Type{$(D){T}}) where {T}
            elements = Ref{NTuple{$L,T}}()
            read!(io, elements)
            $D(elements[])
        end
        @inline Base.write(io::IO, d::$D) = write(io, Ref(extractstat(d)))
    end
end
