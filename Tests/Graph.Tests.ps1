Describe 'Function Graph' -Tag Build {

    Context "Unit Tests" {

        It "Graph should not throw an error" {

            {Graph g {}} | Should -Not -Throw
        }

        It "Graph without name should not throw an error #41" {

            {Graph {}} | Should -Not -Throw
        }

        It "Graph attributes should not throw an error" {

            {Graph g -Attributes @{label = 'test'} {}} | Should -Not -Throw
        }

        It "Graph positional attributes should not throw an error" {

            {Graph g @{label = 'test'} {}} | Should -Not -Throw
        }

        It "Graph without name positional attributes should not throw an error #41" {

            {Graph @{label = 'test'} {}} | Should -Not -Throw
        }

        It "Builds basic graph" {

            $name = 'GRAPH_NAME'
            $result = (Graph $name {}) -join ''

            $result | Should -Not -BeNullOrEmpty
            $result | Should -Match $name
            $result | Should -Match '{'
            $result | Should -Match '}'
            $result | Should -Match 'digraph'
        }
    }

    Context "Features" {

        It "Graph support attributes" {

            {graph g {} -Attributes @{label = "testcase"; style = 'filled'}} | Should -Not -Throw

            $resutls = (graph g {} -Attributes @{label = "testcase"; style = 'filled'}) -join ''

            $resutls | Should -Match 'label="testcase";'
            $resutls | Should -Match 'style="filled";'
        }

        It "Items can be placed in a graph" {
            {
                graph test {
                    node helo
                    edge hello world
                    rank same level
                    subgraph 0 {

                    }
                }
            } | Should -Not -Throw
        }
    }

    Context "-Strict switch" {

        It "Emits 'strict digraph' when specified" {
            $result = (graph g -Strict {}) -join ''
            $result | Should -Match '^strict digraph'
        }

        It "Emits plain 'digraph' when not specified" {
            $result = (graph g {}) -join ''
            $result | Should -Match '^digraph'
            $result | Should -Not -Match 'strict'
        }
    }

    Context "Indentation" {

        It "Has no indention for first graph element" {
            $result = graph g {node test}
            $result | Where-Object {$_ -match 'digraph'} | Should -Match '^digraph'
        }

        It "Has 4 space indention for first level items" {
            $result = graph g {
                node testNode
                edge testEdge1 testEdge2
                rank testRank
            }
            $result | Where-Object {$_ -match 'testNode'}  | Should -Match '^    "testNode"'
            $result | Where-Object {$_ -match 'testEdge1'} | Should -Match '^    "testEdge1"'
            $result | Where-Object {$_ -match 'rank'}  | Should -Match '^    { rank'
        }

        It "Has 4 space indention for first subbraph" {
            $result = graph g {
                subgraph 0 {
                    node test
                }
            }
            $result | Where-Object {$_ -match 'subgraph'} | Should -Match '^    subgraph'
        }

        It "Has 8 space indention for nested items" {
            $result = graph g {
                subgraph 0 {
                    node testNode
                    edge testEdge1 testEdge2
                    rank testRank
                }
            }
            $result | Where-Object {$_ -match 'testNode'}  | Should -Match '^        "testNode"'
            $result | Where-Object {$_ -match 'testEdge1'} | Should -Match '^        "testEdge1"'
            $result | Where-Object {$_ -match 'rank'}  | Should -Match '^        { rank'
        }

        It "Has 12 space indention for nested items" {
            $result = graph g {
                subgraph 0 {
                    subgraph 1 {
                        node testNode
                        edge testEdge1 testEdge2
                        rank testRank
                    }
                }
            }
            $result | Where-Object {$_ -match 'testNode'}  | Should -Match '^            "testNode"'
            $result | Where-Object {$_ -match 'testEdge1'} | Should -Match '^            "testEdge1"'
            $result | Where-Object {$_ -match 'rank'}  | Should -Match '^            { rank'
        }
    }
}
