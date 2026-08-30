
function Record
{
    <#
    .SYNOPSIS
    Creates a record object

    .DESCRIPTION
    Creates a record object that contains rows of data.

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


        Echo one two three | Record Fish
        Record Cow red,blue,green

    } | Export-PSGraph -ShowGraph

    .NOTES
    Early release version of this command.
    A lot of stuff is hard coded that should be exposed as attributes

    #>
    [OutputType('System.String')]
    [cmdletbinding(DefaultParameterSetName = 'Script')]
    param(
        # The node name for this record
        [Parameter(
            Mandatory,
            Position = 0,
            HelpMessage = "The node name for this record."
        )]
        [alias('ID', 'Node')]
        [string]
        $Name,

        # An array of strings/objects to place in this record
        [Parameter(
            Position = 1,
            ValueFromPipeline,
            ParameterSetName = 'Strings'
        )]
        [alias('Rows')]
        [Object[]]
        $Row,

        # A sub expression that contains Row commands
        [Parameter(
            Position = 1,
            ParameterSetName = 'Script'
        )]
        [ScriptBlock]
        $ScriptBlock,

        # A script to run on each row
        [Parameter(
            Position = 2
        )]
        [ScriptBlock]
        $RowScript,

        # The label to use for the header of the record
        [string]
        $Label,

        # HTML attributes for the outer <TABLE> element, e.g. @{ CELLBORDER = 0 } to hide
        # borders between every row in one call (#81). Defaults to today's fixed
        # CELLBORDER=1/BORDER=0/CELLSPACING=0 look.
        [hashtable]
        $TableAttributes = [ordered]@{ CELLBORDER = 1; BORDER = 0; CELLSPACING = 0 }
    )
    begin
    {
        $tableData = [System.Collections.ArrayList]::new()
        if ( [string]::IsNullOrEmpty($Label) )
        {
            $Label = $Name
        }
    }
    process
    {
        if ( $null -ne $ScriptBlock )
        {
            $Row = $ScriptBlock.Invoke()
        }

        if ( $null -ne $RowScript )
        {
            $Row = foreach ( $node in $Row )
            {
                @($node).ForEach($RowScript)
            }
        }

        $results = foreach ( $node in $Row )
        {
            Row -Label $node
        }

        foreach ( $node in $results )
        {
            [void]$tableData.Add($node)
        }
    }
    end
    {
        $tableAttributeCells = $TableAttributes.GetEnumerator() |
            ForEach-Object { ' {0}="{1}"' -f $_.Key.ToString().ToUpper(), $_.Value }
        $tableAttributeString = $tableAttributeCells -join ''
        $htmlFormat = '<TABLE{0}><TR><TD bgcolor="black" align="center">' +
            '<font color="white"><B>{1}</B></font></TD></TR>{2}</TABLE>'
        $html = $htmlFormat -f $tableAttributeString, $Label, ($tableData -join '')
        $nodeAttributes = @{
            label     = $html
            shape     = 'none'
            fontname  = "Courier New"
            style     = "filled"
            penwidth  = 1
            fillcolor = "white"
        }
        Node $Name $nodeAttributes
    }
}

