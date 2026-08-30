function Install-GraphViz
{
    <#
        .Description
        Installs GraphViz package using online provider
        .PARAMETER Scope
        Use -Scope CurrentUser to install as a non-admin user to a per-user
        location instead of Program Files. Unused on macOS.
        .Example
        Install-GraphViz
        .Example
        Install-GraphViz -Scope CurrentUser
    #>
    [cmdletbinding( SupportsShouldProcess = $true, ConfirmImpact = "High" )]
    param(
        [ValidateSet('AllUsers', 'CurrentUser')]
        [string]
        $Scope = 'AllUsers'
    )

    process
    {
        try
        {
            # $IsMacOS doesn't exist on Windows PowerShell (Desktop) or on Core before 6.0;
            # guard the reference instead of relying on undefined-variable-as-falsy.
            $runningOnMacOS = ( Test-Path Variable:IsMacOS ) -and $IsMacOS
            if ( $runningOnMacOS )
            {
                if ( $PSCmdlet.ShouldProcess( 'Install graphviz' ) )
                {
                    brew install graphviz
                }
            }
            else
            {
                if ( $PSCmdlet.ShouldProcess('Register Chocolatey provider and install graphviz' ) )
                {
                    if ( -Not ( Get-PackageSource | Where-Object ProviderName -eq 'Chocolatey' ) )
                    {
                        try
                        {
                            Register-PackageSource -Name Chocolatey -ProviderName Chocolatey -Location http://chocolatey.org/api/v2/ -ErrorAction Stop
                        }
                        catch
                        {
                            # Registering Chocolatey typically requires admin rights. Fall back to the
                            # (older, but still functional) GraphViz package on nuget.org instead of failing outright.
                            $nugetSource = Get-PackageSource | Where-Object { $_.Location -like 'https://api.nuget.org/v*' }
                            if ( -Not $nugetSource )
                            {
                                Write-Warning 'No nuget.org package source found to fall back on. Cannot install GraphViz.'
                                throw
                            }

                            Write-Warning 'Could not register a Chocolatey package provider (this typically requires admin rights). Falling back to the older GraphViz package on nuget.org.'
                            Write-Warning 'Install Chocolatey and re-run this command to get the latest GraphViz.'
                        }
                    }

                    Find-Package graphviz | Install-Package -Verbose -ForceBootstrap -Scope $Scope
                }
            }
        }
        catch
        {
            $PSCmdlet.ThrowTerminatingError( $PSitem )
        }
    }
}
