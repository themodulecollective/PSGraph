$projectRoot = Resolve-Path "$PSScriptRoot\.."
$moduleRoot = Split-Path (Resolve-Path "$projectRoot\*\*.psd1")
$moduleName = Split-Path $moduleRoot -Leaf

#Import-Module (Join-Path $moduleRoot "$moduleName.psm1") -force

# This one is not tagged with Build because it requires GraphViz
Describe "$ModuleName Export-PSGraph" -Tag graphviz {

    BeforeAll {
        $dot = graph g {
            node 2 @{shape = 'house'}
            edge 2, 4, 8, 16
        }
    }

    Context "Basic features" {

        It "Converts file to image" {
            $path = Join-Path $testdrive "g.dot"
            Set-Content -Path $path -Value $dot
            Export-PSGraph -SourcePath $path -OutputFormat png

            "$path.png" | Should -Exist
        }

        It "Converts file to image over pipe" {
            $path = Join-Path $testdrive "g2.dot"
            Set-Content -Path $path -Value $dot
            $path | Export-PSGraph -OutputFormat png

            "$path.png" | Should -Exist
        }
    }

    Context "#110 ShowGraph and destination path with spaces" {

        It "Exports to a destination path containing spaces without throwing" {
            $dir = Join-Path $testdrive "spaced dir"
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
            $path = Join-Path $dir "spaced graph.png"

            { Export-PSGraph -Source $dot -DestinationPath $path -ErrorAction Stop } | Should -Not -Throw

            $path | Should -Exist
        }

        It "-ShowGraph launches a destination path containing spaces without throwing" {
            $dir = Join-Path $testdrive "spaced dir 2"
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
            $path = Join-Path $dir "spaced graph.png"

            { Export-PSGraph -Source $dot -DestinationPath $path -ShowGraph -ErrorAction Stop } | Should -Not -Throw

            $path | Should -Exist
        }
    }

    Context "#97 BOM in generated DOT breaks dot's parser" {

        AfterEach {
            $OutputEncoding = [System.Text.UTF8Encoding]::new($false)
        }

        It "Exports successfully even when the caller's `$OutputEncoding would inject a BOM" {
            $OutputEncoding = [System.Text.UTF8Encoding]::new($true)
            $path = Join-Path $testdrive "bom.dot"

            { Export-PSGraph -Source $dot -DestinationPath $path -OutputFormat dot -ErrorAction Stop } | Should -Not -Throw

            $bytes = [System.IO.File]::ReadAllBytes($path)
            ($bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) | Should -Be $false
        }
    }

    Context "#104 Non-ASCII characters in labels" {

        It "Round-trips accented/non-ASCII labels through dot without garbling" {
            $accented = graph g { node cafe @{label = 'héllo wörld'} }
            $path = Join-Path $testdrive "accented.dot"

            Export-PSGraph -Source $accented -DestinationPath $path -OutputFormat dot

            $text = [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)
            $text | Should -Match 'héllo wörld'
        }
    }

    Context "#75 #88 #85 Graphviz path detection" {

        It "Finds dot via PATH when -GraphVizPath is not specified" {
            { Export-PSGraph -Source $dot -DestinationPath (Join-Path $testdrive "pathlookup.png") -ErrorAction Stop } | Should -Not -Throw
        }

        It "Honors an explicitly-supplied -GraphVizPath instead of silently falling back to PATH" {
            { Export-PSGraph -Source $dot -DestinationPath (Join-Path $testdrive "badpath.png") -GraphVizPath 'C:\does\not\exist\dot.exe' -ErrorAction Stop } | Should -Throw
        }
    }

    Context "PR #105 -PassThru stdout/SVG export" {

        It "Returns the rendered graph as text instead of writing a file" {
            $tempCountBefore = (Get-ChildItem ([System.IO.Path]::GetTempPath()) -Filter '*.svg' -ErrorAction SilentlyContinue).Count

            $result = $dot | Export-PSGraph -OutputFormat svg -PassThru

            $result | Should -Not -BeNullOrEmpty
            ($result -join "`n") | Should -Match '<svg'

            $tempCountAfter = (Get-ChildItem ([System.IO.Path]::GetTempPath()) -Filter '*.svg' -ErrorAction SilentlyContinue).Count
            $tempCountAfter | Should -Be $tempCountBefore
        }

        It "Throws when combined with -DestinationPath" {
            $path = Join-Path $testdrive "passthru-destination.svg"
            { $dot | Export-PSGraph -OutputFormat svg -PassThru -DestinationPath $path -ErrorAction Stop } | Should -Throw
        }

        It "Throws when combined with -ShowGraph" {
            { $dot | Export-PSGraph -OutputFormat svg -PassThru -ShowGraph -ErrorAction Stop } | Should -Throw
        }

        It "Throws when Source is a file path rather than inline DOT text" {
            $path = Join-Path $testdrive "passthru-source.dot"
            Set-Content -Path $path -Value $dot
            { Export-PSGraph -SourcePath $path -OutputFormat svg -PassThru -ErrorAction Stop } | Should -Throw
        }
    }

    Context "Phase 5 format-specific export aliases" {

        It "svgGraph infers -OutputFormat svg" {
            $result = $dot | svgGraph -PassThru
            ($result -join "`n") | Should -Match '<svg'
        }

        It "dotGraph infers -OutputFormat dot" {
            $result = $dot | dotGraph -PassThru
            ($result -join "`n") | Should -Match 'digraph'
        }

        It "an explicit -OutputFormat still overrides the alias-inferred one" {
            $result = $dot | pngGraph -OutputFormat svg -PassThru
            ($result -join "`n") | Should -Match '<svg'
        }
    }

    Context "PR #112 non-admin Install-GraphViz install locations" {

        It "Includes the Install-GraphViz -Scope CurrentUser NuGet package location in the default search paths" {
            $ast = (Get-Command Export-PSGraph).ScriptBlock.Ast
            $paramAst = $ast.Find({ $args[0] -is [System.Management.Automation.Language.ParameterAst] -and $args[0].Name.VariablePath.UserPath -eq 'GraphVizPath' }, $true)

            $paramAst.DefaultValue.Extent.Text | Should -Match 'PackageManagement\\NuGet\\Packages\\Graphviz'
        }

        It "Mentions -Scope CurrentUser in the not-found error message" {
            { Export-PSGraph -Source $dot -DestinationPath (Join-Path $testdrive "notfound.png") -GraphVizPath 'C:\does\not\exist\dot.exe' -ErrorAction Stop } |
                Should -Throw -ExpectedMessage '*-Scope CurrentUser*'
        }
    }
}
