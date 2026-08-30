taskx BuildModule @{
    Inputs  = (Get-ChildItem -Path $Source -Recurse -Filter *.ps1)
    Outputs = $ModulePath
    Jobs    = {
        $sb = [Text.StringBuilder]::new()
        $null = $sb.AppendLine('$Script:PSModuleRoot = $PSScriptRoot')

        foreach ($folder in $Folders)
        {
            if (Test-Path -Path "$Source\$folder")
            {
                $null = $sb.AppendLine("# Importing from [$Source\$folder]")
                $files = Get-ChildItem -Path "$Source\$folder" -Recurse -Filter *.ps1 |
                    Where-Object 'Name' -notlike '*.Tests.ps1'

                foreach ($file in $files)
                {
                    $name = $file.Fullname.Replace($buildroot, '')

                    "Importing [$($file.FullName)]..."
                    $null = $sb.AppendLine("# .$name")
                    $null = $sb.AppendLine([IO.File]::ReadAllText($file.FullName))
                }
            }
        }

        "Creating Module [$ModulePath]..."
        $null = New-Item -Path (Split-path $ModulePath) -ItemType Directory -ErrorAction SilentlyContinue -Force
        Set-Content -Path  $ModulePath -Value $sb.ToString() -Encoding 'UTF8'
    }
}
