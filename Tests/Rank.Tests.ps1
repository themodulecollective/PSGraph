Describe 'Function Rank' -Tag Build {
    Context "Unit Tests" {
        it "Get-Rank should not throw an error" {

            {Rank lhs rhs } | Should -Not -Throw
        }

        it "Rank alias should not throw an error" {

            {Rank lhs rhs} | Should -Not -Throw
        }

        It "Creates a rank grouping" {
            rank lhs rhs | Should -Match '{ rank=same;  "lhs"; "rhs"; }'
        }
    }

    Context "Features" {

        It "Can rank an array of items" {

            {rank (1..3)} | Should -Not -Throw

            $result = rank (1..3)
            $result | Should -Not -BeNullOrEmpty
            $result.count | Should -Be 1
            $result | Should -Match '{ rank=same;  "1"; "2"; "3"; }'
        }

        It "Can rank a list of items" {

            {rank one two three} | Should -Not -Throw

            $result = rank one two three
            $result | Should -Not -BeNullOrEmpty
            $result.count | Should -Be 1
            $result | Should -Match '{ rank=same;  "one"; "two"; "three"; }'
        }

        it "Can rank objects with a script block" {
            $objects = @(
                @{name = 'one'}
                @{name = 'two'}
                @{name = 'three'}
            )

            {rank $objects -NodeScript {$_.name}} | Should -Not -Throw
        }
    }

    Context "#101 RankType" {

        It "Defaults to rank=same when -RankType is not specified" {
            rank lhs rhs | Should -Match '{ rank=same;  "lhs"; "rhs"; }'
        }

        It "Emits the requested rank type '<RankType>'" -TestCases @(
            @{ RankType = 'same' }
            @{ RankType = 'min' }
            @{ RankType = 'source' }
            @{ RankType = 'max' }
            @{ RankType = 'sink' }
        ) {
            param($RankType)

            $result = rank lhs rhs -RankType $RankType
            $result | Should -Match "\{ rank=$RankType;  `"lhs`"; `"rhs`"; \}"
        }

        It "Rejects an invalid -RankType value" {
            { rank lhs rhs -RankType 'bogus' } | Should -Throw
        }
    }

}
