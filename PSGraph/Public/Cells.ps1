function Cells
{
    <#
    .SYNOPSIS
    Converts pipeline objects into GraphViz HTML-like table rows for use inside a Record.

    .DESCRIPTION
    Emits one <TR> per pipeline object (each selected property becomes a <TD>), plus an
    optional header <TR> built from the property names of the first object seen. The
    emitted rows can be passed straight into Record's -Row/-Rows pipeline, since Row
    already passes fully formed <TR>...</TR> strings through unmodified.

    .EXAMPLE
    Get-Process | Select-Object -First 3 Name, Id | Cells -PortProperty Id | Record Processes

    .NOTES
    Ported from upstream PR #105 (KevinMarquette/PSGraph#105), deliberately left un-ported
    by Phase 3's narrow scoping of that PR. Fixed against the original: PortProperty (was
    misspelled PortPoroperty upstream), and uppercase <TR>/<TD> tags to match this module's
    existing Row/Record convention.
    #>
    [OutputType('System.String')]
    [CmdletBinding()]
    param(
        # The object(s) to render as table rows.
        [Parameter(Mandatory, ValueFromPipeline, HelpMessage = "The object(s) to render as table rows.")]
        [object]
        $InputObject,

        # Wildcard-filtered list of property names to include, in order. Defaults to all properties.
        [string[]]
        $Properties = '*',

        # Wildcard-filtered list of property names to exclude.
        [string[]]
        $ExcludeProperty,

        # Text alignment applied to every <TD>. Defaults to LEFT.
        [ValidateSet('LEFT', 'CENTER', 'RIGHT')]
        [string]
        $Align = 'LEFT',

        # Name of the property whose column should also carry a PORT attribute, so it can be
        # targeted by Edge.
        [string]
        $PortProperty,

        # HTML-encode each cell's value.
        [switch]
        $HtmlEncode,

        # Skip emitting the header row built from property names.
        [switch]
        $NoHeader
    )
    begin
    {
        $columns = $null

        $selectParams = @{ Property = $Properties }
        if ( $PSBoundParameters.ContainsKey('ExcludeProperty') )
        {
            $selectParams.ExcludeProperty = $ExcludeProperty
        }
    }
    process
    {
        $filtered = $InputObject | Select-Object @selectParams

        if ( $null -eq $columns )
        {
            $columns = $filtered.PSObject.Properties.Name

            if ( -not $NoHeader )
            {
                $headerCells = ($columns |
                    ForEach-Object { '<TD ALIGN="{0}"><B>{1}</B></TD>' -f $Align, $_ }) -join ''
                '<TR>{0}</TR>' -f $headerCells
            }
        }

        $cells = foreach ( $column in $columns )
        {
            $value = $filtered.$column
            if ( $HtmlEncode )
            {
                $value = [System.Net.WebUtility]::HtmlEncode([string]$value)
            }

            if ( $column -eq $PortProperty )
            {
                '<TD PORT="{0}" ALIGN="{1}">{2}</TD>' -f $value, $Align, $value
            }
            else
            {
                '<TD ALIGN="{0}">{1}</TD>' -f $Align, $value
            }
        }

        '<TR>{0}</TR>' -f ($cells -join '')
    }
}
