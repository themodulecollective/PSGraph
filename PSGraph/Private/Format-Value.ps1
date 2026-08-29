function Format-Value
{
    param(
        $value,

        [switch]
        $Edge,

        [switch]
        $Node
    )

    begin
    {
        if ( $null -eq $Script:CustomFormat )
        {
            Set-NodeFormatScript
        }
    }
    process
    {
        # edges can point to record cells
        if ($Edge -and
            # is not surounded by explicit quotes
            $value -notmatch '^".*"$' -and
            # has record notation with a port/row target - allow hyphens so GUID-style
            # row IDs (see issue #65) are recognized as a port, not part of the node name
            $value -match '^(?<node>.+):(?<Record>[\w-]+)$'
        )
        {
            # Capture both groups before any further regex ops below, since -notmatch
            # re-populates (and would otherwise clobber) $matches
            $recordNode = $matches.node
            $recordPort = $matches.Record

            if ($recordPort -notmatch '^[A-Za-z_]\w*$')
            {
                # Not a bare GraphViz identifier (e.g. a GUID, or starts with a digit) - quote it
                $recordPort = '"{0}"' -f $recordPort
            }

            # Recursive call to this function to format just the node
            "{0}:{1}" -f (Format-Value $recordNode -Node), $recordPort
        }
        else
        {
            # Allows for custom node ID formats
            if ( $Edge -Or $Node )
            {
                $value = @($value).ForEach($Script:CustomFormat)
            }

            switch -Regex ( $value )
            {
                # HTML-like label (DOT grammar: any value wrapped in <...>, not just <table>)
                '(?s)^<.*>$'
                {
                    "<$PSItem>"
                }
                '^".*"$'
                {
                    [string]$PSItem
                }
                # Anything else, use quotes
                default
                {
                    '"{0}"' -f ( [string]$PSItem ).Replace("`"", '\"') # Escape quotes in the string value
                }
            }
        }
    }
}
