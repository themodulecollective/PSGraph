InModuleScope -ModuleName PSGraph {
    Describe 'Function Install-GraphViz' -Tag Build {

        BeforeAll {
            Mock -Verifiable Get-PackageSource {}
            Mock -Verifiable Register-PackageSource {}
            Mock -Verifiable Find-Package {}
            Mock -Verifiable Install-Package {}
        }

        It 'Should not throw' {
            Install-GraphViz -WhatIf
        }

        It 'Defaults -Scope to AllUsers' {
            (Get-Command Install-GraphViz).Parameters['Scope'].Attributes.Where({$_ -is [System.Management.Automation.ValidateSetAttribute]}).ValidValues | Should -Contain 'AllUsers'
        }

        It 'Accepts -Scope CurrentUser' {
            { Install-GraphViz -Scope CurrentUser -WhatIf } | Should -Not -Throw
        }

        It 'Rejects an invalid -Scope value' {
            { Install-GraphViz -Scope 'Bogus' -WhatIf } | Should -Throw
        }

        # Note: the Chocolatey-registration-fails fallback branch (PR #112) isn't covered here.
        # Register-PackageSource/Find-Package expose dynamic, environment-dependent parameters
        # (e.g. -ProviderName's ValidateSet reflects whichever providers are actually registered
        # on the machine running the test), which makes faithfully mocking that specific real-cmdlet
        # interaction too environment-fragile for a unit test - it would pass or fail based on what
        # PackageManagement providers happen to be installed on the test runner, independent of
        # whether Install-GraphViz's own logic is correct.
    }
}
