# New-EdgeAttributeSet

The edge counterpart to [`New-NodeAttributeSet`](Command-New-NodeAttributeSet.md). `Edge` takes a plain hashtable of GraphViz attributes, but GraphViz attribute names and values are case-sensitive — `New-EdgeAttributeSet` builds that hashtable from PowerShell parameters instead, with tab completion for arrowhead, color, and font values, and normalizes casing where GraphViz requires it.

    $attrs = New-EdgeAttributeSet -Direction both -ArrowHead crow -ArrowTail lcrow -Color Blue -Style dashed -Label test
    edge one two $attrs

This defines a two-way dashed edge, in blue, with a "crow" head and left-half-crow tail.

It has an alias, `EdgeAttributes`, for shorter call sites.

    edge one two (EdgeAttributes -Direction both -Color Blue)

## Supported attributes

`-ArrowHead`, `-ArrowTail`, `-ArrowSize`, `-Color`, `-Constraint`, `-Direction`, `-FontColor`, `-FontName`, `-FontSize`, `-HeadLabel`, `-Label`, `-LabelFontColor`, `-LabelFontName`, `-LabelFontSize`, `-Length`, `-PenWidth`, `-Style`, `-TailLabel`.

A couple of these map to shortened GraphViz keys: `-Direction` becomes `dir`, `-Length` becomes `len`. `-Direction` and `-Style` have `[ValidateSet(...)]` on them for tab completion and up-front validation.

## Tab completion

`-ArrowHead` and `-ArrowTail` tab-complete against GraphViz's arrow shape vocabulary (`box`, `crow`, `curve`, `diamond`, `dot`, `inv`, `none`, `normal`, `tee`, `vee`) including the `o`/`l`/`r` modifier prefixes GraphViz supports (e.g. `olbox`, `rvee`). `-Color`, `-FontColor`, and `-LabelFontColor` tab-complete against system colors; `-FontName` and `-LabelFontName` tab-complete against installed fonts. As with `New-NodeAttributeSet`, color/font completion degrades to no suggestions (not an error) on platforms without `System.Drawing`.

## Only the attributes you set are included

    $attrs = New-EdgeAttributeSet -Color Blue
    # $attrs is @{ color = 'blue' } - nothing else
