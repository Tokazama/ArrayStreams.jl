Base.axes(s::ArrayStream{S,T,N,Tuple{Base.OneTo}}) where {S,T,N} = s.axes
Base.axes(s::ArrayStream{S,T,N,Tuple{Axis}}) where {S,T,N} = map(values, s.axes)
Base.axes(s::ArrayStream, i::Int) = axes(s)[i]

Base.to_index(s::ArrayStream, ind, i::Int) = i
Base.to_index(s::ArrayStream, ind, i::Colon) = ind
Base.to_index(s::ArrayStream, ind, i::AbstractVector) = i

Base.to_indices(s::ArrayStream, I::Tuple) = (@_inline_meta; to_indices(s, axes(s), I))
Base.to_indices(s::ArrayStream, ind::Tuple{Vararg{Any,1}}, I::Tuple{Vararg{Any,1}}) =
    (@_inline_meta, _to_index(s, first(ind), first(I)))
Base.to_indices(s::ArrayStream, ind::Tuple{Vararg{Any,N}}, I::Tuple{Vararg{Any,N}}) =
    (@_inline_meta, _to_index(s, first(ind), first(I)), to_indices(s, Base.tail(ind), Base.tail(I))...,)

function idx2offset(s::AbstractArrayStream{S,T,N}, I::Tuple{Vararg{Any,N}}) where {S,T,N}
    stride = 1
    ind = 0
    for i ∈ 1:N
        if i == 1
            ind = I[1]
        else
            ind = ind + stride * (I[i] - 1)
        end
        stride *= S.parameters[i]
    end
    return ind + offset(s)
end

ind2size(s::ArrayStream{S,T,N}, ind::Tuple{Vararg{Any,N}}) where {S,T,N} = map(length, ind)

tuple_first(ind::Tuple{Vararg{Any,1}}) = ind[1]
tuple_first(ind::Tuple{Vararg{Any,N}}) where {N} = (ind[1], tuple_first(ind))

function Base.getindex(s::ArrayStream{S,T,N}, I::Vararg{Any,N}) where {S,T,N}
    ind = to_indices(s, I)
    sz = ind2size(s, ind)
    sind = range(idx2offset(s, tuple_first(I)), length=prod(sz)*sizeof(T))
    S{Tuple{sz...},T,length(sz)}(copy(stream(s)), # TODO: copy doesn't work for all IO subtypes
                                 sind, true, needswap(s))
end

function Base.view(s::ArrayStream{S,T,N}, I::Vararg{Any,N}) where {S,T,N}
    ind = to_indices(s, I)
    sz = ind2size(s, ind)
    sind = range(idx2offset(s, tuple_first(I)), length=prod(sz)*sizeof(T))

    S{Tuple{sz...},T,length(sz)}(stream(s), sind, true, needswap(s))
end


Base.setindex!(a::AbstractArrayStream, value, i::Int) = error("setindex!(::$(typeof(a)), value, ::Int) is not defined.")

# TODO
Base.checkbounds(s::AbstractArrayStream, I...)

