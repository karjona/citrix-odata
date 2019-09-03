<#
.SYNOPSIS
Imports the citrix-odata module to the current console session and executes Get-CitrixMonitorServiceData with
default parameters.

.DESCRIPTION
The Debug-GetCitrixMonitorServiceData script helps with making the debug process of the citrix-odata module easier.
Together with the appropiate Visual Studio Code launch.json action it will automatically clear the console buffer,
import the module (overwriting previous loaded versions, if any) and execute the Get-CitrixMonitorServiceData
cmdlet with default arguments.

This script will use the GetCitrixMonitorServiceData.variables.json file located in the same directory to populate
the required parameters of the cmdlet. An example JSON file should exist in this same directory and you can use it
to create your own variables file.

The Get-CitrixMonitorServiceData cmdlet result will be stored in the $Result variable after execution. This
variable will be automatically printed to the default stream.

.LINK
https://github.com/karjona/citrix-odata

.COMPONENT
citrix-odata
#>


try {
    Clear-Host
    
    $VariablesFromJson = Get-Content `
    -Path $(Join-Path -Path $PSScriptRoot -ChildPath 'GetCitrixMonitorServiceData.variables.json' ) | `
    ConvertFrom-Json

    Import-Module -Name '.\Source\citrix-odata.psd1' -Force

    $Password = ConvertTo-SecureString -String $VariablesFromJson.password -AsPlainText -Force
    $Credential = New-Object System.Management.Automation.PSCredential($VariablesFromJson.username, $Password)

    $Result = Get-CitrixMonitorServiceData -DeliveryControllers $VariablesFromJson.DeliveryControllers `
    -Credential $Credential

    $Result
} catch {
    $DebugError = $_
    throw $DebugError
}
