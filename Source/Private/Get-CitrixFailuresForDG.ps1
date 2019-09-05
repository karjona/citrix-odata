function Get-CitrixFailuresForDG {
    
    <#
    .SYNOPSIS
    
    .DESCRIPTION
    
    .LINK
    https://github.com/karjona/citrix-odata
    
    .PARAMETER FailuresObject
    
    .PARAMETER DeliveryGroupId
    
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
        $FailuresForDeliveryGroup = $FailuresObject.value | `
        Where-Object -FilterScript {$_.DesktopGroupId -eq $DeliveryGroupId} | `
        Measure-Object -Property FailureCount -Sum | Select-Object -ExpandProperty Sum
        if ($null -eq $FailuresForDeliveryGroup) {
            $FailuresForDeliveryGroup = 0
        }
        $FailuresForDeliveryGroup
    }
}
