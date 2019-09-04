function Get-CitrixMachinesForDG {
    
    <#
    .SYNOPSIS
    
    .DESCRIPTION
    
    .LINK
    https://github.com/karjona/citrix-odata
    
    .PARAMETER MachinesObject
    
    .PARAMETER DeliveryGroupId
    
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
        $MachinesForDeliveryGroup = $MachinesObject.value | `
        Where-Object -FilterScript {$_.DesktopGroupId -eq $DeliveryGroupId} | `
        Select-Object -Property DnsName -Unique | Measure-Object | Select-Object -ExpandProperty Count
        if ($null -eq $MachinesForDeliveryGroup) {
            $MachinesForDeliveryGroup = 0
        }
        $MachinesForDeliveryGroup
    }
}
