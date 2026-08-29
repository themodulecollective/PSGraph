$projectRoot = Resolve-Path "$PSScriptRoot\.."
$moduleRoot = Split-Path (Resolve-Path "$projectRoot\*\*.psd1")
$moduleName = Split-Path $moduleRoot -Leaf

Describe "Function Cells" -Tag Build {

    BeforeEach {
        $objects = @(
            [pscustomobject]@{ Name = 'first'; Value = 1 }
            [pscustomobject]@{ Name = 'second'; Value = 2 }
        )
    }

    It 'does not throw' {
        { $objects | Cells } | Should -Not -Throw
    }

    It 'emits a header row followed by one row per object' {
        $result = $objects | Cells

        $result.Count | Should -Be 3
        $result[0] | Should -Be '<TR><TD ALIGN="LEFT"><B>Name</B></TD><TD ALIGN="LEFT"><B>Value</B></TD></TR>'
        $result[1] | Should -Be '<TR><TD ALIGN="LEFT">first</TD><TD ALIGN="LEFT">1</TD></TR>'
        $result[2] | Should -Be '<TR><TD ALIGN="LEFT">second</TD><TD ALIGN="LEFT">2</TD></TR>'
    }

    It 'skips the header row with -NoHeader' {
        $result = $objects | Cells -NoHeader

        $result.Count | Should -Be 2
        $result[0] | Should -Not -Match '<B>'
    }

    It 'filters columns with -Properties' {
        $result = $objects | Cells -Properties Name

        $result[0] | Should -Be '<TR><TD ALIGN="LEFT"><B>Name</B></TD></TR>'
    }

    It 'filters columns with -ExcludeProperty' {
        $result = $objects | Cells -ExcludeProperty Value

        $result[0] | Should -Be '<TR><TD ALIGN="LEFT"><B>Name</B></TD></TR>'
    }

    It 'tags the -PortProperty column with a PORT attribute' {
        $result = $objects | Cells -PortProperty Name

        $result[1] | Should -Match '<TD PORT="first" ALIGN="LEFT">first</TD>'
    }

    It 'applies -Align to every cell' {
        $result = $objects | Cells -Align CENTER

        $result[0] | Should -Match 'ALIGN="CENTER"'
        $result[1] | Should -Match 'ALIGN="CENTER"'
    }

    It 'HTML-encodes cell values with -HtmlEncode' {
        $htmlObjects = @([pscustomobject]@{ Name = '<b>x</b>' })
        $result = $htmlObjects | Cells -HtmlEncode -NoHeader

        $result | Should -Match '&lt;b&gt;x&lt;/b&gt;'
    }

    Context "Integration with Record" {

        It 'combines with Record to render objects as table rows' {
            $localObjects = $objects
            $dot = graph g {
                $rows = $localObjects | Cells
                Record Objects -Row $rows
            }

            ($dot -join "`n") | Should -Match '<B>Name</B>'
            ($dot -join "`n") | Should -Match '<TD ALIGN="LEFT">first</TD>'
            ($dot -join "`n") | Should -Match '<TD ALIGN="LEFT">second</TD>'
        }
    }
}
