# Installing PSGraph
PSGraph requires PowerShell 7 or later (`pwsh`). Windows PowerShell 5.1 is not supported.

    # Install PSGraph from the Powershell Gallery
    Find-Module PSGraph | Install-Module

    # Install GraphViz - see Command-Install-GraphViz.md for details
    Import-Module PSGraph
    Install-GraphViz



# Generating your first graph

PSGraph has a unique syntax for defining a graph. This is because it was built specifically for the GraphViz engine. Here is a basic graph to get you started.

    # Import Module
    Import-Module PSGraph

    graph "myGraph" {
        edge start,middle,end        
    } | Export-PSGraph -ShowGraph

This will create a new graph with three nodes linking each other. 

[![Source](images/firstGraph.png)](images/firstGraph.png)

It will save it in the `$env:temp` folder because we did not specify a destination. It will then show the graph when it is done.
