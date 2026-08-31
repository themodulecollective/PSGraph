# GraphViz Documentation

PSGraph is a thin PowerShell layer over [GraphViz](http://graphviz.org/) — every command in this module ultimately emits text in GraphViz's DOT language, and `Export-PSGraph`/`Show-PSGraph` shell out to GraphViz's `dot` executable to render that text into an image. When you need a feature this module doesn't wrap in a dedicated command, GraphViz's own documentation is the source of truth.

## Useful upstream references

* [Graphviz.org](http://graphviz.org/) — project home.
* [DOT language reference](https://graphviz.org/doc/info/lang.html) — the text format PSGraph generates.
* [Node, Edge, and Graph attributes](https://graphviz.org/doc/info/attrs.html) — every attribute name/value `Node`, `Edge`, `Graph`, and `SubGraph` accept in their `-Attributes` hashtables.
* [Node shapes](https://graphviz.org/doc/info/shapes.html) — including the HTML-like table labels `Record`/`Row`/`Cells`/`Entity` build for you.
* [Layout engines](https://graphviz.org/docs/layouts/) — `Export-PSGraph -LayoutEngine` accepts `dot`, `neato`, `circo`, `fdp`, `sfdp`, `twopi`, and a few legacy aliases (`SpringModelSmall`, etc.) kept for backward compatibility.
* [Command line / graph gallery](https://graphviz.org/gallery/) — the source for the recreated examples in `Example-Gallery.md`.

## Falling back to raw DOT

Any attribute or construct GraphViz supports but PSGraph doesn't have a dedicated parameter for can still be set through a plain hashtable, since `-Attributes` accepts arbitrary key/value pairs:

    graph g {
        node A @{ shape = 'box'; peripheries = 3 }
    }

For syntax PSGraph's DSL doesn't model at all (a construct with no hashtable-attribute equivalent), use `Inline` to pass raw DOT text straight through:

    graph g {
        inline 'rankdir=LR'
    }

## Installing the GraphViz binaries

PSGraph's `Install-GraphViz` command installs the native `dot` binary GraphViz itself ships (Chocolatey on Windows with a nuget.org fallback for non-admin installs via `-Scope CurrentUser`, Homebrew on macOS). See [Command-Install-GraphViz.md](Command-Install-GraphViz.md) for details, or install GraphViz yourself through your platform's package manager (e.g. `apt-get install graphviz` on Debian/Ubuntu) if you'd rather not use PSGraph's installer.
