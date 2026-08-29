# New-NodeAttributeSet

`Node` takes a plain hashtable of GraphViz attributes, but GraphViz attribute names and values are case-sensitive — `color='Blue'` silently fails to render where `color='blue'` works. `New-NodeAttributeSet` builds that hashtable for you from PowerShell parameters, with tab completion for shape, color, and font values, and normalizes the casing GraphViz actually requires.

    $attrs = New-NodeAttributeSet -Shape box -Color Blue -FontName 'Calibri' -Label 'test'
    node MyNode $attrs

It has an alias, `NodeAttributes`, if you want something shorter at the call site.

    node MyNode (NodeAttributes -Shape box -Color Blue)

## Supported attributes

`-Color`, `-FillColor`, `-FixedSize`, `-FontColor`, `-FontName`, `-FontSize`, `-Height`, `-Image`, `-Label`, `-PenWidth`, `-Regular`, `-Shape`, `-Sides`, `-Skew`, `-Style`, `-Width`, `-Distortion`. Each maps to the matching GraphViz node attribute.

`-Shape` and `-Style` have `[ValidateSet(...)]` on them, so tab completion and parameter validation catch typos before you ever hand the graph to GraphViz.

## Tab completion for color and font

`-Color`, `-FillColor`, and `-FontColor` tab-complete against the system's known colors; `-FontName` tab-completes against installed fonts. Completion silently produces no suggestions on platforms where `System.Drawing` isn't available (non-Windows without GDI+) — it doesn't block you from typing a value by hand.

    node MyNode (New-NodeAttributeSet -Color <tab>)

## Only the attributes you set are included

Like `Node`'s own hashtable argument, only attributes you actually pass are added to the result — there's no need to pre-fill defaults for the ones you don't care about.

    $attrs = New-NodeAttributeSet -Shape box
    # $attrs is @{ shape = 'box' } - nothing else
