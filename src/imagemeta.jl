
#####################
# Handle properties #
#####################
abstract type MetaPropertiesArg end
struct AppendProperties <: MetaPropertiesArg end
struct ReplaceProperties <: MetaPropertiesArg end
struct IgnoreProperties <: MetaPropertiesArg end

function updateproperties!(::Type{AppendProperties}, s::AbstractMetaStream, sink::ImageMeta, propkeys::SVector{0,String})
    append!(sink.properties, properties(s))
    return nothing
end
function updateproperties!(::Type{AppendProperties}, s::AbstractMetaStream, sink::ImageMeta, propkeys::SVector{N,String}) where {N}
    for i in propkeys
        append!(properties(sink)[i], properties(s)[i])
    end
end

function updateproperties!(::Type{ReplaceProperties}, s::AbstractMetaStream, sink::ImageMeta, propkeys::SVector{0,String})
    properties(sink) = properties(s)
    return nothing
end
function updateproperties!(::Type{ReplaceProperties}, s::AbstractMetaStream, sink::ImageMeta, propkeys::SVector{N,String}) where {N}
    for i in propkeys
        properties(sink)[i] = properties(s)[i]
    end
    return nothing
end

updateproperties!(::Type{IgnoreProperties}, s::AbstractMetaStream, sink::ImageMeta, propkeys::SVector) = nothing

########
# Read #
########
function Base.read!(s::S, sink::ImageMeta; propchange::MetaPropertiesArg, propkeys::SVector{N,String}) where {S<:AbstractMetaStream,N}
   read!(getfield(s,:data), getfield(s,:data))
   updateproperties!(s, sink, propchange)
   return sink
end

function Base.read(s::S) where {S<:AbstractMetaStream}
    read!(s, ImageMeta(AxisArray(Array{eltype(s),ndims(s)}(undef, size(s)), AxisArrays.axisparams(s)),
                       properties(s)); propchange=IgnoreProperties, propkeys=SVector{0,String}())
end

#########
# Write #
#########
Base.write(s::S, sink::ImageMeta) where {S<:AbstractMetaStream} = write(getfield(s, :data), getfield(sink, :data))
