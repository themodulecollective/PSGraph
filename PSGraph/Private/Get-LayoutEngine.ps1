function Get-LayoutEngine
{
    <#
        .Description
        Maps a friendly GraphViz layout-engine name (e.g. 'Hierarchical') to the
        engine's actual command-line name (e.g. 'dot'). An already-valid engine
        name (e.g. 'dot') is returned unchanged.

        .Example
        Get-LayoutEngine -Name Hierarchical

        dot
    #>
    [CmdletBinding()]
    param(
        # The friendly or GraphViz-native layout engine name to resolve
        [string]
        $Name
    )

    $layoutEngine = @{
        Hierarchical      = 'dot'
        SpringModelSmall  = 'neato'
        SpringModelMedium = 'fdp'
        SpringModelLarge  = 'sfdp'
        Radial            = 'twopi'
        Circular          = 'circo'
        dot               = 'dot'
        neato             = 'neato'
        fdp               = 'fdp'
        sfdp              = 'sfdp'
        twopi             = 'twopi'
        circo             = 'circo'
        osage             = 'osage'
        patchwork         = 'patchwork'
    }

    $layoutEngine[$Name]
}
