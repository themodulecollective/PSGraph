$projectRoot = Resolve-Path "$PSScriptRoot\.."
$moduleRoot = Split-Path (Resolve-Path "$projectRoot\*\*.psd1")
$moduleName = Split-Path $moduleRoot -Leaf

Describe "Function Row" {

    It 'does not throw' {
        Row Test | Should -Not -BeNullOrEmpty
    }

    It 'returns a HTML row unmodified' {
        $text = '<TR>stuff</TR>'
        Row $text | Should -Be $text
    }

    It 'can encode html' {
        $text = '<B>stuff</B>'
        $encoded = ([System.Net.WebUtility]::HtmlEncode($text))
        Row $text -HtmlEncode | Should -match ([regex]::Escape( $encoded))
    }

    It 'uses simple label as port id' {
        Row Test | Should -Match 'PORT="Test"'
    }

    It 'does not use complex label as port id' {
        Row 'Test<b>test</b>' | Should -Not -Match 'PORT="Test'
    }

    It 'should use specified ID as port' {
        Row Label -ID Test | Should -Match 'PORT="Test"'
        Row Label -Name Test | Should -Match 'PORT="Test"'
    }

    Context "#64 Row attributes" {

        It 'applies additional attributes to the row cell' {
            Row Test -Attributes @{BORDER = 0 } | Should -Match 'BORDER="0"'
        }

        It 'still emits the standard PORT/ALIGN attributes alongside extra attributes' {
            $result = Row Test -Attributes @{BGCOLOR = 'lightgrey' }
            $result | Should -Match 'PORT="Test"'
            $result | Should -Match 'ALIGN="LEFT"'
            $result | Should -Match 'BGCOLOR="lightgrey"'
        }

        It 'does not add any extra attributes when none are specified' {
            Row Test | Should -Be '<TR><TD PORT="Test" ALIGN="LEFT">Test</TD></TR>'
        }
    }

    Context "#81 Row -Separator" {

        It 'emits a divider row with no label required' {
            Row -Separator | Should -Be '<TR><TD BORDER="0" CELLPADDING="0" HEIGHT="1" BGCOLOR="gray"></TD></TR>'
        }

        It 'rejects combining -Separator with -Label' {
            { Row Test -Separator } | Should -Throw
        }
    }
}
