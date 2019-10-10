function Get-CitrixMaximumSessionsForDG {
    
    <#
    .SYNOPSIS
    Returns the maximum number of concurrent sessions in the specified Citrix Virtual Apps and Desktops Delivery
    Group.
    
    .DESCRIPTION
    The Get-CitrixMaximumSessionsForDG cmdlet returns an integer with themaximum number of concurrent sessions in a
    specified Delivery Group. The concurrent session information is retrieve directly from the Citrix Monitor
    Service OData API and then sorted with this cmdlet to return the maximum observed value among the retrieved
    data.
    
    .LINK
    https://github.com/karjona/citrix-odata
    
    .PARAMETER SessionsObject
    Specifies an object that contains the results from a query to the SessionActivitySummaries endpoint of the
    Citrix OData Monitor Service API. This object can be easily generated with the Get-CitrixSessionActivity
    cmdlet.
    
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
    $SessionsObject,
    
    [Parameter(Mandatory=$true)]
    [String]
    $DeliveryGroupId
    )
    
    process {
        $MaxSessionsForDeliveryGroup = $SessionsObject.value | Group-Object -Property DesktopGroupId |
        Where-Object -FilterScript {$_.Name -eq $DeliveryGroupId } | Select-Object -ExpandProperty Group |
        Sort-Object -Property ConcurrentSessionCount -Descending |
        Select-Object -ExpandProperty ConcurrentSessionCount -First 1
        if ($null -eq $MaxSessionsForDeliveryGroup) {
            $MaxSessionsForDeliveryGroup = 0
        }
        $MaxSessionsForDeliveryGroup
    }
}
