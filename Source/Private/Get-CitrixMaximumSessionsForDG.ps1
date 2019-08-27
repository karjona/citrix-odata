function Get-CitrixMaximumSessionsForDG {
    
    <#
    .SYNOPSIS
    
    .DESCRIPTION
    
    .LINK
    https://github.com/karjona/citrix-odata
    
    .PARAMETER SessionsObject
    
    .PARAMETER DeliveryGroupId
    
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
        $ConcurrentSessionsForDeliveryGroup = $SessionsObject.value | `
        Where-Object -FilterScript { $_.DesktopGroupId -eq $DeliveryGroupId }
        $MaxSessionsForDeliveryGroup = $ConcurrentSessionsForDeliveryGroup.ConcurrentSessionCount | `
        Measure-Object -Maximum | Select-Object -ExpandProperty Maximum
        if ($null -eq $MaxSessionsForDeliveryGroup) {
            $MaxSessionsForDeliveryGroup = 0
        }
        $MaxSessionsForDeliveryGroup
    }
}
