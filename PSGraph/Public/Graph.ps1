function Graph
{
    <#
        .SYNOPSIS
        Defines a graph, the base collection that holds all other graph elements.
        .Description
        Defines a graph. The base collection that holds all other graph elements

        .Example
        graph g {
            node top,left,right @{shape='rectangle'}
            rank left,right
            edge top left,right
        }

        .Example

        $dot = graph {
            edge hello world
        }

        .Example

        graph g -Strict {
            edge a b
            edge a b
        }

        -Strict emits 'strict digraph' so GraphViz merges the duplicate a->b edge into one.

        .Notes
        The output is a string so it can be saved to a variable or piped to other commands
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        "PSAvoidDefaultValueForMandatoryParameter", "",
        Justification = "Name and Attributes are each Mandatory only in the parameter sets where the
caller names/attributes the graph, but their defaults ('g' and @{}) also have to serve the
Default/Named sets, where the function body reads `$name and mutates `$Attributes unconditionally
to support unnamed 'graph { }' usage. Removing either default would break that unnamed-graph
support; it isn't an oversight."
    )]
    [CmdletBinding( DefaultParameterSetName = 'Default' )]
    [Alias( 'DiGraph' )]
    [OutputType( [string] )]
    param(

        # Name or ID of the graph
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ParameterSetName = 'Named',
            HelpMessage = 'Name or ID of the graph.'
        )]
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ParameterSetName = 'NamedAttributes',
            HelpMessage = 'Name or ID of the graph.'
        )]
        [string]
        $Name = 'g',

        # The commands to execute inside the graph
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ParameterSetName = 'Default',
            HelpMessage = 'Scriptblock containing the Node/Edge/etc. commands that define the graph.'
        )]
        [Parameter(
            Mandatory = $true,
            Position = 1,
            ParameterSetName = 'Named',
            HelpMessage = 'Scriptblock containing the Node/Edge/etc. commands that define the graph.'
        )]
        [Parameter(
            Mandatory = $true,
            Position = 1,
            ParameterSetName = 'Attributes',
            HelpMessage = 'Scriptblock containing the Node/Edge/etc. commands that define the graph.'
        )]
        [Parameter(
            Mandatory = $true,
            Position = 2,
            ParameterSetName = 'NamedAttributes',
            HelpMessage = 'Scriptblock containing the Node/Edge/etc. commands that define the graph.'
        )]
        [scriptblock]
        $ScriptBlock,

        # Hashtable that gets translated to graph attributes
        [Parameter(
            Mandatory = $true,
            Position = 1,
            ParameterSetName = 'NamedAttributes',
            HelpMessage = 'Hashtable of graph attributes, e.g. @{ compound = $true }.'
        )]
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ParameterSetName = 'Attributes',
            HelpMessage = 'Hashtable of graph attributes, e.g. @{ compound = $true }.'
        )]
        [hashtable]
        $Attributes = @{},

        # Keyword that initiates the graph
        [string]
        $Type = 'digraph',

        # Emits 'strict digraph'/'strict graph', which tells GraphViz to merge duplicate edges
        # instead of drawing them separately. Only meaningful on the top-level graph.
        [switch]
        $Strict
    )

    begin
    {
        try
        {
            Write-Verbose "Begin Graph $type $Name"
            if ($Type -eq 'digraph')
            {
                $script:indent = 0
                if (-not $Attributes.ContainsKey('compound'))
                {
                    $Attributes.compound = 'true'
                }
                $script:SubGraphList = @{}
            }

            $typeKeyword = if ( $Strict ) { "strict $Type" } else { $Type }
            "{0}{1} {2} {{" -f (Get-Indent), $typeKeyword, $name
            $script:indent++

            if ($null -ne $Attributes)
            {
                ConvertTo-GraphVizAttribute -Attributes $Attributes -UseGraphStyle
            }
        }
        catch
        {
            $PSCmdlet.ThrowTerminatingError( $PSitem )
        }
    }

    process
    {
        try
        {
            Write-Verbose "Process Graph $type $name"

            if ( $type -eq 'subgraph' )
            {
                $nodeName = $name.Replace('cluster', '')
                $script:SubGraphList[$nodeName] = $name
                Node $nodeName @{ shape = 'point'; style = 'invis'; label = '' }
            }

            & $ScriptBlock
        }
        catch
        {
            $PSCmdlet.ThrowTerminatingError( $PSitem )
        }
    }

    end
    {
        try
        {
            $script:indent--
            if ( $script:indent -lt 0 )
            {
                $script:indent = 0
            }
            "$(Get-Indent)}" # Close braces
            "" #Blank line
            Write-Verbose "End Graph $type $name"
        }
        catch
        {
            $PSCmdlet.ThrowTerminatingError( $PSitem )
        }
    }
}
