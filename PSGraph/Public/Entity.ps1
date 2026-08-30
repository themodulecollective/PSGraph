
Enum EntityType
{
    Name
    Value
    TypeName
}

Function Entity
{
    <#
    .SYNOPSIS
    Convert an object into a PSGraph Record

    .DESCRIPTION
    Convert an object into a PSGraph Record

    .EXAMPLE

    $sample = [pscustomobject]@{
        first = 1
        second = 'two'
    }
    graph {
        $sample |  Entity -Show TypeName
    } | export-PSGraph -ShowGraph

    .NOTES
    General notes
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        "PSUseProcessBlockForPipelineCommand", "",
        Justification = "Converts one InputObject into one Record by design; not a batch/collection cmdlet."
    )]
    [CmdletBinding()]
    param (
        # The object to convert into a record
        [parameter(
            ValueFromPipeline,
            position = 0
        )]
        $InputObject,

        # The name of the node
        [string]
        $Name,

        # The list of properties to display. Default is to list them all. Supports wildcards.
        [string[]]
        $Property,

        # The different details to show in the record: Name (property name), Value (name and
        # value), or TypeName (name and the value's type).
        [EntityType]
        $Show = [EntityType]::TypeName
    )

    end
    {
        if ([string]::isnullorempty($Name) )
        {
            $Name = $InputObject.GetType().Name
        }

        if ($InputObject -is [System.Collections.IDictionary])
        {
            $members = $InputObject.keys
        }
        else
        {
            $Members = $InputObject.PSObject.Properties.Name
        }

        $rows = foreach ($propertyName in $members)
        {
            if ($null -ne $Property)
            {
                $matchingProperties = $property | Where-Object {$propertyName -like $_}
                if ($null -eq $matchingProperties)
                {
                    continue
                }
            }

            $value = $inputobject.($propertyName)
            switch ($Show)
            {
                Name
                {
                    Row "<B>$propertyName</B>" -Name $propertyName
                }
                TypeName
                {
                    if ($null -ne $value)
                    {
                        $type = $value.GetType().Name
                    }
                    else
                    {
                        $type = 'null'
                    }
                    Row ('<B>{0}</B> <I>[{1}]</I>' -f $propertyName, $type) -Name $propertyName
                }
                Value
                {
                    if ([string]::IsNullOrEmpty($value))
                    {
                        $value = ' '
                    }
                    elseif ($value.count -gt 1)
                    {
                        $value = '[object[]]'
                    }
                    $encodedValue = [System.Net.WebUtility]::HtmlEncode($value)
                    Row ('<B>{0}</B> : <I>{1}</I>' -f $propertyName, $encodedValue) -Name $propertyName
                }
            }
        }

        Record -Name $Name -Row $rows
    }
}
