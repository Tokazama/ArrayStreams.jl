---

# Construct ArrayStream from Array

```
julia> io = IOBuffer();

julia> write(io, [1:10...])
80

julia> seek(io, 0)
IOBuffer(data=UInt8[...], readable=true, writable=true, seekable=true, append=false, size=80, maxsize=Inf, ptr=1, mark=-1)

julia> as = ArrayStream{Tuple{2,5},Int,2}(io,0:80,true,false)
```

# Indexing

While an `ArrayStream` may be indexed, this will only result in performance gains
if the indices represent a significantly smaller portion of the original `ArrayStream`.
This is because an indexed ArrayStream has to perform a `seek(ArrayStream, index)`
step at every index before reading. This is in contrast to reading in a single
chunk of memory, which is considerably faster.

# ChunkedStream


