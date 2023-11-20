# HelloID-Task-SA-Target-HelloID-UserRevokeMembership
###########################################################
# Form mapping
$formObject = @{
    userGUID  = $form.userGUID
    userName  = $form.userName
    groupGUID = $form.groupGUID
    groupName = $form.groupName
}

try {
    Write-Information "Executing HelloID action: [RevokeMembership] to Group: [$($formObject.groupName)] for User: [$($formObject.userName)]"
    Write-Verbose "Creating authorization headers"
    # Create authorization headers with HelloID API key
    $pair = "${portalApiKey}:${portalApiSecret}"
    $bytes = [System.Text.Encoding]::ASCII.GetBytes($pair)
    $base64 = [System.Convert]::ToBase64String($bytes)
    $key = "Basic $base64"
    $headers = @{"authorization" = $Key }

    Write-Verbose "Revoking Membership to HelloIDGroup: [$($formObject.groupName)] for HelloIDAccount: [$($formObject.userName)]"
    $splatCreateUserParams = @{
        Uri         = "$($portalBaseUrl)/api/v1/users/$($formObject.userGUID)/groups/$($formObject.groupGUID)"
        Method      = "DELETE"
        Verbose     = $false
        Headers     = $headers
        ContentType = "application/json"
    }
    $response = Invoke-RestMethod @splatCreateUserParams

    $auditLog = @{
        Action            = "RevokeMembership"
        System            = "HelloID"
        TargetIdentifier  = [String]$formObject.userGUID
        TargetDisplayName = [String]$formObject.userName
        Message           = "HelloID action: [RevokeMembership] to Group: [$($formObject.groupName)] for User: [$($formObject.userName)] executed successfully"
        IsError           = $false
    }
    Write-Information -Tags "Audit" -MessageData $auditLog

    Write-Information "HelloID action: [RevokeMembership] to Group: [$($formObject.groupName)] for User: [$($formObject.userName)] executed successfully"
}
catch {
    $ex = $_
    $auditLog = @{
        Action            = "RevokeMembership"
        System            = "HelloID"
        TargetIdentifier  = ""
        TargetDisplayName = [String]$formObject.userName
        Message           = "Could not execute HelloID action: [RevokeMembership] to Group: [$($formObject.groupName)] for User: [$($formObject.userName)], error: $($ex.Exception.Message)"
        IsError           = $true
    }
    if ($($ex.Exception.GetType().FullName -eq "Microsoft.PowerShell.Commands.HttpResponseException")) {
        $auditLog.Message = "Could not execute HelloID action: [RevokeMembership] to Group: [$($formObject.groupName)] for User: [$($formObject.userName)]"
        Write-Error "Could not execute HelloID action: [RevokeMembership] to Group: [$($formObject.groupName)] for User: [$($formObject.userName)], error: $($ex.ErrorDetails)"
    }
    Write-Information -Tags "Audit" -MessageData $auditLog
    Write-Error "Could not execute HelloID action: [RevokeMembership] to Group: [$($formObject.groupName)] for User: [$($formObject.userName)], error: $($ex.Exception.Message)"
}
###########################################################