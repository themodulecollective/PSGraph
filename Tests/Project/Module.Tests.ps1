$Script:ModuleRoot = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent
$Script:ModuleName = Get-ChildItem $ModuleRoot\*\*.psm1 | Select-Object -ExpandProperty BaseName

$Script:SourceRoot = Join-Path -Path $ModuleRoot -ChildPath $ModuleName

Describe "All commands pass PSScriptAnalyzer rules" -Tag 'Build' {

    BeforeDiscovery {
        $rulesPath = "$ModuleRoot\ScriptAnalyzerSettings.psd1"
        $scripts = Get-ChildItem -Path $SourceRoot -Include '*.ps1', '*.psm1', '*.psd1' -Recurse |
            Where-Object FullName -notmatch 'Classes' |
            ForEach-Object { @{ ScriptPath = $_.FullName; RulesPath = $rulesPath } }
    }

    Context "'<ScriptPath>'" -ForEach $scripts {

        It "Should not fail any ScriptAnalyzer rules" {
            $results = Invoke-ScriptAnalyzer -Path $ScriptPath -Settings $RulesPath
            $messages = $results | ForEach-Object { "{0} Line {1}: {2}" -f $_.Severity, $_.Line, $_.Message }
            ($messages -join [Environment]::NewLine) | Should -BeNullOrEmpty
        }
    }
}

Describe "Public commands have Pester tests" -Tag 'Build' {

    BeforeDiscovery {
        $commands = Get-Command -Module $ModuleName | ForEach-Object {
            @{
                CommandName = $_.Name
                TestFile    = Get-ChildItem -Path "$ModuleRoot\Tests" -Include "$($_.Name).Tests.ps1" -Recurse
            }
        }
    }

    It "Should have a Pester test for [<CommandName>]" -ForEach $commands {
        $TestFile.FullName | Should -Not -BeNullOrEmpty
    }
}
