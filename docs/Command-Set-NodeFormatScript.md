# Set-NodeFormatScript

Every node/edge identifier PSGraph emits passes through a formatting step before it's written to the DOT output. `Set-NodeFormatScript` lets you override that step for the rest of the session, which is handy when your data isn't consistently formatted (mixed case, stray whitespace, etc.) and you want every reference to the same underlying value to collapse to the same node.

    Set-NodeFormatScript -ScriptBlock {$_.ToLower()}

    graph g {
        edge 'Server1' 'server1'
    }

Without the format script, `'Server1'` and `'server1'` would be treated as two different nodes. With it, both collapse to the same lowercased node.

## Scope and lifetime

The script block is stored in module scope and applies to every `graph {}` call made afterward, for the lifetime of the imported module — not just the next call. Reset it back to the default (no transformation) by calling it again with no argument:

    Set-NodeFormatScript
