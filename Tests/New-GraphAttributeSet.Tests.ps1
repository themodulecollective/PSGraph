Describe 'Function New-GraphAttributeSet' -Tag Build {

    Context "Unit Tests" {

        It "Does not throw an error" {
            { New-GraphAttributeSet } | Should -Not -Throw
        }

        It "Returns an empty hashtable when nothing is specified" {
            (New-GraphAttributeSet).Count | Should -Be 0
        }

        It "GraphAttributes alias resolves to the same command" {
            (Get-Alias GraphAttributes).ResolvedCommand.Name | Should -Be 'New-GraphAttributeSet'
        }
    }

    Context "-RankDir keeps its required uppercase form" {

        It "Passes 'LR' through unchanged (rankdir is not a lowercase attribute)" {
            (New-GraphAttributeSet -RankDir LR).rankdir | Should -Be 'LR'
        }

        It "Accepts TB, LR, BT and RL" {
            foreach ($direction in 'TB', 'LR', 'BT', 'RL')
            {
                { New-GraphAttributeSet -RankDir $direction } | Should -Not -Throw
            }
        }
    }

    Context "Lowercased string attributes" {

        It "Lowercases -BgColor, -FontColor, -Splines and -Style" {
            $result = New-GraphAttributeSet -BgColor LightYellow -FontColor Green -Splines Curved -Style Radial

            $result.bgcolor | Should -Be 'lightyellow'
            $result.fontcolor | Should -Be 'green'
            $result.splines | Should -Be 'curved'
            $result.style | Should -Be 'radial'
        }

        It "Lowercases -ColorScheme" {
            (New-GraphAttributeSet -ColorScheme 'Blues9').colorscheme | Should -Be 'blues9'
        }
    }

    Context "Passed-through numeric/free-form attributes" {

        It "Accepts -NodeSep, -RankSep, -FontSize and -GradientAngle without throwing (double)" {
            { New-GraphAttributeSet -NodeSep 0.5 -RankSep 1 -FontSize 12 -GradientAngle 45 } | Should -Not -Throw
        }

        It "Preserves case for -Label, -Ratio and -Size" {
            $result = New-GraphAttributeSet -Label 'MyGraph' -Ratio 'fill' -Size '8,8!'
            $result.label | Should -Be 'MyGraph'
            $result.ratio | Should -Be 'fill'
            $result.size | Should -Be '8,8!'
        }
    }

    Context "-Concentrate switch and -Compound bool" {

        It "Sets concentrate = true when specified" {
            (New-GraphAttributeSet -Concentrate).concentrate | Should -Be $true
        }

        It "Omits 'concentrate' when not specified" {
            (New-GraphAttributeSet).ContainsKey('concentrate') | Should -Be $false
        }

        It "Sets compound explicitly, including an explicit false" {
            (New-GraphAttributeSet -Compound $true).compound | Should -Be $true
            (New-GraphAttributeSet -Compound $false).compound | Should -Be $false
        }
    }

    Context "Integration with Graph" {

        It "Merges cleanly into Graph's -Attributes and renders in the DOT output" {
            $attrs = New-GraphAttributeSet -RankDir LR -BgColor lightyellow
            $dot = (graph g -Attributes $attrs {}) -join "`n"

            $dot | Should -Match 'rankdir="LR"'
            $dot | Should -Match 'bgcolor="lightyellow"'
        }

        It "An explicit -Compound `$false is respected, not silently overridden back to true (#98)" {
            $attrs = New-GraphAttributeSet -Compound $false
            $dot = (graph g -Attributes $attrs {}) -join "`n"

            $dot | Should -Match 'compound="False"'
        }
    }
}
