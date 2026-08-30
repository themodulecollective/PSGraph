function Get-TranslatedArgument
{
    <#
        .Description
        Converts a hashtable of PSGraph parameter names/values (already defaulted
        by Update-DefaultArgument) into GraphViz command-line arguments, using the
        mapping from Get-ArgumentLookUpTable.

        .Example
        Get-TranslatedArgument -InputObject @{ OutputFormat = 'png' }

        -Tpng
    #>
    [OutputType([string])]
    [CmdletBinding()]
    param(
        # Parameter name/value pairs to translate into GraphViz command-line arguments
        [hashtable]
        $InputObject
    )

    $paramLookup = Get-ArgumentLookUpTable

    Write-Verbose 'Walking parameter mapping'
    foreach ( $key in $InputObject.keys )
    {
        Write-Debug $key
        if ( $null -ne $key -and $paramLookup.ContainsKey( $key ) )
        {
            $newArgument = $paramLookup[$key]
            if ( $newArgument -like '*{0}*' )
            {
                $newArgument = $newArgument -f $InputObject[$key]
            }

            Write-Debug $newArgument
            "-$newArgument"
        }
    }
}
