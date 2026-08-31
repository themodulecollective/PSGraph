# PSGraph

PSGraph is a PowerShell module that lets you script the generation of graphs using the GraphViz engine. It makes it easy to produce data-driven visualizations straight from PowerShell objects.

![basic graph](images/firstGraph.png)

---
### Install PSGraph from the PowerShell Gallery

    Find-Module PSGraph | Install-Module
    Import-Module PSGraph

### Install GraphViz

    # Chocolatey on Windows (nuget.org fallback for non-admin installs),
    # Homebrew on macOS, your distro's package manager on Linux
    Install-GraphViz

---

### Describe how items are connected

Using a custom DSL, describe how nodes are connected with edges

    Graph "myGraph" {
        Edge start -To middle
        Edge middle -To end
    }

---

### Export and show the Graph

Then we can render the graph as an image.

    Graph "myGraph" {
        Edge -From start -To middle
        Edge -From middle -To end
    }  | Export-PSGraph -ShowGraph

![firstGraph](images/firstGraph.png)

---

### Data driven graphs

The real fun starts when they are data driven — every example below pulls its shape from real PowerShell objects, not hand-typed node names.

---

### Example: Server farm topology

Describe how tiers of servers relate to each other.

    $WebServer = 1..2 | ForEach-Object {"Web_$_"}
    $APIServer = 1..2 | ForEach-Object {"API_$_"}
    $DatabaseServer = 1..2 | ForEach-Object {"DB_$_"}

    graph servers {
        node @{shape='box'}
        edge LoadBalancer -To $WebServer
        edge $WebServer -To $APIServer
        edge $APIServer -To AvailabilityGroup
        edge AvailabilityGroup -To $DatabaseServer
    } | Export-PSGraph -ShowGraph

![servers](images/pitchme-serverfarm.png)

---

### Example: Database schema

`Record`/`Row`/`Cells` build GraphViz's HTML-like table nodes — a natural fit for entity-relationship diagrams. `Cells -PortProperty` names a row so `Edge` can point straight at it.

    $customers = @(
        [pscustomobject]@{ Column='Id'; Type='int PK' }
        [pscustomobject]@{ Column='Name'; Type='nvarchar' }
        [pscustomobject]@{ Column='Email'; Type='nvarchar' }
    )
    $orders = @(
        [pscustomobject]@{ Column='Id'; Type='int PK' }
        [pscustomobject]@{ Column='CustomerId'; Type='int FK' }
        [pscustomobject]@{ Column='Total'; Type='money' }
    )

    graph schema {
        Record Customers -Rows ($customers | Cells -PortProperty Column)
        Record Orders -Rows ($orders | Cells -PortProperty Column)
        Edge 'Orders:CustomerId' -To 'Customers:Id'
    } | Export-PSGraph -ShowGraph

![schema](images/pitchme-schema.png)

---

### Example: Live process tree

Graph what's actually running right now, color-coded by memory use via `New-NodeAttributeSet`.

    $all = Get-Process
    $procs = $all | Where-Object {
        $_.Id -ne 0 -and $_.Parent -and ($all.Id -contains $_.Parent.Id)
    }

    graph processTree @{rankdir='LR'} {
        $procs | ForEach-Object {
            $color = if ($_.WorkingSet64 -gt 200MB) {'orangered'}
                     elseif ($_.WorkingSet64 -gt 50MB) {'gold'}
                     else {'palegreen'}
            $attrs = New-NodeAttributeSet -Style filled -FillColor $color
            $attrs.label = $_.ProcessName
            node $_.Id $attrs
        }
        edge $procs -FromScript {$_.Parent.Id} -ToScript {$_.Id}
    } | Export-PSGraph -ShowGraph

![process tree](images/pitchme-processtree.png)

---

### Example: Windows service dependencies

`Get-Service` already exposes each service's dependency graph — PSGraph just draws it.

    $services = Get-Service | Where-Object RequiredServices

    graph serviceDeps @{rankdir='LR'} {
        node @{shape='box'}
        $services | ForEach-Object {
            edge $_.Name -To $_.RequiredServices.Name
        }
    } | Export-PSGraph -ShowGraph

![service dependencies](images/pitchme-servicedeps.png)

---

### Example: PowerShell module dependencies

Dogfooding: walk installed modules' own `RequiredModules` and graph them.

    $modules = Get-Module -ListAvailable | Where-Object RequiredModules

    graph moduleDeps @{rankdir='LR'} {
        node @{shape='box'}
        $modules | ForEach-Object {
            edge $_.Name -To $_.RequiredModules.Name
        }
    } | Export-PSGraph -ShowGraph

![module dependencies](images/pitchme-moduledeps.png)

---

### Example: Export to any format in one line

`Export-PSGraph` ships a format-specific alias for every supported output — `svgGraph`, `pngGraph`, `pdfGraph`, `dotGraph`, and more.

    $dot = graph g { edge hello world }

    $dot | svgGraph -Destination out.svg
    $dot | pngGraph -Destination out.png
    $dot | pdfGraph -Destination out.pdf

![formats](images/pitchme-formats.png)

---

### More examples

* [Project structure](images/filesSmall.png) — a folder tree walked with `Get-ChildItem`
* [GraphViz gallery recreations](https://github.com/themodulecollective/PSGraph/blob/main/docs/Example-Gallery.md) — clusters, entity-relation diagrams, finite automata
* Full command reference and more scripted examples: [psgraph.readthedocs.io](http://psgraph.readthedocs.io)

---

### What will you graph?

* [psgraph.readthedocs.io](http://psgraph.readthedocs.io) — full documentation
* [github.com/themodulecollective/PSGraph](https://github.com/themodulecollective/PSGraph) — source, issues, and this fork's changelog
* `Get-Help about_PSGraph` — conceptual overview, right from your PowerShell prompt
