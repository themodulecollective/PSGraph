function New-NodeAttributeSet
{
    <#
        .SYNOPSIS
        Builds a GraphViz attribute hashtable for the Node command.

        .DESCRIPTION
        Node takes a hashtable of attributes, but GraphViz attribute names and values are
        case-sensitive and easy to get wrong ('blue' works, 'Blue' does not). This command
        exposes the common node attributes as PowerShell parameters - with tab completion for
        shape/color/font values - and normalizes casing for the ones GraphViz requires lowercase.

        .EXAMPLE
        $attrs = New-NodeAttributeSet -Shape box -Color Blue -FontName 'Calibri' -Label 'test'
        node MyNode $attrs

        .NOTES
        Ported from upstream PR #105 (jhoneill). The source PR called .ToLower() on every
        attribute value including numeric/boolean ones, which throws - this version only
        lowercases the string-valued attributes GraphViz actually requires lowercase.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]
    [CmdletBinding()]
    [Alias('NodeAttributes')]
    [OutputType([hashtable])]
    param(
        # Basic drawing color for graphics, not text (which requires FontColor to be set)
        [string]
        $Color,

        # Distortion factor for shape=polygon. Positive values enlarge the top; negative the bottom.
        [double]
        $Distortion,

        # Background color used to fill the node's shape
        [string]
        $FillColor,

        # If true, node size is fixed to Width/Height and not expanded to fit the label
        [ValidateSet('false', 'shape', 'true')]
        [string]
        $FixedSize,

        # Color used for text
        [string]
        $FontColor,

        # Font used for text
        [string]
        $FontName,

        # Font size, in points, used for text
        [double]
        $FontSize,

        # Height of node, in inches - the initial, minimum height
        [double]
        $Height,

        # Path to an image file to display inside the node (JPEG/PNG/GIF/BMP/SVG/PostScript)
        [string]
        $Image,

        # Text label attached to the node
        [string]
        $Label,

        # Width of the pen, in points, used to draw lines and curves
        [double]
        $PenWidth,

        # Forces a polygon shape to be regular (vertices lie on a circle centered on the node)
        [switch]
        $Regular,

        # A string specifying the shape of a node
        [ValidateSet('box', 'polygon', 'ellipse', 'oval', 'circle', 'point', 'egg', 'triangle', 'plaintext', 'plain', 'diamond',
            'trapezium', 'parallelogram', 'house', 'pentagon', 'hexagon', 'septagon', 'octagon', 'doublecircle',
            'doubleoctagon', 'tripleoctagon', 'invtriangle', 'invtrapezium', 'invhouse', 'Mdiamond', 'Msquare',
            'Mcircle', 'rect', 'rectangle', 'square', 'star', 'none', 'underline', 'cylinder', 'note', 'tab',
            'folder', 'box3d', 'component', 'promoter', 'cds', 'terminator', 'utr', 'primersite', 'restrictionsite',
            'fivepoverhang', 'threepoverhang', 'noverhang', 'assembly', 'signature', 'insulator', 'ribosite',
            'rnastab', 'proteasesite', 'proteinstab', 'rpromoter', 'rarrow', 'larrow', 'lpromoter')]
        [string]
        $Shape,

        # Number of sides if Shape is 'polygon'
        [int16]
        $Sides,

        # Skew factor for shape=polygon. Positive skews the top right; negative skews it left.
        [double]
        $Skew,

        # Style for the node, e.g. filled, dashed, rounded
        [ValidateSet('dashed', 'dotted', 'solid', 'invis', 'bold', 'filled', 'striped', 'wedged', 'diagonals', 'rounded')]
        [string]
        $Style,

        # Width of node, in inches - the initial, minimum width
        [double]
        $Width
    )

    $values = @{}

    # GraphViz requires these lowercase; user input may not be
    foreach ($param in @('Color', 'FillColor', 'FixedSize', 'FontColor', 'Shape', 'Style'))
    {
        if ($PSBoundParameters.ContainsKey($param))
        {
            $values[$param.ToLower()] = $PSBoundParameters[$param].ToLower()
        }
    }

    # Passed through unchanged - numeric, or free-form text where case is meaningful
    foreach ($param in @('Distortion', 'FontName', 'FontSize', 'Height', 'Image', 'Label', 'PenWidth', 'Sides', 'Skew', 'Width'))
    {
        if ($PSBoundParameters.ContainsKey($param))
        {
            $values[$param.ToLower()] = $PSBoundParameters[$param]
        }
    }

    if ($Regular)
    {
        $values['regular'] = $true
    }

    $values
}

function Get-PSGraphColorCompletion
{
    # commandName/parameterName/commandAst/fakeBoundParameter are required by
    # Register-ArgumentCompleter's scriptblock signature but unused here.
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSReviewUnusedParameter", "")]
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    try
    {
        [System.Drawing.KnownColor].GetFields() |
            Where-Object { $_.IsStatic -and -not $_.IsSpecialName -and $_.Name -like "$wordToComplete*" } |
            Sort-Object Name |
            ForEach-Object {
                [System.Management.Automation.CompletionResult]::new($_.Name.ToLower(), $_.Name.ToLower(), 'ParameterValue', $_.Name.ToLower())
            }
    }
    catch
    {
        # System.Drawing isn't guaranteed to be available/functional on every platform - degrade to no suggestions
        Write-Debug "Get-PSGraphColorCompletion: System.Drawing unavailable - $PSItem"
    }
}

function Get-PSGraphFontCompletion
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSReviewUnusedParameter", "")]
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    if ($null -eq $script:PSGraphFontFamilies)
    {
        try
        {
            $script:PSGraphFontFamilies = (New-Object System.Drawing.Text.InstalledFontCollection).Families.Name
        }
        catch
        {
            # Not available on this platform (e.g. non-Windows without GDI+) - degrade to no suggestions
            Write-Debug "Get-PSGraphFontCompletion: System.Drawing.Text unavailable - $PSItem"
            $script:PSGraphFontFamilies = @()
        }
    }
    $script:PSGraphFontFamilies.Where({ $_ -like "$wordToComplete*" }) | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new("'$_'", $_, 'ParameterValue', $_)
    }
}

function Get-PSGraphArrowCompletion
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSReviewUnusedParameter", "")]
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $baseArrows = @('box', 'crow', 'curve', 'diamond', 'dot', 'inv', 'none', 'normal', 'tee', 'vee')
    $modifierPrefixMatch = [regex]::Match($wordToComplete, '^[olr]{1,2}')
    $prefix = if ($modifierPrefixMatch.Success) { $modifierPrefixMatch.Value } else { '' }

    $baseArrows | Where-Object { "$prefix$_" -like "$wordToComplete*" } | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new("$prefix$_", "$prefix$_", 'ParameterValue', "$prefix$_")
    }
}

if (Get-Command -Name Register-ArgumentCompleter -ErrorAction SilentlyContinue)
{
    Register-ArgumentCompleter -CommandName New-NodeAttributeSet -ParameterName Color -ScriptBlock ${function:Get-PSGraphColorCompletion}
    Register-ArgumentCompleter -CommandName New-NodeAttributeSet -ParameterName FillColor -ScriptBlock ${function:Get-PSGraphColorCompletion}
    Register-ArgumentCompleter -CommandName New-NodeAttributeSet -ParameterName FontColor -ScriptBlock ${function:Get-PSGraphColorCompletion}
    Register-ArgumentCompleter -CommandName New-NodeAttributeSet -ParameterName FontName -ScriptBlock ${function:Get-PSGraphFontCompletion}

    Register-ArgumentCompleter -CommandName New-EdgeAttributeSet -ParameterName ArrowHead -ScriptBlock ${function:Get-PSGraphArrowCompletion}
    Register-ArgumentCompleter -CommandName New-EdgeAttributeSet -ParameterName ArrowTail -ScriptBlock ${function:Get-PSGraphArrowCompletion}
    Register-ArgumentCompleter -CommandName New-EdgeAttributeSet -ParameterName Color -ScriptBlock ${function:Get-PSGraphColorCompletion}
    Register-ArgumentCompleter -CommandName New-EdgeAttributeSet -ParameterName FontColor -ScriptBlock ${function:Get-PSGraphColorCompletion}
    Register-ArgumentCompleter -CommandName New-EdgeAttributeSet -ParameterName LabelFontColor -ScriptBlock ${function:Get-PSGraphColorCompletion}
    Register-ArgumentCompleter -CommandName New-EdgeAttributeSet -ParameterName FontName -ScriptBlock ${function:Get-PSGraphFontCompletion}
    Register-ArgumentCompleter -CommandName New-EdgeAttributeSet -ParameterName LabelFontName -ScriptBlock ${function:Get-PSGraphFontCompletion}
}
