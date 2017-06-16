using Documenter, HoTRG_lemon

makedocs()

deploydocs(
		   deps = Deps.pip("mkdocs", "python-markdown-math"), 
		   repo = "github.com/yoyoyoju/HoTRG_lemon.jl.git",
		   julia = "0.5", 
		   osname = "osx"
)
