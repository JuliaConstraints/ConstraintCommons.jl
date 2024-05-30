using ConstraintCommons
using Documenter

DocMeta.setdocmeta!(
    ConstraintCommons,
    :DocTestSetup,
    :(using ConstraintCommons);
    recursive = true
)

makedocs(;
    modules = [ConstraintCommons],
    authors = "azzaare (jean-François BAFFIER)",
    repo = "https://github.com/JuliaConstraints/ConstraintCommons.jl/blob/{commit}{path}#{line}",
    sitename = "ConstraintCommons.jl",
    format = Documenter.HTML(;
        prettyurls = get(ENV, "CI", "false") == "true",
        canonical = "https://JuliaConstraints.github.io/ConstraintCommons.jl",
        edit_link = "main",
        assets = String[]
    ),
    pages = ["Home" => "index.md"]
)

deploydocs(; repo = "github.com/JuliaConstraints/ConstraintCommons.jl", devbranch = "main")
