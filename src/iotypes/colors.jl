# TODO
#Base.read!(s::ImageStream{S,Tr,N,Tuple{Axis{:colordim}, Axis}}, sink::Array{Ts}; kwargs...) where {S,Tr,Ts<:Union{Color3,ColorAlpha},N} = read!(stream(s), sink)
#function Base.read!(s::ImageStream{S,RGB{T},N}, sink::Array{RGB{T},N}; kwargs...) where {S,T<:AbstractFloat,N}
#end

#function Base.read!(s::ImageStream{S,RGBA{T},N}, sink::Array{RGBA{T},N}; kwargs...) where {S,T<:AbstractFloat,N}
#end
