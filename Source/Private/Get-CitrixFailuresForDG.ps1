function Get-CitrixFailuresForDG {
    
    <#
    .SYNOPSIS
    Returns the connection failure count for sessions in the specified Citrix Virtual Apps and Desktops Delivery
    Group.
    
    .DESCRIPTION
    The Get-CitrixFailuresForDG cmdlet returns an integer with the number of connection failures for sessions of a
    specified Delivery Group. This result is directly retrieved from the Citrix Monitor Service OData API.
    
    .LINK
    https://github.com/karjona/citrix-odata
    
    .PARAMETER FailuresObject
    Specifies an object that contains the results from a query to the Failures endpoint of the Citrix OData Monitor
    Service API. This object can be easily generated with the Get-CitrixFailures cmdlet.
    
    .PARAMETER DeliveryGroupId
    Specifies a single Delivery Group ID to collect data from.
    
    .COMPONENT
    citrix-odata
    #>
    
    
    [CmdletBinding()]
    [OutputType('int')]
    
    param(
    [Parameter(Mandatory=$true)]
    [PSCustomObject]
    $FailuresObject,
    
    [Parameter(Mandatory=$true)]
    [String]
    $DeliveryGroupId
    )
    
    
    process {
        $FailuresForDeliveryGroup = $FailuresObject.value |
        Where-Object -FilterScript {$_.DesktopGroupId -eq $DeliveryGroupId} |
        Measure-Object -Property FailureCount -Sum | Select-Object -ExpandProperty Sum
        if ($null -eq $FailuresForDeliveryGroup) {
            $FailuresForDeliveryGroup = 0
        }
        $FailuresForDeliveryGroup
    }
}
