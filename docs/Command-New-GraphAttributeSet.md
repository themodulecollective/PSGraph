# New-GraphAttributeSet

The graph-level counterpart to [`New-NodeAttributeSet`](Command-New-NodeAttributeSet.md) and [`New-EdgeAttributeSet`](Command-New-EdgeAttributeSet.md). `Graph`/`SubGraph` take a plain hashtable of GraphViz attributes, but GraphViz attribute names and values are case-sensitive — `New-GraphAttributeSet` builds that hashtable from PowerShell parameters instead, with tab completion for color and font values, and normalizes casing where GraphViz requires it.

    $attrs = New-GraphAttributeSet -RankDir LR -BgColor lightyellow -FontName 'Calibri'
    graph g -Attributes $attrs {
        edge left right
    }

It has an alias, `GraphAttributes`, for shorter call sites.

    graph g -Attributes (GraphAttributes -RankDir LR) { edge a b }

## Supported attributes

`-BgColor`, `-ColorScheme`, `-Compound`, `-Concentrate`, `-FontColor`, `-FontName`, `-FontSize`, `-GradientAngle`, `-Label`, `-LabelLoc`, `-NodeSep`, `-RankDir`, `-RankSep`, `-Ratio`, `-Size`, `-Splines`, `-Style`.

`-RankDir`, `-LabelLoc`, `-Splines`, and `-Style` have `[ValidateSet(...)]` on them for tab completion and up-front validation. Unlike most GraphViz enum values, `rankdir`'s `TB`/`LR`/`BT`/`RL` values are required in uppercase — `-RankDir` is passed through as typed, not lowercased.

## Gradients and colorschemes

`-Style radial` (or `filled`) plus a two-color `-BgColor` (e.g. `'yellow:red'`) and `-GradientAngle` produce a gradient background on the graph or cluster. `-ColorScheme` names a palette (most commonly one of the [Brewer color schemes](https://graphviz.org/doc/info/colors.html#brewer)) that small-integer color values resolve against; there's no tab completion for scheme names since GraphViz ships dozens of them with varying color counts.

## Tab completion

`-BgColor` and `-FontColor` tab-complete against the system's known colors; `-FontName` tab-completes against installed fonts, the same completers `New-NodeAttributeSet`/`New-EdgeAttributeSet` use. Completion silently produces no suggestions on platforms where `System.Drawing` isn't available — it doesn't block you from typing a value by hand.

## An explicit -Compound is respected

`Graph` defaults `compound` to `true` unless the caller's attribute hashtable already contains a `compound` key — so `-Compound $false` here is not silently overridden back to `true` (see the [`compound=$false` fix](Command-Graph.md) for background).

    $attrs = New-GraphAttributeSet -Compound $false
    graph g -Attributes $attrs {}

## Only the attributes you set are included

    $attrs = New-GraphAttributeSet -RankDir LR
    # $attrs is @{ rankdir = 'LR' } - nothing else
