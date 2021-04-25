using Documenter
using StableArrays

makedocs(
    sitename = "StableArrays",
    format = Documenter.HTML(),
    modules = [StableArrays],
    pages = [
        "index.md",
        "API" => "api.md"
    ]
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
#=deploydocs(
    repo = "<repository url>"
)=#
