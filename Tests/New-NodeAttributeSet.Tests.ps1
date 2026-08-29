Describe 'Function New-NodeAttributeSet' -Tag Build {

    Context "Unit Tests" {

        It "Does not throw an error" {
            { New-NodeAttributeSet } | Should -Not -Throw
        }

        It "Returns an empty hashtable when nothing is specified" {
            (New-NodeAttributeSet).Count | Should -Be 0
        }

        It "NodeAttributes alias resolves to the same command" {
            (Get-Alias NodeAttributes).ResolvedCommand.Name | Should -Be 'New-NodeAttributeSet'
        }
    }

    Context "Lowercased string attributes" {

        It "Lowercases -Color" {
            (New-NodeAttributeSet -Color Blue).color | Should -Be 'blue'
        }

        It "Lowercases -Shape" {
            (New-NodeAttributeSet -Shape Box).shape | Should -Be 'box'
        }

        It "Lowercases -FillColor, -FontColor, -FixedSize and -Style" {
            $result = New-NodeAttributeSet -FillColor Red -FontColor Green -FixedSize True -Style Filled

            $result.fillcolor | Should -Be 'red'
            $result.fontcolor | Should -Be 'green'
            $result.fixedsize | Should -Be 'true'
            $result.style | Should -Be 'filled'
        }
    }

    Context "Passed-through numeric/free-form attributes (#105 upstream bug: .ToLower() on non-strings)" {

        It "Accepts -FontSize without throwing (double)" {
            { New-NodeAttributeSet -FontSize 12 } | Should -Not -Throw
            (New-NodeAttributeSet -FontSize 12).fontsize | Should -Be 12
        }

        It "Accepts -Height/-Width without throwing (double)" {
            { New-NodeAttributeSet -Height 1.5 -Width 2.5 } | Should -Not -Throw
        }

        It "Accepts -Sides without throwing (int16)" {
            { New-NodeAttributeSet -Sides 6 } | Should -Not -Throw
        }

        It "Preserves case for -FontName and -Label" {
            $result = New-NodeAttributeSet -FontName 'Courier New' -Label 'MyLabel'
            $result.fontname | Should -Be 'Courier New'
            $result.label | Should -Be 'MyLabel'
        }

        It "Applies -Distortion (previously broken by a stray-array-entry bug upstream)" {
            (New-NodeAttributeSet -Distortion 0.5).distortion | Should -Be 0.5
        }
    }

    Context "-Regular switch" {

        It "Sets regular = true when specified" {
            (New-NodeAttributeSet -Regular).regular | Should -Be $true
        }

        It "Omits 'regular' when not specified" {
            (New-NodeAttributeSet).ContainsKey('regular') | Should -Be $false
        }
    }

    Context "Integration with Node" {

        It "Merges cleanly into Node's -Attributes and renders in the DOT output" {
            $dot = (graph g { node MyNode (New-NodeAttributeSet -Shape box -Color Blue) }) -join "`n"

            $dot | Should -Match 'shape="box"'
            $dot | Should -Match 'color="blue"'
        }
    }
}
