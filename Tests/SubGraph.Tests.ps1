Describe 'Function SubGraph' -Tag Build {

    Context "Unit Tests" {

        it "SubGraph alias should not throw an error" {

            {SubGraph 0 {}} | Should -Not -Throw
        }

        it "SubGraph attributes should not throw an error" {

            {SubGraph 0 -Attributes @{label = 'test'} {}} | Should -Not -Throw
        }

        it "SubGraph positional attributes should not throw an error" {

            {SubGraph 0 @{label = 'test'} {}} | Should -Not -Throw
        }

        it "Builds basic graph" {
            $result = (SubGraph 0 {}) -join ''

            $result | Should -Not -BeNullOrEmpty
            $result | Should -Match 'cluster0'
            $result | Should -Match '{'
            $result | Should -Match '}'
            $result | Should -Match 'subgraph'
        }
    }

    Context "Features" {

        It "Items can be placed in a subgraph" {
            {
                graph test {
                    subgraph 0 {
                        node helo
                        edge hello world
                        rank same level
                        subgraph 1 {

                        }
                    }
                }
            } | Should -Not -Throw
        }

        It "#55 Supports un-named subgraphs" {
            {
                graph {
                    subgraph {
                        node helo
                        edge hello world
                        rank same level
                        subgraph {

                        }
                    }
                }
            } | Should -Not -Throw
        }

        It "#53 Supports edges to subgraphs" {

            $graph = graph g {
                subgraph source {
                    node a
                }
                edge b -to source
            } | Out-String

            $graph | Should -Match 'compound'
            $graph | Should -Match 'invis'
            $graph | Should -Match 'point'
            $graph | Should -Match 'lhead="clustersource"'

            $graph = graph g {
                subgraph source {
                    node a
                }
                edge source -to b
            } | Out-String

            $graph | Should -Match 'ltail="clustersource"'
        }
    }
}
