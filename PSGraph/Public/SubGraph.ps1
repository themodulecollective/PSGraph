function SubGraph
{
    <#
        .SYNOPSIS
        Defines a graph nested inside another graph, to sub-group elements.
        .Description
        A graph that is nested inside another graph to sub group elements

        .Example
        graph g {
            node top,bottom @{shape='rect'}
            subgraph 0 {
                node left,right
            }
            edge top -to left,right
            edge left,right -to bottom
        }

        .Notes
        This is just like the graph or digraph, except the name must match cluster_#
        The numbering must start at 0 and work up or the processor will fail.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        "PSAvoidDefaultValueForMandatoryParameter", "",
        Justification = "Attributes is only Mandatory in the Attributes/NamedAttributes sets, but the
default (@{}) also has to serve the Default/Named sets, since it's passed to Graph unconditionally
regardless of parameter set. Removing the default would break unnamed/attribute-less subgraph usage;
it isn't an oversight."
    )]
    [cmdletbinding(DefaultParameterSetName = 'Default')]
    param(
        # Name of subgraph
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ParameterSetName = 'Named',
            HelpMessage = 'Name of the subgraph (must match cluster_# numbering, starting at 0).'
        )]
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ParameterSetName = 'NamedAttributes',
            HelpMessage = 'Name of the subgraph (must match cluster_# numbering, starting at 0).'
        )]
        [alias('ID')]
        $Name,

        # The commands to execute inside the subgraph
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ParameterSetName = 'Default',
            HelpMessage = 'Scriptblock containing the Node/Edge/etc. commands that define the subgraph.'
        )]
        [Parameter(
            Mandatory = $true,
            Position = 1,
            ParameterSetName = 'Named',
            HelpMessage = 'Scriptblock containing the Node/Edge/etc. commands that define the subgraph.'
        )]
        [Parameter(
            Mandatory = $true,
            Position = 1,
            ParameterSetName = 'Attributes',
            HelpMessage = 'Scriptblock containing the Node/Edge/etc. commands that define the subgraph.'
        )]
        [Parameter(
            Mandatory = $true,
            Position = 2,
            ParameterSetName = 'NamedAttributes',
            HelpMessage = 'Scriptblock containing the Node/Edge/etc. commands that define the subgraph.'
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
        $Attributes = @{}
    )

    process
    {
        try
        {
            if ( $null -eq $Name )
            {
                $name = ((New-Guid ) -split '-')[4]
            }

            Graph -Name "cluster$Name" -ScriptBlock $ScriptBlock -Attributes $Attributes -Type 'subgraph'
        }
        catch
        {
            $PSCmdlet.ThrowTerminatingError( $PSitem )
        }
    }
}
