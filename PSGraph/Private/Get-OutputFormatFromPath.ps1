function Get-OutputFormatFromPath
{
    <#
        .Description
        Guesses a GraphViz output format from a destination file's extension
        (e.g. '.png' -> 'png'). Returns nothing if the extension isn't recognized.

        .Example
        Get-OutputFormatFromPath -Path 'C:\graphs\example.svg'
    #>
    [CmdletBinding()]
    param(
        # The destination path whose extension should be mapped to an output format
        [string]
        $Path
    )

    $formats = @(
        'jpg'
        'png'
        'gif'
        'imap'
        'cmapx'
        'jp2'
        'json'
        'pdf'
        'plain'
        'dot'
    )

    foreach ( $ext in $formats )
    {
        if ( $Path -like "*.$ext" )
        {
            return $ext
        }
    }
}
