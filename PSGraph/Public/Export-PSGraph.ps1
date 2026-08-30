function Export-PSGraph
{
    <#
        .SYNOPSIS
        Invokes the GraphViz binaries to render a graph to a file or as text.
        .Description
        Invokes the graphviz binaries to generate a graph.
        .PARAMETER Source
        The GraphViz file to process or contents of the graph in Dot notation
        .PARAMETER DestinationPath
        The destination for the generated file.
        .PARAMETER OutputFormat
        The file type used when generating an image
        .PARAMETER LayoutEngine
        The layout engine used to generate the image
        .PARAMETER GraphVizPath
        Path or paths to the dot graphviz executable. Some sensible defaults are used if nothing is passed.
        .PARAMETER ShowGraph
        Launches the graph when done
        .PARAMETER PassThru
        Returns the rendered graph as text instead of writing it to a file. Useful for
        piping SVG/DOT output into a notebook workflow (e.g. Jupyter/.NET Interactive).
        Only supported when Source is inline DOT text (not a file path), and cannot be
        combined with -DestinationPath or -ShowGraph.
        .Example
        Export-PSGraph -Source graph.dot -OutputFormat png

        .Example
        graph g {
            edge (3..6)
            edge (5..2)
        } | Export-PSGraph -Destination $env:temp\test.png

        .Example
        graph g {
            edge hello world
        } | Export-PSGraph -OutputFormat svg -PassThru

        .Example
        graph g {
            edge hello world
        } | svgGraph -PassThru

        Format-specific aliases (pngGraph, svgGraph, dotGraph, etc., one per -OutputFormat
        value) call Export-PSGraph with -OutputFormat inferred from the alias name, unless
        -OutputFormat is passed explicitly.

        .Notes
        The source can either be files or piped graph data.

        It checks the piped data for file paths. If it cannot find a file, it assumes it is graph data.
        This may give unexpected errors when the file does not exist.
    #>
    [cmdletbinding()]
    [Alias(
        'jpgGraph', 'pngGraph', 'gifGraph', 'imapGraph', 'cmapxGraph',
        'jp2Graph', 'jsonGraph', 'pdfGraph', 'plainGraph', 'dotGraph', 'svgGraph'
    )]
    param(
        # The GraphViz file to process or contents of the graph in Dot notation
        [Parameter(
            ValueFromPipeline = $true
        )]
        [Alias('InputObject', 'Graph', 'SourcePath')]
        [string[]]
        $Source,

        #The destination for the generated file.
        [Parameter(
            Position = 0
        )]
        [string]
        $DestinationPath,

        # The file type used when generating an image
        [ValidateSet('jpg', 'png', 'gif', 'imap', 'cmapx', 'jp2', 'json', 'pdf', 'plain', 'dot', 'svg')]
        [string]
        $OutputFormat = 'png',

        # The layout engine used to generate the image
        [ValidateSet(
            'Hierarchical',
            'SpringModelSmall' ,
            'SpringModelMedium',
            'SpringModelLarge',
            'Radial',
            'Circular',
            'dot',
            'neato',
            'fdp',
            'sfdp',
            'twopi',
            'circo'
        )]
        [string]
        $LayoutEngine,

        [Parameter()]
        [string[]]
        $GraphVizPath = (
            'C:\Program Files\NuGet\Packages\Graphviz*\dot.exe',
            # Install-GraphViz -Scope CurrentUser location
            "$env:USERPROFILE\AppData\Local\PackageManagement\NuGet\Packages\Graphviz*\dot.exe",
            'C:\program files*\GraphViz*\bin\dot.exe',
            '/usr/local/bin/dot',
            '/usr/bin/dot'
        ),

        # launches the graph when done
        [switch]
        $ShowGraph,

        # returns the rendered graph as text instead of writing it to a file
        [switch]
        $PassThru
    )

    begin
    {
        try
        {
            # Invoked through a format-specific alias (pngGraph, svgGraph, ...) and no
            # explicit -OutputFormat was passed: infer it from the alias name. Both the
            # local variable (used below for the temp-file extension) and
            # $PSBoundParameters (what Get-GraphVizArgument actually reads) must be set.
            $formatAliasPattern = '^(?<format>jpg|png|gif|imap|cmapx|jp2|json|pdf|plain|dot|svg)Graph$'
            if ( -Not $PSBoundParameters.ContainsKey('OutputFormat') -and
                $MyInvocation.InvocationName -match $formatAliasPattern )
            {
                $OutputFormat = $Matches.format
                $PSBoundParameters['OutputFormat'] = $OutputFormat
            }

            if ( $PassThru )
            {
                if ( $PSBoundParameters.ContainsKey('DestinationPath') -and
                    -Not [string]::IsNullOrEmpty($DestinationPath) )
                {
                    throw '-PassThru cannot be combined with -DestinationPath; PassThru returns ' +
                        'the rendered graph instead of writing a file.'
                }
                if ( $ShowGraph )
                {
                    throw '-PassThru cannot be combined with -ShowGraph; there is no destination ' +
                        'file to show when the graph is returned as text.'
                }
            }

            $graphViz = $null

            # Unless the caller explicitly pinned a path, prefer a cross-platform
            # PATH lookup (works regardless of install location/OS).
            if ( -Not $PSBoundParameters.ContainsKey('GraphVizPath') )
            {
                $graphViz = Get-Command -Name 'dot' -CommandType Application -ErrorAction SilentlyContinue |
                    Select-Object -First 1
            }

            if ( $null -eq $graphViz )
            {
                # Use Resolve-Path to test all passed/default paths
                # Select only items with 'dot' BaseName and use first one
                $graphViz = Resolve-Path -path $GraphVizPath -ErrorAction SilentlyContinue |
                    Get-Item |
                    Where-Object BaseName -eq 'dot' |
                    Select-Object -First 1
            }

            if ( $null -eq $graphViz )
            {
                $GraphvizPathString = $GraphVizPath -Join " or "
                throw "Could not find GraphViz installed on this system. Please run " +
                    "'Install-GraphViz' (or 'Install-GraphViz -Scope CurrentUser' if you don't " +
                    "have admin rights) to install the needed binaries and libraries. This " +
                    "module looked for a 'dot' executable on PATH and in the following paths: " +
                    "$($GraphvizPathString). Optionally pass a path to your dot.exe file with " +
                    "the GraphVizPath parameter"
            }

            $useStandardInput = $false
            $standardInput = [System.Text.StringBuilder]::new()

            # Pipe DOT source to graphviz as UTF-8 without a BOM, regardless of the
            # caller's ambient $OutputEncoding (a BOM here breaks dot's parser).
            $OutputEncoding = [System.Text.UTF8Encoding]::new($false)
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
            if ( $null -ne $Source -and $Source.Count -gt 0 )
            {
                # if $Source is a list of files, process each one
                $fileList = $null

                # Only resolve paths, if there are NO empty string entries in the $Source
                # Resolve-path spits out an error with empty string paths, even with SilentlyContinue
                if ( @( $Source | Where-Object { [String]::IsNullOrEmpty($_) } ).Count -eq 0 )
                {
                    try
                    {
                        $fileList = Resolve-Path -Path $Source -ErrorAction Stop
                    }
                    catch
                    {
                        # I don't care that it isn't a file, I'll do something else with the data
                        $fileList = $null
                    }
                }

                if ( $null -ne $fileList -and $Source.Count -gt 0 )
                {
                    if ( $PassThru )
                    {
                        throw '-PassThru is only supported when Source is inline DOT text, not a file path.'
                    }

                    foreach ( $file in $fileList )
                    {
                        Write-Verbose "Generating graph from '$($file.path)'"
                        $arguments = Get-GraphVizArgument -InputObject $PSBoundParameters
                        $null = & $graphViz @($arguments + $file.path)
                        if ($LastExitCode)
                        {
                            $writeErrorSplat = @{
                                ErrorAction = 'Stop'
                                Exception   = [System.Management.Automation.ParseException]::New()
                            }
                            Write-Error @writeErrorSplat
                        }
                    }
                }
                else
                {
                    Write-Debug 'Using standard input to process graph'
                    $useStandardInput = $true
                    [void]$standardInput.AppendLine($Source)
                }
            }
        }
        catch
        {
            $PSCmdlet.ThrowTerminatingError($PSitem)
        }
    }

    end
    {
        try
        {

            if ( $useStandardInput )
            {
                Write-Verbose 'Processing standard input'
                if ( -Not $PSBoundParameters.ContainsKey( 'DestinationPath' ) -and -Not $PassThru )
                {
                    Write-Verbose '  Creating temporary path to save graph'

                    if ( $standardInput[0] -match 'graph\s+(?<filename>.+)\s+{' )
                    {
                        $file = $Matches.filename
                    }
                    else
                    {
                        $file = [System.IO.Path]::GetRandomFileName()
                    }
                    $tempDirectory = [system.io.path]::GetTempPath()
                    $PSBoundParameters["DestinationPath"] = Join-Path $tempDirectory "$file.$OutputFormat"
                }

                $arguments = Get-GraphVizArgument $PSBoundParameters
                Write-Verbose " Arguments: $($arguments -join ' ')"

                if ( $PSVersionTable.PSEdition -eq 'Desktop' )
                {
                    # Windows PowerShell's native-command pipeline encodes piped stdin using
                    # console-codepage-dependent translation that can make dot exit nonzero;
                    # write to a temp file instead, matching how file-based -Source input is
                    # already handled above. PowerShell 7+ doesn't need this workaround.
                    $tempFileName = "$([System.IO.Path]::GetRandomFileName()).dot"
                    $tempDotPath = Join-Path ([System.IO.Path]::GetTempPath()) $tempFileName
                    try
                    {
                        $utf8NoBom = [System.Text.UTF8Encoding]::new($false)
                        [System.IO.File]::WriteAllText($tempDotPath, $standardInput.ToString(), $utf8NoBom)

                        # @($arguments) forces array context: a single-flag $arguments (e.g. just
                        # -Tsvg when -PassThru omits -o) would otherwise collapse to a scalar string,
                        # making '+' concatenate the path onto the flag instead of appending an argument.
                        $result = & $graphViz @(@($arguments) + $tempDotPath)
                    }
                    finally
                    {
                        Remove-Item -Path $tempDotPath -ErrorAction SilentlyContinue
                    }
                }
                else
                {
                    $result = $standardInput.ToString() | & $graphViz @($arguments)
                }

                if ($LastExitCode)
                {
                    $writeErrorSplat = @{
                        ErrorAction = 'Stop'
                        Exception   = [System.Management.Automation.ParseException]::New()
                    }
                    Write-Error @writeErrorSplat
                }

                if ( $PassThru )
                {
                    return $result
                }

                if ( $ShowGraph )
                {
                    # Launches image with default viewer as decided by explorer
                    Write-Verbose "Launching $($PSBoundParameters["DestinationPath"])"
                    Invoke-Item -Path $PSBoundParameters["DestinationPath"]
                }

                Get-ChildItem $PSBoundParameters["DestinationPath"]
            }
        }
        catch
        {
            $PSCmdlet.ThrowTerminatingError($PSitem)
        }
    }
}
