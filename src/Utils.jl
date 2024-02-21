module Utils
export @showc, @showp, near_eq, near_eq

# TODO(melmer): Add release branch

# Compact show
macro showc(exs...)
    blk = Expr(:block)
    for ex in exs
        push!(blk.args, :(println($(sprint(Base.show_unquoted,ex)*" = "),
        repr(begin local value = $(esc(ex)) end, context = :compact=>true))))
    end
    isempty(exs) || push!(blk.args, :value)
    return blk
end

# Pretty show
macro showp(exs...)
    blk = Expr(:block)
    for ex in exs
        push!(blk.args, :(println($(sprint(Base.show_unquoted,ex)*" = "),
        repr(MIME("text/plain"), begin local value = $(esc(ex)) end, context = :limit=>true))))
    end
    isempty(exs) || push!(blk.args, :value)
    return blk
end

# Relatively robust floating-point comparisons
# Using `where T <: AbstractFloat` to ensure similar types
# TODO(m elmer): take the min of the floatmax and the max of the floatmin to
# enable dissimilar type comparisons (maybe)
function near_eq(
    a::T, b::T, rel_tol::T = 128 * eps(T), abs_tol::T = eps(T)
)::Bool where T <: AbstractFloat
    # Some handy constants for determining whether the defaults are suitable:
    # eps(Float64) = 2.220446049250313e-16
    # eps(Float32) = 1.1920929f-7
    # eps(Float16) = 0.000977
    # floatmin(Float64) = 2.2250738585072014e-308
    # floatmin(Float32) = 1.1754944f-38
    # floatmin(Float16) = 6.104e-5
    # See also: nextfloat e.g. nextfloat(1000.0::Float64) - 1000.0::Float64 =
    #                              1.1368683772161603e-13
    if a == b return true; end

    diff = abs(a - b)
    norm = min(abs(a) + abs(b), floatmax(T))
    return diff < max(abs_tol, rel_tol * norm)
end

# Now make it work on vectors
# TODO(m elmer): SIMD this hoe
# TODO(m elmer): take the min of the floatmax and the max of the floatmin to
# enable dissimilar type comparisons (maybe)
function near_eq(
    a::Vector{T}, b::Vector{T}, rel_tol::T = 128 * eps(T),
    abs_tol::T = 128 * floatmin(T)
)::Bool where T <: AbstractFloat
    if size(a) != size(b) throw(DimensionMismatch("Dimension mismatch.")); end

    for i in 1:size(a, 1)
        if !near_eq(a[i], b[i], rel_tol, abs_tol) return false; end
    end

    return true;
end

end
