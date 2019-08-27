function Get-CitrixMonitorServiceData {
    
    <#
    .SYNOPSIS
    Returns Citrix Virtual Apps & Desktops usage data over a period of time.
    
    .DESCRIPTION
    The Get-CitrixMonitorServiceData cmdlet gets an object with usage data (sessions, number of virtual machines)
    of a Citrix Virtual Apps & Desktops Site over an specified period of time.
    
    This cmdlet takes a required parameter: a list of Citrix Virtual Apps & Desktops Delivery Controllers.
    Without any other parameters, it will use the current user to connect to the DDCs and collect usage information
    for the past day.
    
    It will return a custom object with session, user, login times and number of VMs for every Delivery Group
    present on the selected Site.
    
    Additional filters can be applied to select a different date range.
    
    .LINK
    https://github.com/karjona/citrix-odata
    
    .PARAMETER DeliveryControllers
    Specifies a single Citrix Virtual Apps & Desktops Delivery Controller or an array of Citrix DDCs from
    different Sites to collect data from.
    
    .PARAMETER Credential
    Specifies a user account that has permission to send the request. The default is the current user. A minimum of
    read-only administrator permissions on Citrix Virtual Apps & Desktops are required to collect this data.
    
    Enter a PSCredential object, such as one generated by the Get-Credential cmdlet.
    
    .PARAMETER StartDate
    Specifies the start date for the report in yyyy-MM-ddTHH:mm:ss. If you omit the time part, 00:00:00 will be
    automatically appended to the date.
    
    The default value is yesterday's date, midnight.
    
    .PARAMETER EndDate
    Specifies the end date for the report in yyyy-MM-ddTHH:mm:ss. If you omit the time part, 23:59:59 will be
    automatically appended to the date.
    
    The default value is yesterday's date, 23:59:59.
    
    .EXAMPLE
    Get-CitrixMonitorServiceData -DeliveryControllers $ddcs = @('myddc01.example.com', 'myddc02.example.com') ` -Credential Get-Credential
    
    Example 1: Get the usage data for the past day
    Returns the usage data for all Delivery Groups present on myddc01 and myddc02 Delivery Controllers using the
    specified credentials. The returned custom object will contain yesterday's usage data.
    
    .COMPONENT
    citrix-odata
    #>
    
    [CmdletBinding()]
    [OutputType('PSCustomObject')]
    
    param(
    [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=0, HelpMessage='Enter one or more Delivery' +
    ' Controllers separated by commas.')]
    [Alias('ComputerName')]
    [String[]]
    $DeliveryControllers,
    
    [Parameter()]
    [PSCredential]
    $Credential,
    
    [Parameter()]
    [DateTime]
    $StartDate = "$(Get-Date (Get-Date).AddDays(-1) -Format 'yyyy-MM-ddT00:00:00')",
    
    [Parameter()]
    [DateTime]
    $EndDate = "$(Get-Date (Get-Date).AddDays(-1) -Format 'yyyy-MM-ddT23:59:59')"
    )
    
    begin {
        if ($Credential) {
            $DeliveryControllers = Test-CitrixDDCConnectivity -DeliveryControllers $DeliveryControllers `
            -Credential $Credential
        } else {
            $DeliveryControllers = Test-CitrixDDCConnectivity -DeliveryControllers $DeliveryControllers
        }
    }
    
    process {
        foreach ($DeliveryController in $DeliveryControllers) {
            if ($Credential) {
                $DeliveryGroupsForDDC = Get-CitrixDeliveryGroups -DeliveryController $DeliveryController `
                -Credential $Credential
            } else {
                $DeliveryGroupsForDDC = Get-CitrixDeliveryGroups -DeliveryController $DeliveryController
            }

            if ($DeliveryGroupsForDDC.length -ge 1) {
                $DeliveryGroupInfo = @()
                if ($Credential) {
                    $ConcurrentSessionsForDDC = Get-CitrixConcurrentSessions `
                    -DeliveryController $DeliveryController -Credential $Credential -StartDate $StartDate `
                    -EndDate $EndDate
                } else {
                    $ConcurrentSessionsForDDC = Get-CitrixConcurrentSessions `
                    -DeliveryController $DeliveryController -StartDate $StartDate -EndDate $EndDate
                }

                foreach ($DeliveryGroup in $DeliveryGroupsForDDC) {
                    $DeliveryGroupInfo += [PSCustomObject]@{
                        Name = $DeliveryGroup.Name
                        Id = $DeliveryGroup.Id
                        MaxConcurrentSessions = Get-CitrixMaximumSessionsForDG `
                        -SessionsObject $ConcurrentSessionsForDDC -DeliveryGroupId $DeliveryGroup.Id
                    }
                }
            }

            $DeliveryControllerObject = [PSCustomObject]@{
                DeliveryControllerAddress = $DeliveryController
                DeliveryGroups = $DeliveryGroupInfo
            }
            
            # Construct the object that we will return and add the data from the loop
            $CitrixMonitorServiceData = [PSCustomObject]@{
                CreationDate = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
                StartDate = Get-Date -Date $StartDate -Format "yyyy-MM-ddTHH:mm:ss"
                EndDate = Get-Date -Date $EndDate -Format "yyyy-MM-ddTHH:mm:ss"
                DeliveryControllers = $DeliveryControllerObject
            }
        }
        $CitrixMonitorServiceData
    }
}
