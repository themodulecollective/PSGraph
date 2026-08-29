function New-EdgeAttributeSet
{
    <#
        .SYNOPSIS
        Builds a GraphViz attribute hashtable for the Edge command.

        .DESCRIPTION
        Edge takes a hashtable of attributes, but GraphViz attribute names and values are
        case-sensitive and easy to get wrong ('blue' works, 'Blue' does not). This command
        exposes the common edge attributes as PowerShell parameters - with tab completion for
        arrowhead/color/font values - and normalizes casing for the ones GraphViz requires lowercase.

        .EXAMPLE
        $attrs = New-EdgeAttributeSet -Direction both -ArrowHead crow -ArrowTail lcrow -Color Blue -Style dashed -Label test
        edge one two $attrs

        This defines a two-way dashed edge, in blue, with a "crow" head and left-half-crow tail.

        .NOTES
        Ported from upstream PR #105 (jhoneill). The source PR called .ToLower() on every
        attribute value including numeric/boolean ones, which throws - this version only
        lowercases the string-valued attributes GraphViz actually requires lowercase.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]
    [CmdletBinding()]
    [Alias('EdgeAttributes')]
    [OutputType([hashtable])]
    param(
        # Style of arrowhead on the head node of an edge. Only shown when Direction is 'forward' or 'both'.
        [string]
        $ArrowHead,

        # Multiplicative scale factor for arrowheads
        [double]
        $ArrowSize,

        # Style of arrowhead on the tail node of an edge. Only shown when Direction is 'back' or 'both'.
        [string]
        $ArrowTail,

        # Basic drawing color for graphics, not text (which requires FontColor to be set)
        [string]
        $Color,

        # If false, the edge is not used when ranking nodes
        [bool]
        $Constraint,

        # Which ends of the edge should be decorated with an arrowhead
        [ValidateSet('forward', 'back', 'both', 'none')]
        [string]
        $Direction,

        # Color used for text
        [string]
        $FontColor,

        # Font used for text
        [string]
        $FontName,

        # Font size, in points, used for text
        [double]
        $FontSize,

        # Text label placed near the head of the edge
        [string]
        $HeadLabel,

        # Text label attached to the edge
        [string]
        $Label,

        # Color used for HeadLabel/TailLabel; defaults to the edge's FontColor if unset
        [string]
        $LabelFontColor,

        # Font used for HeadLabel/TailLabel; defaults to the edge's FontName if unset
        [string]
        $LabelFontName,

        # Font size, in points, used for HeadLabel/TailLabel; defaults to the edge's FontSize if unset
        [double]
        $LabelFontSize,

        # Preferred edge length, in inches
        [double]
        $Length,

        # Width of the pen, in points, used to draw lines and curves
        [double]
        $PenWidth,

        # Style for the edge, e.g. dashed, solid
        [ValidateSet('dashed', 'dotted', 'solid', 'invis', 'bold', 'tapered')]
        [string]
        $Style,

        # Text label placed near the tail of the edge
        [string]
        $TailLabel
    )

    $values = @{}

    # Attributes where the GraphViz key is shortened from the parameter name
    if ($PSBoundParameters.ContainsKey('Direction'))
    {
        $values['dir'] = $Direction.ToLower()
    }
    if ($PSBoundParameters.ContainsKey('Length'))
    {
        $values['len'] = $Length
    }

    # GraphViz requires these lowercase; user input may not be
    foreach ($param in @('ArrowHead', 'ArrowTail', 'Color', 'FontColor', 'LabelFontColor', 'Style'))
    {
        if ($PSBoundParameters.ContainsKey($param))
        {
            $values[$param.ToLower()] = $PSBoundParameters[$param].ToLower()
        }
    }

    # Passed through unchanged - numeric, boolean, or free-form text where case is meaningful
    foreach ($param in @('ArrowSize', 'Constraint', 'FontName', 'FontSize', 'HeadLabel', 'Label', 'LabelFontName', 'LabelFontSize', 'PenWidth', 'TailLabel'))
    {
        if ($PSBoundParameters.ContainsKey($param))
        {
            $values[$param.ToLower()] = $PSBoundParameters[$param]
        }
    }

    $values
}
