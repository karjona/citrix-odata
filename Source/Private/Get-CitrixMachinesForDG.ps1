function Get-CitrixMachinesForDG {
    
    <#
    .SYNOPSIS
    Returns the number of managed machines in the specified Citrix Virtual Apps and Desktops Delivery Group.
    
    .DESCRIPTION
    The Get-CitrixMachinesForDG cmdlet returns an integer with the number of managed machines in a specified
    Delivery Group. This result is directly retrieved from the Citrix Monitor Service OData API.
    
    .LINK
    https://github.com/karjona/citrix-odata
    
    .PARAMETER MachinesObject
    Specifies an object that contains the results from a query to the Machines endpoint of the Citrix OData Monitor
    Service API. This object can be easily generated with the Get-CitrixMachines cmdlet.
    
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
    $MachinesObject,
    
    [Parameter(Mandatory=$true)]
    [String]
    $DeliveryGroupId
    )
    
    process {
        $MachinesForDeliveryGroup = $MachinesObject.value |
        Where-Object -FilterScript {$_.DesktopGroupId -eq $DeliveryGroupId} |
        Select-Object -Property HostedMachineId -Unique | Measure-Object | Select-Object -ExpandProperty Count
        if ($null -eq $MachinesForDeliveryGroup) {
            $MachinesForDeliveryGroup = 0
        }
        $MachinesForDeliveryGroup
    }
}
