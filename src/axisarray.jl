# Reading of each struct type has 2 methods
# - s has same type as sink
#   - read is performed at the element level and doesn't require any additional permutations
# - s has different type from sink
#   - read in as raw eltype and permutedims to fill in sink. This requires appropriately axisnames

########
# Read #
########
Base.read!(s::AxisStream, sink::ImageMeta) = read!(s, getfield(sink, :data))
Base.read!(s::AxisStream{S,<:BitTypes}, sink::Array{<:BitTypes}) where {S,N} = read!(getfield(s,:data), sink)
Base.read!(s::AxisStream{S,T,N,I,Ax}, sink::AxisArray{T,N,D,Ax}) where {S,T,N,I,D,Ax} = read!(getfield(s, :data), getfield(s,:data))
Base.read(s::AxisStream{S,T,N,I,Ax}) where {S,T,N,I,Ax} = read!(s, AxisArray(Array{T,N}(undef, size(s)), AxisArrays.axisparams(s)))
Base.read!(s::AxisStream{S,T,N,I,Ax}, sink::AxisArray{T,N,D,Ax}) where {S,T,N,I,D,Ax} = read!(getfield(s,:data), getfield(s:, :data))
# raw eltype → struct view can use Axis name permutation to semiautomate this
Base.read!(s::AxisStream{S,<:BitTypes,N,I,Ax}, sink::AxisArray{T,N,D,Ax}) where {S,T,N,I,D,Ax} = read!(s, getfield(s:, :data))

# Triangle
function Base.read!(s::AxisStream{S,<:BitTypes,N,I,Ax}, sink::Array{Triangle}) where {S,T,N,I,Ax}
    perm = permutation((:triangledim, setdiff(axisnames(s), :triangledim)...,), axisnames(s))
    return fill!(sink, triangleview(permutedims(read(getfield(s,:data)), perm)))
end

# Point
function Base.read!(s::AxisStream{S,<:BitTypes,N,I,Ax}, sink::Array{Point}) where {S,N,I,Ax}
    perm = permutation((:pointdim, setdiff(AxisArrays.axisnames(s), :pointdim)...,), AxisArrays.axisnames(s))
    return fill!(sink, pointview(permutedims(read(s), perm)))
end

# Quat
function Base.read!(s::AxisStream{S,<:BitTypes,N,I,Ax}, sink::Array{Quat}) where {S,N,I,Ax}
    perm = permutation((:quatdim, setdiff(axisnames(s), :quatdim)...,), axisnames(s))
    return fill!(sink, quatview(permutedims(read(getfield(s,:data)), perm)))
end

# SMatrix
function Base.read!(s::AxisStream{S,<:BitTypes,N,I,Ax}, sink::Array{SMatrix}) where {S,N,I,Ax}
    perm = permutation((:matdim1, :matdim2, setdiff(axisnames(s), (:matdim1,:matdim2))...,), axisnames(s))
    return fill!(sink, matview(permutedims(read(getfield(s,:data)), perm)))
end

# SVector
function Base.read!(s::AxisStream{S,<:BitTypes,N,I,Ax}, sink::Array{SVector}) where {S,N,I,Ax}
    perm = permutation((:vecdim, setdiff(axisnames(s), :vecdim)...,), axisnames(s))
    return fill!(sink, vecview(permutedims(read(getfield(s, :data)), perm)))
end

# ColorTypes
function Base.read!(s::AxisStream{S,<:BitTypes,N,I,Ax}, sink::Array{T,N}) where {S,T<:Union{Color3,ColorAlpha},N,I,Ax}
    perm = permutation((:colordim, setdiff(axisnames(s), :colordim)...,), axisnames(s))
    return fill!(sink, colorview(T, PermutedDimsArray(read!(getfield(s, :data)), perm)))
end

# Distributions
function Base.read!(s::AxisStream{S,<:BitTypes}, sink::Array{Ts}) where {S,T<:Distribution}
    perm = permutation((:statdim, setdiff(axisnames(s), :statdim)...,), axisnames(s))
    return fill!(sink, statview(T, permutedims(read(s), perm)))
end

#########
# Write #
#########
Base.write(s::AxisStream{S,T,N,I,Ax}, sink::ImageMeta) where {S,T,N,I,D,Ax} = write(s, getfield(sink, :data))
Base.write(s::AxisStream{S,T,N,I,Ax}, sink::AxisArray) where {S,T,N,I,D,Ax} = write(s, getfield(sink, :data))

# Triangle
function Base.write(s::AxisStream{S,<:BitTypes,N,I,Ax}, sink::Array{Triangle}) where {S,T,N,I,Ax} =
    perm = permutation(axisnames(s), (:triangledim, setdiff(axisnames(s), :triangledim)...,))
    write(getfield(s,:data), PermutedDimsArray(mappedview(extracttriangle, sink), perm))
end

# Point
function Base.write(s::AxisStream{S,<:BitTypes,N,I,Ax}, sink::Array{Point}) where {S,N,I,Ax} =
    perm = permutation(axisnames(s), (:pointdim, setdiff(axisnames(s), :pointdim)...,))
    write(getfield(s,:data), PermutedDimsArray(mappedview(extractpoint, A), perm))
end

# Quat
function Base.write(s::AxisStream{S,<:BitTypes,N,I,Ax}, sink::Array{Quat}) where {S,N,I,Ax} =
    perm = permutation(axisnames(s), (:quatdim, setdiff(axisnames(s), :quatdim)...,))
    write(getfield(s,:data), PermutedDimsArray(mappedview(extractquat, A), perm))
end

# SMatrix
function Base.write(s::AxisStream{S,<:BitTypes,N,I,Ax}, sink::Array{Quat}) where {S,N,I,Ax} =
    perm = permutation(axisnames(s), (:matdim1, :matdim2, setdiff(axisnames(s), :matdim1, :matdim2)...,))
    write(getfield(s,:data), PermutedDimsArray(extractsmat(sink), perm))
end

# SVector
function Base.write(s::AxisStream{S,<:BitTypes,N,I,Ax}, sink::Array{SVector}) where {S,N,I,Ax} =
    perm = permutation(axisnames(s), (:vecdim, setdiff(axisnames(s), :vecdim)...,))
    write(getfield(s,:data), PermutedDimsArray(extractsvec(sink), perm))
end

# ColorTypes
function Base.write(s::AxisStream{S,<:BitTypes,N,I,Ax}, sink::Array{<:Union{Color3,ColorAlpha}}) where {S,N,I,Ax}
    perm = permutation(axisnames(s), (:colordim, setdiff(axisnames(s), :colordim)...,))
    write(getfield(s,:data), PermutedDimsArray(channelview(sink), perm))
end

# Distributions
function Base.write(s::AxisStream{S,<:BitTypes}, sink::Array{Ts}) where {S,T<:Distribution}
    perm = permutation(axisnames(s), (:statdim, setdiff(axisnames(s), :statdim)...,))
    write(getfield(s,:data), PermutedDimsArray(extractstat(sink), perm))
end
