# Install-GraphViz

PSGraph needs the GraphViz `dot` engine on `PATH` to render anything — `Export-PSGraph` just shells out to it. `Install-GraphViz` gets it installed without you having to know which package manager your platform uses.

    Install-GraphViz

On Windows this registers the Chocolatey package source (if it isn't already) and installs GraphViz through it. On macOS it runs `brew install graphviz`.

## Install-GraphViz -Scope [CurrentUser|AllUsers]

Registering Chocolatey and installing to the default `AllUsers` scope normally requires an elevated (admin) session. If you don't have admin rights, use `-Scope CurrentUser` to install to a per-user location instead.

    Install-GraphViz -Scope CurrentUser

`-Scope` is ignored on macOS — `brew` doesn't have an equivalent concept.

## Falling back when Chocolatey can't be registered

Registering the Chocolatey provider itself typically needs admin rights, independent of `-Scope`. If that registration fails, `Install-GraphViz` doesn't give up — it falls back to installing the (older) GraphViz package published on nuget.org instead, with a warning telling you it did so. Install Chocolatey yourself and re-run the command if you want the latest GraphViz build.

## Confirmation prompts

`Install-GraphViz` supports `-WhatIf` and `-Confirm` like any state-changing command, and prompts by default since it's installing software on your machine.

    Install-GraphViz -WhatIf
