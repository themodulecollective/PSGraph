[CmdletBinding()]
param()
$Script:PSModuleRoot = $PSScriptRoot
Write-Verbose -Message "This file is replaced in the build output, and is only used for debugging."
Write-Verbose -Message $PSScriptRoot

$folders = 'Includes', 'Internal', 'Private', 'Public', 'Resources'
foreach ($folder in $folders)
{
    $root = Join-Path -Path $PSScriptRoot -ChildPath $folder
    if (Test-Path -Path $root)
    {
        Write-Verbose -Message "Importing files from [$folder]..."
        $files = Get-ChildItem -Path $root -Filter '*.ps1' -Recurse |
            Where-Object Name -notlike '*.Tests.ps1'

        foreach ($file in $files)
        {
            Write-Verbose -Message "Dot sourcing [$($file.BaseName)]..."
            . $file.FullName
        }
    }
}

Write-Verbose -Message 'Exporting Public functions...'
$functions = Get-ChildItem -Path "$PSScriptRoot\Public" -Filter '*.ps1' -Recurse

# Keep in sync with PSGraph.psd1's AliasesToExport
Export-ModuleMember -Function $functions.BaseName -Alias @(
    'DiGraph', 'NodeAttributes', 'EdgeAttributes',
    'jpgGraph', 'pngGraph', 'gifGraph', 'imapGraph', 'cmapxGraph',
    'jp2Graph', 'jsonGraph', 'pdfGraph', 'plainGraph', 'dotGraph', 'svgGraph'
)
