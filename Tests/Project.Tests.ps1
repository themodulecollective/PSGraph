$projectRoot = Resolve-Path "$PSScriptRoot\.."
$moduleRoot = Split-Path (Resolve-Path "$projectRoot\*\*.psd1")
$moduleName = Split-Path $moduleRoot -Leaf

Describe "PSScriptAnalyzer rule-sets" -Tag Build {

    BeforeDiscovery {
        $scripts = Get-ChildItem $moduleRoot -Include *.ps1, *.psm1, *.psd1 -Recurse |
            Where-Object FullName -notmatch 'classes' |
            ForEach-Object { @{ ScriptPath = $_.FullName } }
    }

    Context "Script '<ScriptPath>'" -ForEach $scripts {

        It "Should not fail any ScriptAnalyzer rules" {
            $rules = Get-ScriptAnalyzerRule
            $results = Invoke-ScriptAnalyzer -Path $ScriptPath -IncludeRule $rules
            $messages = $results | ForEach-Object { "{0} Line {1}: {2}" -f $_.Severity, $_.Line, $_.Message }
            ($messages -join [Environment]::NewLine) | Should -BeNullOrEmpty
        }
    }
}
