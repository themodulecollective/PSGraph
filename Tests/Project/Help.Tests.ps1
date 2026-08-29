$Script:ModuleRoot = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent
$Script:ModuleName = Get-ChildItem $ModuleRoot\*\*.psm1 | Select-Object -ExpandProperty BaseName

Describe "Public commands have comment-based or external help" -Tags 'Build' {

    BeforeDiscovery {
        $commandHelp = Get-Command -Module $ModuleName | ForEach-Object {
            $help = Get-Help -Name $_.Name
            @{
                CommandName  = $_.Name
                Synopsis     = $help.Synopsis
                Description  = $help.Description
                HasExamples  = [bool]$help.Examples.Example
                Parameters   = @(
                    $help.Parameters.Parameter |
                        Where-Object { $_.Name -notmatch 'WhatIf|Confirm' } |
                        ForEach-Object { @{ ParameterName = $_.Name; ParameterDescription = $_.Description.Text } }
                )
            }
        }
    }

    Context "<CommandName>" -ForEach $commandHelp {

        It "Should have a Description or Synopsis" {
            ($Description + $Synopsis) | Should -Not -BeNullOrEmpty
        }

        It "Should have an Example" {
            # Not asserting the example text mentions <CommandName>: proxy functions
            # (e.g. Show-PSGraph's `.ForwardHelpTargetName Export-PSGraph`) legitimately
            # inherit another command's examples verbatim.
            $HasExamples | Should -BeTrue
        }

        It "Should have a Description for Parameter [<ParameterName>]" -ForEach $Parameters {
            $ParameterDescription | Should -Not -BeNullOrEmpty
        }
    }
}
