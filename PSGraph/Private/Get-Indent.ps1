function Get-Indent
{
    <#
        .Description
        Returns a string of leading spaces (4 per level) for the current graph
        nesting depth, used to indent generated DOT source.

        .Example
        Get-Indent -Depth 2

        "        " (8 spaces)
    #>
    [cmdletbinding()]
    param(
        # The nesting depth to indent for; defaults to the current graph's tracked depth
        $depth = $script:indent
    )
    process
    {
        if ( $null -eq $depth -or $depth -lt 0 )
        {
            $depth = 0
        }
        Write-Debug "Depth $depth"
        (" " * 4 * $depth )
    }
}
