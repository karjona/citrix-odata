function Get-CitrixAverageLogOnDurationForDG {
    
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
        $AverageLogOnForDeliveryGroup = $SessionsObject.value | `
        Where-Object -FilterScript {$_.DesktopGroupId -eq $DeliveryGroupId -and $_.TotalLogOnCount -ge 1} | `
        Measure-Object -Property TotalLogOnDuration -Average | Select-Object -ExpandProperty Average
        if ($null -eq $AverageLogOnForDeliveryGroup) {
            $AverageLogOnForDeliveryGroup = 0
        }
        $AverageLogOnForDeliveryGroup / 1000
    }
}
