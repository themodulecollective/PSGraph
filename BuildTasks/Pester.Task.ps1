task Pester {
    $config = New-PesterConfiguration
    $config.Run.Path = 'Tests'
    $config.Run.PassThru = $true
    $config.Filter.Tag = 'Build'
    $config.Output.Verbosity = 'Normal'
    $config.TestResult.Enabled = $true
    $config.TestResult.OutputFormat = 'NUnitXml'
    $config.TestResult.OutputPath = $testFile

    $results = Invoke-Pester -Configuration $config
    if ($results.FailedCount -gt 0)
    {
        Write-Error -Message "Failed [$($results.FailedCount)] Pester tests."
    }
}
