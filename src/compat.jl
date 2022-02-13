if VERSION < v"1.1.0-DEV.472"
    export isnothing
    isnothing(::Any) = false
    isnothing(::Nothing) = true
end
