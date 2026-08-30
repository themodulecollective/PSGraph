function Format-KeyName
{
    <#
        .Description
        Lowercases a GraphViz attribute key name, except for the handful of
        attributes (Damping, K, URL) that GraphViz requires in their exact case.

        .Example
        Format-KeyName 'FONTCOLOR'

        fontcolor

        .Example
        Format-KeyName 'url'

        URL
    #>
    [OutputType('System.String')]
    [cmdletbinding()]
    param(
        [Parameter(Position = 0)]
        [string]
        $InputObject
    )
    begin
    {
        $translate = @{
            Damping = 'Damping'
            K       = 'K'
            URL     = 'URL'
        }
    }
    process
    {
        $InputObject = $InputObject.ToLower()
        if ( $translate.ContainsKey( $InputObject ) )
        {
            return $translate[ $InputObject ]
        }
        return $InputObject
    }
}