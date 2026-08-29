
Describe "Function Record" -Tag Build {

    It 'does not throw' {
        Record Test {} | Should -Not -BeNullOrEmpty
    }

    It 'name only' {
        $result = Record -Name test
        $result | Should -match test
    }
    It 'simple script example' {
        $result = Record test {
            'first'
            'second'
        } 
        $result | Should -match test
        $result | Should -match 'PORT="first"'        
        $result | Should -match 'PORT="Second"'
    } 

    It 'script example with row' {
        $result = Record test {
            Row 'first'
            'second'
        } 
        $result | Should -match test
        $result | Should -match 'PORT="first"'        
        $result | Should -match 'PORT="Second"'
    } 

    It 'simple array example' {
        $result = Record test @(
            'first'
            'second'
        ) 
        $result | Should -match test
        $result | Should -match 'PORT="first"'        
        $result | Should -match 'PORT="Second"'
    } 

    It 'simple array example with row script' {
        
        $list = @(
            'first',
            'Second'
        )

        $result = Record test $list {
            Row -Name $PSItem -Label "<B>$PSItem</B>"
        }
        $result | Should -match test
        $result | Should -match 'PORT="first"'        
        $result | Should -match 'PORT="Second"'
        $result | Should -match '<B>first</B>'        
        $result | Should -match '<B>Second</B>'
    } 

    It 'pipeline example' {
        $list = @(
            'first',
            'Second'
        )
        $result = $list | Record test

        $result | Should -match test
        $result | Should -match 'PORT="first"'        
        $result | Should -match 'PORT="Second"'
    }

    It 'pipeline example with row script' {
        $list = @(
            'first',
            'Second'
        )

        $result = $list | Record test -RowScript {
            Row -Name $PSItem -Label "<B>$PSItem</B>"
        }
        $result | Should -match test
        $result | Should -match 'PORT="first"'        
        $result | Should -match 'PORT="Second"'
        $result | Should -match '<B>first</B>'
        $result | Should -match '<B>Second</B>'
    }

    Context "#65 GUID-style row ports round-trip through Edge" {

        It 'quotes a GUID row port when targeted by Edge' {
            $rowId = '3fa85f64-5717-4562-b3fc-2c963f66afa6'

            $dot = graph g {
                Record Table1 {
                    Row -Name $rowId -Label 'Row with a GUID id'
                }
                Node Table2
                Edge "Table1:$rowId" -To Table2
            }

            ($dot -join "`n") | Should -Match "PORT=`"$rowId`""
            ($dot -join "`n") | Should -Match "`"Table1`":`"$rowId`"->`"Table2`""
        }
    }
}
