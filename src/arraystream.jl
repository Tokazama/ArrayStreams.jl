struct ArrayStream{S,T,N,I<:Union{AbstractRange,Int,Vector}} #<: AbstractArrayStream{T,N}
    s::IO
    streamindices::I
    ownstream::Bool
    needswap::Bool
end

# TODO: maybe use Base.unsafe_wrap here
ArrayStream{S,T,N}(io::IO, streamindices::I, ownstream::Bool=true, needswap::Bool=false) where {S,T,N,I<:Union{AbstractRange,Int,Vector}} =
    ArrayStream{S,T,N,I}(io, streamindices, ownstream, needswap)

function ArrayStream(A::AbstractArray{T,N}, needswap::Bool=false) where {T,N}
    io = IOBuffer()
    write(io, A)
    seek(io, 0)
    ArrayStream{Tuple{size(A)...},T,N}(io, range(position(io), step=sizeof(T), length=length(A)), 0, true, needswap)
end

function UpdatType(ArrayStream{S,Told,N}, ::Type{Tnew}) where {S,Told,N,Tnew}
    ArrayStream{S,Tnew,N}(stream(s),range(firstindex(s),step=sizeof(Tnew),stop=lastindex(s)),ownstream(s),needswap(s))
end

########
# Read #
########
function Base.read!(s::ArrayStream{S,T,N,AbstractRange}, sink::Array{T,N}) where {S,T,N}
    seek(s, firstindex(s))
    fixendian(read!(stream(s), sink), needswap(s))
end
Base.read(s::ArrayStream{S,T,N}) where {S,T,N} = read!(s, Array{T,N}(undef, size(s)))

# This is really slow
function Base.read!(s::ArrayStream{S,Tr,N,Vector{Int}}, sink::Array{Ts,N}) where {S,Tr<:BitTypes,Ts<:BitTypes,N}
    for i in 1:length(s)
        seek(s, streamindices(s)[i])
        sink[i] = read(stream(s), T)
    end
    return sink
end

# this needs testing but may be better
function Base.read!(s::ArrayStream{S,Tr,N,Vector{Int}}, sink::Array{Ts,N}) where {S,Tr<:BitTypes,Ts<:BitTypes,N}
    for i in 1:length(s)
        seek(s, streamindices(s)[i])
        sink[i] = read(stream(s), T)
    end
    return sink
end


Base.read!(s::ArrayStream{S,Tr,N}, sink::Array{Ts,N}) where {S,Tr<:BitTypes,Ts<:BitTypes,N} =
    fill!(sink, reinterpret(Ts, fixendian(sink, read(s)))

#########
# Write #
#########
Base.write(s::S, sink::AbstractArray) where {S<:AbstractStreamContainer} = write(getfield(s, :data), sink)
Base.write(s::ArrayStream, sink::AxisArray) = write(s, getfield(sink, :data))
Base.write(s::ArrayStream, sink::ImageMeta) = write(s, getfield(sink, :data))

function Base.write(s::ArrayStream{S,T,N,AbstractRange}, sink::Array{T,N}) where {S,T,N}
    seek(s, firstindex(s))
    write(stream(s), fixendian(sink, needswap(s)))
end

function Base.read!(s::ArrayStream{S,T,N,Vector{Int}}, sink::Array{T,N}) where {S,T,N}
    for i in 1:length(s)
        seek(s, streamindices(s)[i])
        write(stream(s), fixendian(sink[i]), needswap(s))
    end
end

Base.write(s::ArrayStream{S,Tr,N}, sink::Array{Ts,N}) where {S,Tr<:BitTypes,Ts<:BitTypes,N} =
    write(s, reinterpret(Tr, s))

