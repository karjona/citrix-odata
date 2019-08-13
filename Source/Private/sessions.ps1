function sessions {
    $username = 'xx'
    $password = ConvertTo-SecureString 'XXX' -AsPlainText -Force
    $ddcs = @('xx')
    $date = '2019-08-11'
    
    
    
    
    
    function CountSessions {
        param([PSCustomObject]$s, [PSCustomObject]$m)
        foreach ($f in $s.value) {
            $name = $m | Where-Object -Property Id -EQ $f.MachineId | Select-Object -ExpandProperty DesktopGroupName
            if ($null -eq $name) {
                $name = "No delivery group assigned"
            }
            $dgroupsessions[$name] += 1
        }
    }
    
    $cred = New-Object System.Management.Automation.PSCredential($username, $password)
    $ddcObj = @()
    $m = @()
    $dgroupsessions = @{}
    
    foreach ($ddc in $ddcs) {
        $dgroups = Invoke-RestMethod -Uri "http://$ddc/Citrix/Monitor/OData/v3/Data/DesktopGroups?`$format=json&`$select=Id,Name" -Credential $cred
        $machines = Invoke-RestMethod -Uri "http://$ddc/Citrix/Monitor/OData/v3/Data/Machines?`$format=json&`$select=Id,DesktopGroupId&`$filter=(DesktopGroupId ne null) and (Id ne null)" -Credential $cred
        foreach ($machine in $machines.value) {
            $m += [PSCustomObject]@{
                Id = $machine.Id
                DesktopGroupName = $dgroups.value | Where-Object -Property Id -EQ $machine.DesktopGroupId | Select-Object -ExpandProperty Name
            }
        }
        
        $sessions = 0
        # Sessions that started earlier than the selected date, but ended on the selected date
        $s = Invoke-RestMethod -Uri "http://$ddc/Citrix/Monitor/OData/v3/Data/Sessions?`$format=json&`$filter=(StartDate lt DateTime'$date`T00:00:00') and ((EndDate gt DateTime'$date`T00:00:00') and (EndDate lt DateTime'$date`T23:59:59'))" -Credential $cred
        $sessions += $s.value | Measure-Object -Maximum | Select-Object -ExpandProperty Count
        CountSessions $s $m
        
        # Sessions that started on the selected date and are still active
        $s = Invoke-RestMethod -Uri "http://$ddc/Citrix/Monitor/OData/v3/Data/Sessions?`$format=json&`$filter=(StartDate lt DateTime'$date`T00:00:00') and (EndDate eq null)" -Credential $cred
        $sessions += $s.value | Measure-Object -Maximum | Select-Object -ExpandProperty Count
        CountSessions $s $m
        
        # Sessions that started earlier than the selected date and ended later
        $s = Invoke-RestMethod -Uri "http://$ddc/Citrix/Monitor/OData/v3/Data/Sessions?`$format=json&`$filter=(StartDate lt DateTime'$date`T00:00:00') and (EndDate gt DateTime'$date`T23:59:59')" -Credential $cred
        $sessions += $s.value | Measure-Object -Maximum | Select-Object -ExpandProperty Count
        CountSessions $s $m
        
        # Sessions that started and ended on the selected date, typically the larger amount
        $s = Invoke-RestMethod -Uri "http://$ddc/Citrix/Monitor/OData/v3/Data/Sessions?`$format=json&`$filter=(StartDate gt DateTime'$date`T00:00:00') and (EndDate lt DateTime'$date`T23:59:59')" -Credential $cred
        $sessions += $s.value | Measure-Object -Maximum | Select-Object -ExpandProperty Count
        CountSessions $s $m
        
        # Sessions that started on the selected date and are still active
        $s = Invoke-RestMethod -Uri "http://$ddc/Citrix/Monitor/OData/v3/Data/Sessions?`$format=json&`$filter=((StartDate gt DateTime'$date`T00:00:00') and (StartDate lt DateTime'$date`T23:59:59')) and (EndDate eq null)" -Credential $cred
        $sessions += $s.value | Measure-Object -Maximum | Select-Object -ExpandProperty Count
        CountSessions $s $m
        
        # Sessions that started on the selected date and ended later
        $s = Invoke-RestMethod -Uri "http://$ddc/Citrix/Monitor/OData/v3/Data/Sessions?`$format=json&`$filter=((StartDate gt DateTime'$date`T00:00:00') and (StartDate lt DateTime'$date`T23:59:59')) and (EndDate gt DateTime'$date`T23:59:59')" -Credential $cred
        $sessions += $s.value | Measure-Object -Maximum | Select-Object -ExpandProperty Count
        CountSessions $s $m
        
        $ddcObj += [PSCustomObject]@{
            Name = $ddc
            Sessions = $sessions
        }
    }
    
    $capacityObj = [PSCustomObject]@{
        CreationDate = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
        ReportDate = $date
        CitrixHosts = $ddcObj
    }
    
    ConvertTo-Json -InputObject $capacityObj -Depth 2
    $dgroupsessions
}
