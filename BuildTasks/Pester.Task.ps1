task Pester {
    $requiredPercent = $Script:CodeCoveragePercent

    $config = New-PesterConfiguration
    $config.Run.Path = 'Tests'
    $config.Run.PassThru = $true
    $config.Filter.Tag = 'Build'
    $config.Output.Verbosity = 'Normal'
    $config.TestResult.Enabled = $true
    $config.TestResult.OutputFormat = 'NUnitXml'
    $config.TestResult.OutputPath = $testFile

    if ($requiredPercent -gt 0.00)
    {
        $config.CodeCoverage.Enabled = $true
        $config.CodeCoverage.Path = 'Output\*\*.psm1'
        $config.CodeCoverage.OutputPath = 'Output\codecoverage.xml'
    }

    $results = Invoke-Pester -Configuration $config
    if ($results.FailedCount -gt 0)
    {
        Write-Error -Message "Failed [$($results.FailedCount)] Pester tests."
    }

    if ($results.CodeCoverage.NumberOfCommandsAnalyzed -gt 0)
    {
        $codeCoverage = $results.CodeCoverage.NumberOfCommandsExecuted / $results.CodeCoverage.NumberOfCommandsAnalyzed

        if ($codeCoverage -lt $requiredPercent)
        {
            Write-Error ("Failed Code Coverage [{0:P}] below {1:P}" -f $codeCoverage, $requiredPercent)
        }
    }
}
