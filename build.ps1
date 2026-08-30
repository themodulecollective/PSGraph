[CmdletBinding()]
param(
    [parameter(Position=0)]
    $Task = 'Default'
)

$Script:Modules = @(
    'BuildHelpers',
    'InvokeBuild',
    'platyPS',
    'PSScriptAnalyzer',
    'DependsOn'
)

# Pinned explicitly: Pester 4.x and 5.x can be installed side by side, which
# leaves `Invoke-Pester` resolution ambiguous without a required version.
$Script:PesterVersion = '5.7.1'

$Script:ModuleInstallScope = 'CurrentUser'

'Starting build...'
'Installing module dependencies...'

Get-PackageProvider -Name 'NuGet' -ForceBootstrap | Out-Null

$installPesterSplat = @{
    Name               = 'Pester'
    RequiredVersion    = $Script:PesterVersion
    Scope              = $Script:ModuleInstallScope
    Force              = $true
    SkipPublisherCheck = $true
    AllowClobber       = $true
}
Install-Module @installPesterSplat
Install-Module -Name $Script:Modules -Scope $Script:ModuleInstallScope -Force -SkipPublisherCheck -AllowClobber

Import-Module -Name 'Pester' -RequiredVersion $Script:PesterVersion -Force

Set-BuildEnvironment
Get-ChildItem Env:BH*
Get-ChildItem Env:APPVEYOR*

$Error.Clear()

"Invoking build action [$Task]"

Invoke-Build -Task $Task -Result 'Result'
if ($Result.Error)
{
    $Error[-1].ScriptStackTrace | Out-String
    exit 1
}

exit 0
