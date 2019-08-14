function Test-CitrixDDCConnectivity {
    [CmdletBinding()]
    [OutputType([String[]])]

    param(
        [Parameter(Mandatory=$true)]
        [String[]]
        $DeliveryControllers,

        [Parameter()]
        [PSCredential]
        $Credential
    )

    process {
        # Test if Delivery Controllers are reachable and credentials are valid
        # Delivery Controllers that do not respond or that have invalid credentials will be removed from the list
        # If no Delivery Controllers are left after the validation, the cmdlet execution is halted
        foreach ($ddc in $DeliveryControllers) {
            try {
                if ($Credential) {
                    Invoke-RestMethod -Uri "http://$ddc/Citrix/Monitor/OData/v3/Data/" `
                    -Credential $Credential | Out-Null
                } else {
                    Invoke-RestMethod -Uri "http://$ddc/Citrix/Monitor/OData/v3/Data/" `
                    -UseDefaultCredentials | Out-Null
                }
            } catch {
                $ConnectionError = $_
                # Handle 401 (invalid credentials) error
                if ($ConnectionError.Exception.Response.StatusCode) {
                    if ($ConnectionError.Exception.Response.StatusCode.ToString() -eq 'Unauthorized') {
                        if (!$Credential) {
                            Write-Error ("The current user does not have at least read-only administrator " +
                            "permissions on $ddc.")
                        } else {
                            Write-Error ("The supplied credentials do not have at least read-only administrator " +
                            "permissions on $ddc.")
                        }
                    # There's a web server on that address, but responded with an error
                    } else {
                        Write-Error ("The server on $ddc responded with an error: " +
                        "$($ConnectionError.Exception.Message)")
                    }
                } else {
                    # Handle DNS resolution errors
                    if ($ConnectionError.Exception.Status.ToString() -eq 'NameResolutionFailure') {
                        Write-Error "Could not find host $ddc."
                    # Handle all other errors
                    } else {
                        Write-Error ("An error occurred while trying to connect to $ddc. Check network " +
                        "connectivity and that the specified host is a Citrix Delivery Controller.`r`n" +
                        "$($ConnectionError.Exception.Message)")
                    }
                }
                # Remove the failed DDC from the DDCs list
                $DeliveryControllers = $DeliveryControllers | Where-Object -FilterScript {$_ -ne $ddc}
            } finally {
                if (!$DeliveryControllers) {
                    throw "Could not connect to any of the specified Delivery Controllers."
                }
            }
        }
        $DeliveryControllers
    }
}
