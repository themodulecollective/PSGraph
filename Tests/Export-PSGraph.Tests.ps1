$projectRoot = Resolve-Path "$PSScriptRoot\.."
$moduleRoot = Split-Path (Resolve-Path "$projectRoot\*\*.psd1")
$moduleName = Split-Path $moduleRoot -Leaf

#Import-Module (Join-Path $moduleRoot "$moduleName.psm1") -force

# This one is not tagged with Build because it requires GraphViz
Describe "$ModuleName Export-PSGraph" -Tag graphviz {

    $dot = graph g {
        node 2 @{shape = 'house'}
        edge 2, 4, 8, 16
    }

    Context "Basic features" {

        It "Converts file to image" {
            $path = "$testdrive\g.dot"
            Set-Content -Path $path -Value $dot
            Export-PSGraph -SourcePath $path -OutputFormat png

            "$path.png" | Should Exist
        }

        It "Converts file to image over pipe" {
            $path = "$testdrive\g2.dot"
            Set-Content -Path $path -Value $dot
            $path | Export-PSGraph -OutputFormat png

            "$path.png" | Should Exist
        }
    }

    Context "#110 ShowGraph and destination path with spaces" {

        It "Exports to a destination path containing spaces without throwing" {
            $dir = Join-Path $testdrive "spaced dir"
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
            $path = Join-Path $dir "spaced graph.png"

            { Export-PSGraph -Source $dot -DestinationPath $path -ErrorAction Stop } | Should Not Throw

            $path | Should Exist
        }

        It "-ShowGraph launches a destination path containing spaces without throwing" {
            $dir = Join-Path $testdrive "spaced dir 2"
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
            $path = Join-Path $dir "spaced graph.png"

            { Export-PSGraph -Source $dot -DestinationPath $path -ShowGraph -ErrorAction Stop } | Should Not Throw

            $path | Should Exist
        }
    }

    Context "#97 BOM in generated DOT breaks dot's parser" {

        AfterEach {
            $OutputEncoding = [System.Text.UTF8Encoding]::new($false)
        }

        It "Exports successfully even when the caller's `$OutputEncoding would inject a BOM" {
            $OutputEncoding = [System.Text.UTF8Encoding]::new($true)
            $path = "$testdrive\bom.dot"

            { Export-PSGraph -Source $dot -DestinationPath $path -OutputFormat dot -ErrorAction Stop } | Should Not Throw

            $bytes = [System.IO.File]::ReadAllBytes($path)
            ($bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) | Should Be $false
        }
    }

    Context "#104 Non-ASCII characters in labels" {

        It "Round-trips accented/non-ASCII labels through dot without garbling" {
            $accented = graph g { node cafe @{label = 'héllo wörld'} }
            $path = "$testdrive\accented.dot"

            Export-PSGraph -Source $accented -DestinationPath $path -OutputFormat dot

            $text = [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)
            $text | Should Match 'héllo wörld'
        }
    }

    Context "#75 #88 #85 Graphviz path detection" {

        It "Finds dot via PATH when -GraphVizPath is not specified" {
            { Export-PSGraph -Source $dot -DestinationPath "$testdrive\pathlookup.png" -ErrorAction Stop } | Should Not Throw
        }

        It "Honors an explicitly-supplied -GraphVizPath instead of silently falling back to PATH" {
            { Export-PSGraph -Source $dot -DestinationPath "$testdrive\badpath.png" -GraphVizPath 'C:\does\not\exist\dot.exe' -ErrorAction Stop } | Should Throw
        }
    }
}
