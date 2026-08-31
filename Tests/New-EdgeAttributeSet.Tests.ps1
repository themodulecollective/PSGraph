Describe 'Function New-EdgeAttributeSet' -Tag Build {

    Context "Unit Tests" {

        It "Does not throw an error" {
            { New-EdgeAttributeSet } | Should -Not -Throw
        }

        It "Returns an empty hashtable when nothing is specified" {
            (New-EdgeAttributeSet).Count | Should -Be 0
        }

        It "EdgeAttributes alias resolves to the same command" {
            (Get-Alias EdgeAttributes).ResolvedCommand.Name | Should -Be 'New-EdgeAttributeSet'
        }
    }

    Context "Renamed attributes" {

        It "Maps -Direction to 'dir', lowercased" {
            (New-EdgeAttributeSet -Direction Both).dir | Should -Be 'both'
        }

        It "Maps -Length to 'len'" {
            (New-EdgeAttributeSet -Length 2.5).len | Should -Be 2.5
        }
    }

    Context "Lowercased string attributes" {

        It "Lowercases -ArrowHead, -ArrowTail and -Color" {
            $result = New-EdgeAttributeSet -ArrowHead Crow -ArrowTail Lcrow -Color Blue

            $result.arrowhead | Should -Be 'crow'
            $result.arrowtail | Should -Be 'lcrow'
            $result.color | Should -Be 'blue'
        }

        It "Lowercases -FontColor, -LabelFontColor and -Style" {
            $result = New-EdgeAttributeSet -FontColor Green -LabelFontColor Red -Style Dashed

            $result.fontcolor | Should -Be 'green'
            $result.labelfontcolor | Should -Be 'red'
            $result.style | Should -Be 'dashed'
        }
    }

    Context "Passed-through numeric/free-form attributes (#105 upstream bug: .ToLower() on non-strings)" {

        It "Accepts -ArrowSize, -FontSize and -LabelFontSize without throwing (double)" {
            { New-EdgeAttributeSet -ArrowSize 1.5 -FontSize 10 -LabelFontSize 8 } | Should -Not -Throw
        }

        It "Accepts -Constraint without throwing (bool)" {
            { New-EdgeAttributeSet -Constraint $false } | Should -Not -Throw
        }

        It "Preserves case for -FontName, -Label, -HeadLabel and -TailLabel" {
            $result = New-EdgeAttributeSet -FontName 'Courier New' -Label 'MyLabel' -HeadLabel 'Head' -TailLabel 'Tail'

            $result.fontname | Should -Be 'Courier New'
            $result.label | Should -Be 'MyLabel'
            $result.headlabel | Should -Be 'Head'
            $result.taillabel | Should -Be 'Tail'
        }
    }

    Context "Phase 8 additions" {

        It "Accepts -Weight and -MinLen without throwing (numeric)" {
            { New-EdgeAttributeSet -Weight 2.5 -MinLen 2 } | Should -Not -Throw
            (New-EdgeAttributeSet -Weight 2.5).weight | Should -Be 2.5
            (New-EdgeAttributeSet -MinLen 2).minlen | Should -Be 2
        }

        It "Preserves case for -Tooltip and -XLabel" {
            $result = New-EdgeAttributeSet -Tooltip 'MyTip' -XLabel 'MyXLabel'
            $result.tooltip | Should -Be 'MyTip'
            $result.xlabel | Should -Be 'MyXLabel'
        }

        It "-URL and its -Href alias both bind to the same 'url' key" {
            (New-EdgeAttributeSet -URL 'https://example.com').url | Should -Be 'https://example.com'
            (New-EdgeAttributeSet -Href 'https://example.com').url | Should -Be 'https://example.com'
        }

        It "Renders -Weight and -URL in DOT output via Edge" {
            $dot = (graph g { edge one two (New-EdgeAttributeSet -Weight 3 -URL 'https://example.com') }) -join "`n"
            $dot | Should -Match 'weight="3"'
            $dot | Should -Match 'URL="https://example.com"'
        }
    }

    Context "Integration with Edge" {

        It "Merges cleanly into Edge's -Attributes and renders in the DOT output" {
            $dot = (graph g { edge one two (New-EdgeAttributeSet -Style dashed -Color blue) }) -join "`n"

            $dot | Should -Match 'style="dashed"'
            $dot | Should -Match 'color="blue"'
        }
    }
}
