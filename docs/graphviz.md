# GraphViz Documentation

PSGraph is a thin PowerShell layer over [GraphViz](http://graphviz.org/) — every command in this module ultimately emits text in GraphViz's DOT language, and `Export-PSGraph`/`Show-PSGraph` shell out to GraphViz's `dot` executable to render that text into an image. When you need a feature this module doesn't wrap in a dedicated command, GraphViz's own documentation is the source of truth.

## Useful upstream references

* [Graphviz.org](http://graphviz.org/) — project home.
* [DOT language reference](https://graphviz.org/doc/info/lang.html) — the text format PSGraph generates.
* [Node, Edge, and Graph attributes](https://graphviz.org/doc/info/attrs.html) — every attribute name/value `Node`, `Edge`, `Graph`, and `SubGraph` accept in their `-Attributes` hashtables.
* [Node shapes](https://graphviz.org/doc/info/shapes.html) — including the HTML-like table labels `Record`/`Row`/`Cells`/`Entity` build for you.
* [Layout engines](https://graphviz.org/docs/layouts/) — `Export-PSGraph -LayoutEngine` accepts `dot`, `neato`, `circo`, `fdp`, `sfdp`, `twopi`, `osage`, `patchwork`, and a few legacy aliases (`SpringModelSmall`, etc.) kept for backward compatibility.
* [Output formats](https://graphviz.org/docs/outputs/) — `Export-PSGraph -OutputFormat` accepts a broad set of GraphViz's `dot -T` values (`png`, `svg`, `pdf`, `eps`, `xdot`, `dot_json`, ...). Which of these actually work depends on how your local GraphViz build was compiled — run `dot -T?` to see what your install supports.
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

## Graph-level attributes

`New-GraphAttributeSet` (alias `GraphAttributes`) builds a case-correct attribute hashtable for `Graph`/`SubGraph`, the same way `New-NodeAttributeSet`/`New-EdgeAttributeSet` do for `Node`/`Edge`. It covers the graph attributes callers reach for most often — `rankdir`, `splines`, background/gradient fills, and rank/node spacing:

    $attrs = New-GraphAttributeSet -RankDir LR -BgColor lightyellow
    graph g -Attributes $attrs {
        edge left right
    }

## Strict graphs

`Graph -Strict` emits `strict digraph`/`strict graph`, which tells GraphViz to merge duplicate edges into one instead of drawing them separately:

    graph g -Strict {
        edge a b
        edge a b   # collapsed into the same edge as above
    }

## Gradients

Any color attribute accepts a two-color `"c1:c2"` value plus `gradientangle`, and `style` needs `filled` or `radial`:

    graph g {
        node A (New-NodeAttributeSet -FillColor 'yellow:red' -GradientAngle 45 -Style radial)
    }

## Colorschemes

GraphViz can resolve small-integer color values against a named scheme instead of X11 color names — most commonly one of the [Brewer color schemes](https://graphviz.org/doc/info/colors.html#brewer). `New-NodeAttributeSet -ColorScheme`/`New-EdgeAttributeSet`/`New-GraphAttributeSet` all expose the attribute as a plain string (no tab completion, since Graphviz ships dozens of Brewer palettes with varying color counts):

    graph g {
        node A @{ colorscheme = 'blues9'; fillcolor = '7'; style = 'filled' }
    }

## Installing the GraphViz binaries

PSGraph's `Install-GraphViz` command installs the native `dot` binary GraphViz itself ships (Chocolatey on Windows with a nuget.org fallback for non-admin installs via `-Scope CurrentUser`, Homebrew on macOS). See [Command-Install-GraphViz.md](Command-Install-GraphViz.md) for details, or install GraphViz yourself through your platform's package manager (e.g. `apt-get install graphviz` on Debian/Ubuntu) if you'd rather not use PSGraph's installer.
