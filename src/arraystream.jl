struct ArrayStream{S,T,N,I<:Union{AbstractRange,Int,Vector}} #<: AbstractArrayStream{T,N}
    s::IO
    streamindices::I
    ownstream::Bool
    needswap::Bool
end

# TODO: would it be better to use AbstractArrayStream here?
const AxisStream{S,T,N,I,Ax} = AxisArray{T,N,ArrayStream{S,T,N,I},Ax}
const MetaStream{S,T,N,I} = ImageMeta{T,N,ArrayStream{S,T,N,I}}
const MetaAxisStream{S,T,N,I,Ax} = ImageMeta{T,N,AxisStream{S,T,N,I,Ax}}
const MetaAxis{T,N,D,Ax} = ImageMeta{T,N,AxisArray{T,N,D,Ax}}
const AbstractMetaStream{S,T,N,I} = Union{MetaStream{S,T,N,I},MetaAxisStream{S,T,N,I,Ax}} where {Ax}
const AbstractStreamContainer = Union{AbstractMetaStream, AxisStream}

# TODO: maybe use Base.unsafe_wrap here
ArrayStream{S,T,N}(io::IO, streamindices::I, ownstream::Bool=true, needswap::Bool=false) where {S,T,N,I<:Union{AbstractRange,Int,Vector}} =
    ArrayStream{S,T,N,I}(io, streamindices, ownstream, needswap)

function ArrayStream(A::AbstractArray{T,N}, needswap::Bool=false) where {T,N}
    io = IOBuffer()
    write(io, A)
    seek(io, 0)
    ArrayStream{Tuple{size(A)...},T,N}(io, range(position(io), step=sizeof(T), length=length(A)), 0, true, needswap)
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
    fill!(sink, reinterpret(Ts, fixendian(sink, read(s))))

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

