$username = 'EURO\ae028793'
$password = ConvertTo-SecureString 'XxXXx' -AsPlainText -Force
$ddcs = @('ffxgbsphxdc01.euro.iberdrola.local', 'ffxgbsphxdc03.euro.iberdrola.local')
$startdate = '2019-08-07'
$enddate = '2019-08-07'





$cred = New-Object System.Management.Automation.PSCredential($username, $password)
$ddcObj = @()

foreach ($ddc in $ddcs) {
    $dgroups = Invoke-RestMethod -Uri "http://$ddc/Citrix/Monitor/OData/v3/Data/DesktopGroups?`$format=json" -Credential $cred
    
    $dgroupObj = @()
    foreach ($dgroup in $dgroups.value) {
        $activity = Invoke-RestMethod -Uri "http://$ddc/Citrix/Monitor/OData/v3/Data/SessionActivitySummaries?`$format=json&`$filter=(DesktopGroupId eq guid'$($dgroup.Id)') and (SummaryDate gt DateTime'$startdate`T00:00:00') and (SummaryDate lt DateTime'$enddate`T23:59:59') and (Granularity eq 1440)" -Credential $cred
        $machines = Invoke-RestMethod -Uri "http://$ddc/Citrix/Monitor/OData/v3/Data/Machines?`$format=json&`$filter=(DesktopGroupId eq guid'$($dgroup.Id)')" -Credential $cred
        
        $concurrentUsers = $activity.value.ConcurrentSessionCount | Measure-Object -Maximum | Select-Object -ExpandProperty Maximum
        if ($null -eq $concurrentUsers) {
            $concurrentUsers = 0
        }
        
        $dgroupObj += [PSCustomObject]@{
            Id = $dgroup.Id
            Name = $dgroup.Name
            ConcurrentUsers = $concurrentUsers
            VMNumber = $($machines.value | Where-Object -FilterScript {$_.HostedMachineName -NE $null -and $_.LifecycleState -eq 0 -and $_.IsPendingUpdate -ne $true} | Measure-Object | Select-Object -ExpandProperty Count)
        }
    }
    
    $ddcObj += [PSCustomObject]@{
        Name = $ddc
        DeliveryGroups = $dgroupObj
    }
}

$capacityObj = [PSCustomObject]@{
    CreationDate = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
    StartDate = "$startdate`T00:00:00"
    EndDate = "$enddate`T23:59:59"
    CitrixHosts = $ddcObj
}

ConvertTo-Json -InputObject $capacityObj -Depth 3
