function Get-CitrixAverageLogOnDurationForDG {
    
    <#
    .SYNOPSIS
    Returns the average log on time duration in seconds for sessions in the specified Citrix Virtual Apps and
    Desktops Delivery Group.
    
    .DESCRIPTION
    The Get-CitrixAverageLogOnDurationForDG cmdlet returns an integer representing the average log on time for the
    sessions of a specified Delivery Group. To retrieve this result, the cmdlet divides the total log on duration
    in milliseconds of all sessions in the specified Delivery Group by the total number of log on operations in
    the Delivery Group. Both values are retrieved from the Citrix OData Monitor Service API and stored in a
    Sessions Object with a different cmdlet.
    
    To make the value easier to read, it is returned in seconds instead of milliseconds.
    
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
        $TotalLogOnCountForDeliveryGroup = $SessionsObject.value |
        Where-Object -FilterScript {$_.DesktopGroupId -eq $DeliveryGroupId} |
        Measure-Object -Property TotalLogOnCount -Sum | Select-Object -ExpandProperty Sum
        
        $TotalLogOnForDeliveryGroup = $SessionsObject.value |
        Where-Object -FilterScript {$_.DesktopGroupId -eq $DeliveryGroupId -and $_.TotalLogOnCount -ge 1} |
        Measure-Object -Property TotalLogOnDuration -Sum | Select-Object -ExpandProperty Sum
        
        if ($null -ne $TotalLogOnForDeliveryGroup) {
            $AverageLogOnForDeliveryGroup = $TotalLogOnForDeliveryGroup / $TotalLogOnCountForDeliveryGroup
        } else {
            $AverageLogOnForDeliveryGroup = 0
        }
        $AverageLogOnForDeliveryGroup / 1000        # Return the value in seconds
    }
}
