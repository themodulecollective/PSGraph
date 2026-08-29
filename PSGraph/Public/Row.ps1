function Row
{
    <#
    .SYNOPSIS
    Adds a row to a record

    .Description
    Adds a row to a record inside a PSGraph Graph

    .PARAMETER Label
    This is the displayed data for the row

    .PARAMETER Name
    This is the target name of this row to be used in edges.
    Will default to the label if the label has not special characters

    .PARAMETER HtmlEncode
    This will encode unintentional HTML. Characters like <>& would break html parsing if they are
    contained in the source data.

    .PARAMETER Attributes
    Additional HTML attributes applied to this row's cell, e.g. @{BORDER = 0} to hide the row's
    border line, or @{BGCOLOR = 'lightgrey'} to shade it.

    .PARAMETER Separator
    Emits a dedicated thin divider row instead of a labeled one, useful for visually grouping
    rows in a Record without hiding every row's border individually.

    .EXAMPLE
    graph {

        Record Components1 @(
            'Name'
            'Environment'
            'Test <I>[string]</I>'
        )

        Record Components2 {
            Row Name
            Row 'Environment <B>test</B>'
            'Test'
        }


        Edge Components1:Name -to Components2:Name

    } | Export-PSGraph -ShowGraph

    .NOTES
    Need to add attribute support

    DSL planned syntax
    # Row Label
    # Row Label -ID
    # Row Label Attributes
    # Row Label -ID Attributes

    #>
    [OutputType('System.String')]
    [cmdletbinding(DefaultParameterSetName = 'Default')]
    param(
        [Parameter(
            Mandatory,
            Position = 0,
            ValueFromPipeline,
            ParameterSetName = 'Default'
        )]
        [string]
        $Label,

        [Parameter(ParameterSetName = 'Default')]
        [alias('ID')]
        [string]
        $Name,

        [Parameter(ParameterSetName = 'Default')]
        [switch]
        $HtmlEncode,

        # Additional HTML attributes for this row's cell, e.g. @{BORDER = 0} to hide the row's border
        [Parameter(ParameterSetName = 'Default')]
        [hashtable]
        $Attributes = @{},

        # #81: emit a dedicated thin divider row instead of a labeled one
        [Parameter(Mandatory, ParameterSetName = 'Separator')]
        [switch]
        $Separator
    )
    process
    {
        if ( $Separator )
        {
            '<TR><TD BORDER="0" CELLPADDING="0" HEIGHT="1" BGCOLOR="gray"></TD></TR>'
            return
        }

        if ( [string]::IsNullOrEmpty($Name) )
        {
            if ($Label -notmatch '[<,>\s]')
            {
                $Name = $Label
            }
            else
            {
                $Name = New-Guid
            }
        }

        if ($Label -match '^<TR>.*</TR>?')
        {
            $Label
        }
        else
        {
            if ($HtmlEncode)
            {
                $Label = ([System.Net.WebUtility]::HtmlEncode($Label))
            }

            $extraAttributes = ($Attributes.GetEnumerator() | ForEach-Object { ' {0}="{1}"' -f $_.Key.ToString().ToUpper(), $_.Value }) -join ''

            '<TR><TD PORT="{0}" ALIGN="LEFT"{1}>{2}</TD></TR>' -f $Name, $extraAttributes, $Label
        }
    }
}