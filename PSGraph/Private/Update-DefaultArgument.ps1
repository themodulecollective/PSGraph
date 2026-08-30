function Update-DefaultArgument
{
    <#
        .Description
        Fills in default GraphViz arguments (layout engine, auto-name, output
        format) on a copy of the caller's parameter hashtable before it's
        translated into command-line arguments by Get-TranslatedArgument.

        .Example
        Update-DefaultArgument -InputObject @{ DestinationPath = 'graph.svg' }
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        "PSUseShouldProcessForStateChangingFunctions", "",
        Justification = "Despite the Update- verb, this only mutates the caller's local hashtable
argument to fill in defaults and returns it - it doesn't change any external/persistent state, so
ShouldProcess doesn't apply."
    )]
    [cmdletbinding()]
    param (
        # Parameter hashtable to fill in defaults on
        $inputObject
    )

    if ( $InputObject.ContainsKey( 'LayoutEngine' ) )
    {
        Write-Verbose 'Looking up and replacing rendering engine string'
        $InputObject['LayoutEngine'] = Get-LayoutEngine -Name $InputObject['LayoutEngine']
    }

    # PassThru intentionally omits DestinationPath so graphviz writes to stdout;
    # don't let AutoName's '-O' flag force it to an auto-named file instead.
    if ( -Not $InputObject.ContainsKey( 'DestinationPath' ) -and -Not $InputObject.ContainsKey( 'PassThru' ) )
    {
        $InputObject["AutoName"] = $true;
    }

    if ( -Not $InputObject.ContainsKey( 'OutputFormat' ) )
    {
        Write-Verbose "Tryig to set OutputFormat to match file extension"
        $outputFormat = Get-OutputFormatFromPath -Path $InputObject['DestinationPath']
        if ( $outputFormat )
        {
            $InputObject["OutputFormat"] = $outputFormat
        }
        else
        {
            $InputObject["OutputFormat"] = 'png'
        }
    }

    return $InputObject
}
