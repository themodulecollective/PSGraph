$Script:ModuleName = Get-ChildItem -Path (Join-Path $PSScriptRoot '*\*.psm1') |
    Select-Object -ExpandProperty BaseName
$Script:CodeCoveragePercent = 0.0 # 0 to 1
. $PSScriptRoot\BuildTasks\InvokeBuildInit.ps1

task Default Build, Test, UpdateSource
task Build Copy, Compile, BuildModule, BuildManifest, SetVersion
task Helpify GenerateMarkdown, GenerateHelp
task Test Build, ImportModule, Pester
task Publish Build, PublishVersion, Test, PublishModule
task TFS Clean, Build, PublishVersion, Test
task DevTest ImportDevModule, Pester

Write-Host 'Import common tasks'
Get-ChildItem -Path $buildroot\BuildTasks\*.Task.ps1 |
    ForEach-Object {Write-Host $_.FullName;. $_.FullName}
