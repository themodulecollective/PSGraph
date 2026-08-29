# Rank

The rank keyword groups object to the same level.

## Rank [string[]]

nodes get placed wherever the engine things is best. The rank command allows you to give it some more layout guidance.

    graph g {
        rank web1,web2,reports
        edge loadBalancer -To web1,web2
        edge user -To loadBalancer,reports
        edge web1,web2,reports -To database
    }

Here is the image without the rank:

[![Source](images/norank.png)](images/norank.png)

Here it is with the rank:

[![Source](images/withRank.png)](images/withRank.png)

## Rank [object[]] -NodeScript [scriptblock]
Just like with the node and edge commands, you can provide an object and script the properties.

graph g {
    rank $csv -NodeScript {$_.UserName}
}

This was added just to be consistent with the other commands.

## Rank [string[]] -RankType [same|min|source|max|sink]

By default, `rank` places the given nodes at the *same* level. GraphViz supports other rank constraints too, and `-RankType` exposes them:

* `same` (default) - all nodes at the same level
* `min` - nodes placed at the minimum rank
* `source` - like `min`, but also constrains them to be rendered at the top/left
* `max` - nodes placed at the maximum rank
* `sink` - like `max`, but also constrains them to be rendered at the bottom/right

    graph g {
        rank 1,2,3 -RankType min
        edge (1..3)
    }
