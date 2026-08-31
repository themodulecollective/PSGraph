function New-GraphAttributeSet
{
    <#
        .SYNOPSIS
        Builds a GraphViz attribute hashtable for the Graph/SubGraph commands.

        .DESCRIPTION
        Graph and SubGraph take a hashtable of attributes, but GraphViz attribute names and
        values are case-sensitive and easy to get wrong ('blue' works, 'Blue' does not). This
        command exposes the common graph-level attributes (rankdir, splines, background,
        spacing, ...) as PowerShell parameters - with tab completion for color/font values - and
        normalizes casing for the ones GraphViz requires lowercase.

        .EXAMPLE
        $graphAttributeSetSplat = @{
            RankDir = 'LR'
            BgColor = 'lightyellow'
            FontName = 'Calibri'
        }
        $attrs = New-GraphAttributeSet @graphAttributeSetSplat
        graph g -Attributes $attrs { edge a b }

        .NOTES
        Follows the same lowercase/passthrough split as New-NodeAttributeSet and
        New-EdgeAttributeSet. RankDir's TB/LR/BT/RL values are left in their required
        uppercase form - unlike most other GraphViz enum values, rankdir is not lowercase.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        "PSUseShouldProcessForStateChangingFunctions", "",
        Justification = "Despite the New- verb, this builds and returns a hashtable in memory - it
doesn't change any external/persistent state, so ShouldProcess doesn't apply."
    )]
    [CmdletBinding()]
    [Alias('GraphAttributes')]
    [OutputType([hashtable])]
    param(
        # Background color for the graph/cluster; supports a two-color 'c1:c2' gradient
        [string]
        $BgColor,

        # Namespace GraphViz resolves BgColor/FontColor small-integer values against,
        # e.g. 'blues9' (a Brewer palette) or 'x11' (the default). No tab completion is provided -
        # see https://graphviz.org/doc/info/colors.html#brewer for the full scheme list.
        [string]
        $ColorScheme,

        # If false, forces edges between clusters to attach to the actual node instead of the
        # cluster boundary, even when Edge would otherwise rewrite them with lhead/ltail
        [bool]
        $Compound,

        # Merges edges sharing an endpoint into a single line where the layout allows it
        [switch]
        $Concentrate,

        # Font color used for the graph's Label
        [string]
        $FontColor,

        # Font used for the graph's Label
        [string]
        $FontName,

        # Font size, in points, used for the graph's Label
        [double]
        $FontSize,

        # Angle, in degrees, controlling the direction of a BgColor gradient fill
        [double]
        $GradientAngle,

        # Text label for the graph/cluster
        [string]
        $Label,

        # Placement of Label: 't' (top) or 'b' (bottom)
        [ValidateSet('t', 'b')]
        [string]
        $LabelLoc,

        # Minimum space, in inches, between adjacent nodes on the same rank
        [double]
        $NodeSep,

        # Direction of graph layout: top-to-bottom, left-to-right, bottom-to-top, right-to-left
        [ValidateSet('TB', 'LR', 'BT', 'RL')]
        [string]
        $RankDir,

        # Minimum space, in inches, between adjacent ranks
        [double]
        $RankSep,

        # Aspect-ratio hint for the final layout - a number (e.g. 0.5) or a keyword such as
        # 'fill'/'compress'/'expand'/'auto'
        [string]
        $Ratio,

        # Maximum drawing size, e.g. '8,8' or '8,8!' (the trailing '!' forces scaling up too)
        [string]
        $Size,

        # Splines/edge-routing mode, e.g. curved, ortho, polyline, none
        [ValidateSet('line', 'polyline', 'curved', 'ortho', 'spline', 'none', 'true', 'false')]
        [string]
        $Splines,

        # Style for the graph/cluster background, e.g. filled, rounded, radial (gradient fill)
        [ValidateSet('filled', 'striped', 'rounded', 'radial')]
        [string]
        $Style
    )

    $values = @{}

    # GraphViz requires these lowercase; user input may not be
    $lowercaseParams = @('BgColor', 'ColorScheme', 'FontColor', 'Splines', 'Style')
    foreach ($param in $lowercaseParams)
    {
        if ($PSBoundParameters.ContainsKey($param))
        {
            $values[$param.ToLower()] = $PSBoundParameters[$param].ToLower()
        }
    }

    # Passed through unchanged - numeric, boolean, free-form text, or an enum GraphViz requires
    # in a case other than lowercase (RankDir's TB/LR/BT/RL)
    $passthroughParams = @(
        'FontName', 'FontSize', 'GradientAngle', 'Label', 'LabelLoc', 'NodeSep', 'RankDir',
        'RankSep', 'Ratio', 'Size'
    )
    foreach ($param in $passthroughParams)
    {
        if ($PSBoundParameters.ContainsKey($param))
        {
            $values[$param.ToLower()] = $PSBoundParameters[$param]
        }
    }

    if ($PSBoundParameters.ContainsKey('Compound'))
    {
        $values['compound'] = $Compound
    }

    if ($Concentrate)
    {
        $values['concentrate'] = $true
    }

    $values
}
