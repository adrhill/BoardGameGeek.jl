using BoardGameGeek
using Documenter

DocMeta.setdocmeta!(BoardGameGeek, :DocTestSetup, :(using BoardGameGeek); recursive=true)

makedocs(;
    modules=[BoardGameGeek],
    authors="Adrian Hill",
    repo="https://github.com/adrhill/BoardGameGeek.jl/blob/{commit}{path}#{line}",
    sitename="BoardGameGeek.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://adrhill.github.io/BoardGameGeek.jl",
        assets=String[],
    ),
    pages=["Home" => "index.md"],
)

deploydocs(; repo="github.com/adrhill/BoardGameGeek.jl", devbranch="main")
