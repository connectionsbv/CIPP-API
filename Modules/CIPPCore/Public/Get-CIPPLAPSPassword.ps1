
function Get-CIPPLapsPassword {
    [CmdletBinding()]
    param (
        $device,
        $TenantFilter,
        $APIName = 'Get LAPS Password',
        $Headers
    )

    try {
        $GraphRequest = (New-GraphGetRequest -noauthcheck $true -uri "https://graph.microsoft.com/beta/directory/deviceLocalCredentials/$($device)?`$select=credentials" -tenantid $TenantFilter).credentials | Select-Object -First 1 | ForEach-Object {
            $PlainText = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($_.passwordBase64))
            $date = $_.BackupDateTime
            [PSCustomObject]@{
                resultText = "LAPS password retrieved for $($_.accountName), generated at $($date). Copy the password by clicking the copy button"
                copyField  = $PlainText
                state      = 'success'
            }
        }
        if ($GraphRequest) { return $GraphRequest } else { return "No LAPS password found for $device" }
    } catch {
        $ErrorMessage = Get-CippException -Exception $_
        Write-LogMessage -headers $Headers -API $APIName -message "Could not retrieve LAPS password for $($device). Error: $($ErrorMessage.NormalizedError)" -Sev 'Error' -tenant $TenantFilter -LogData $ErrorMessage
        return "Could not retrieve LAPS password for $($device). Error: $($ErrorMessage.NormalizedError)"
    }
}


