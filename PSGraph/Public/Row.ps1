function Row
{
    <#
    .SYNOPSIS
    Adds a row to a record

    .Description
    Adds a row to a record inside a PSGraph Graph

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
        # This is the displayed data for the row
        [Parameter(
            Mandatory,
            Position = 0,
            ValueFromPipeline,
            ParameterSetName = 'Default',
            HelpMessage = "This is the displayed data for the row."
        )]
        [string]
        $Label,

        # This is the target name of this row to be used in edges.
        # Will default to the label if the label has not special characters
        [Parameter(ParameterSetName = 'Default')]
        [alias('ID')]
        [string]
        $Name,

        # This will encode unintentional HTML. Characters like <>& would break html parsing if they
        # are contained in the source data.
        [Parameter(ParameterSetName = 'Default')]
        [switch]
        $HtmlEncode,

        # Additional HTML attributes for this row's cell, e.g. @{BORDER = 0} to hide the row's
        # border line, or @{BGCOLOR = 'lightgrey'} to shade it. Pass [ordered]@{...} if the
        # rendered attribute order matters to you.
        [Parameter(ParameterSetName = 'Default')]
        [hashtable]
        $Attributes = [ordered]@{},

        # #81: emit a dedicated thin divider row instead of a labeled one, useful for visually
        # grouping rows in a Record without hiding every row's border individually.
        [Parameter(
            Mandatory,
            ParameterSetName = 'Separator',
            HelpMessage = "Emit a dedicated thin divider row instead of a labeled one."
        )]
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

            $extraAttributeCells = $Attributes.GetEnumerator() |
                ForEach-Object { ' {0}="{1}"' -f $_.Key.ToString().ToUpper(), $_.Value }
            $extraAttributes = $extraAttributeCells -join ''

            '<TR><TD PORT="{0}" ALIGN="LEFT"{1}>{2}</TD></TR>' -f $Name, $extraAttributes, $Label
        }
    }
}