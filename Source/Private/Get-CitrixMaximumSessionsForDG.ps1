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
        $MaxSessionsForDeliveryGroup = $SessionsObject.value | Group-Object -Property DesktopGroupId | `
        Where-Object -FilterScript {$_.Name -eq $DeliveryGroupId } | Select-Object -ExpandProperty Group | `
        Sort-Object -Property ConcurrentSessionCount -Descending | `
        Select-Object -ExpandProperty ConcurrentSessionCount -First 1
        if ($null -eq $MaxSessionsForDeliveryGroup) {
            $MaxSessionsForDeliveryGroup = 0
        }
        $MaxSessionsForDeliveryGroup
    }
}
