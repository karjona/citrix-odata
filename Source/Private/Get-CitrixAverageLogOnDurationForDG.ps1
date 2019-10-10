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
        $AverageLogOnForDeliveryGroup / 1000
    }
}
