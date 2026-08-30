function Rank
{
    <#
        .SYNOPSIS
        Places specified nodes at the same level on the chart.
        .Description
        Places specified nodes at the same level on the chart as a way to give some guidance to node layout

        .Example
        graph g {
            rank 1,3,5,7
            rank 2,4,6,8
            edge (1..8)
        }

        .Example
        $odd = @(1,3,5,7)
        $even = @(2,4,6,8)

        graph g {
            rank $odd
            rank $even
            edge $odd -to $even
        }

        .Example
        graph g {
            rank 1,2,3 -RankType min
            edge (1..3)
        }

        .Notes
        Accepts an array of items or a list of strings.
    #>

    [cmdletbinding()]
    param(

        # List of nodes to be on the same level as each other
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            Position = 0,
            HelpMessage = 'The nodes to place at the same rank/level.'
        )]
        [object[]]
        $Nodes,

        # Used to catch alternate style of specifying nodes
        [Parameter(
            ValueFromRemainingArguments = $true,
            Position = 1
        )]
        [object[]]
        $AdditionalNodes,

        # Script to run on each node
        [alias('Script')]
        [scriptblock]
        $NodeScript = {$_},

        # GraphViz rank type used to constrain the relative layout of this node set
        [ValidateSet('same', 'min', 'source', 'max', 'sink')]
        [string]
        $RankType = 'same'
    )

    begin
    {
        $values = [System.Collections.Generic.List[object]]::new()
    }

    process
    {
        try
        {

            $itemList = [System.Collections.Queue]::new()
            if ( $null -ne $Nodes )
            {
                $Nodes | ForEach-Object {$_} | ForEach-Object {$itemList.Enqueue($_)}
            }
            if ( $null -ne $AdditionalNodes )
            {
                $AdditionalNodes | ForEach-Object {$_} | ForEach-Object {$_} |
                    ForEach-Object {$itemList.Enqueue($_)}
            }

            $itemsThisCall = foreach ($item in $itemList)
            {
                # Adding these arrays ceates an empty element that we want to exclude
                if ( -Not [string]::IsNullOrWhiteSpace( $item ) )
                {
                    if ( $NodeScript )
                    {
                        $nodeName = [string]( @( $item ).ForEach( $NodeScript ) )
                    }
                    else
                    {
                        $nodeName = $item
                    }

                    Format-Value $nodeName -Node
                }
            }
            $values.AddRange(@($itemsThisCall))
        }
        catch
        {
            $PSCmdlet.ThrowTerminatingError( $PSitem )
        }
    }

    end
    {
        '{0}{{ rank={1};  {2}; }}' -f (Get-Indent), $RankType, ($values -join '; ')
    }
}
