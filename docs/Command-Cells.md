# Cells

`Cells` converts pipeline objects into GraphViz HTML-like table rows (`<TR>...</TR>`), one row per object. It exists to pair with `Record`: pipe any collection straight into a table node without hand-building `Row` calls for each property.

    Get-Process | Select-Object -First 3 Name, Id |
        Cells | Record Processes | Show-PSGraph

By default the first object's property names become a bold header row, and every property after that becomes one `<TD>` per row.

## Cells [-Properties [string[]]] [-ExcludeProperty [string[]]]

Filter which properties become columns, and in what order. Both accept wildcards.

    Get-Process | Cells -Properties Name, Id, CPU

    Get-Process | Cells -ExcludeProperty Handle*, WS

## Cells [-PortProperty [string]]

Names one column's `<TD>` with a `PORT` attribute, so `Edge` can target that specific cell instead of the whole record.

    Get-Process | Select-Object -First 3 Name, Id |
        Cells -PortProperty Id | Record Processes -Name Procs

    Graph {
        Record Procs -Rows (Get-Process | Select-Object -First 3 Name, Id | Cells -PortProperty Id)
        Node Other
        Edge Other -To Procs:1234
    }

## Cells [-Align [LEFT|CENTER|RIGHT]] [-HtmlEncode] [-NoHeader]

* `-Align` — text alignment applied to every `<TD>`. Defaults to `LEFT`.
* `-HtmlEncode` — HTML-encodes each cell's value, for data that may contain `<>&`.
* `-NoHeader` — skips the header row that's otherwise built from the first object's property names.

    Get-Process | Select-Object -First 5 Name, Id, CPU |
        Cells -Align CENTER -NoHeader | Record ProcessList
