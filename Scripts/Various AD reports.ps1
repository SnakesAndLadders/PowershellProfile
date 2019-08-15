Write-host "Getting total user count"
$totaluser = get-aduser -Filter * -Properties Name
Write-host $totaluser.count -ForegroundColor Green "Total number of users in $Domain"

Write-host "Getting disabled users"
$disabledusers = Search-ADAccount -UsersOnly -AccountDisabled |select name,DistinguishedName,LastLogonDate
Write-Host $disabledusers.count -ForegroundColor Green "Number of disabled users"

write-Host "Getting never logged User accounts that are enabled"
$Neverlogin = get-aduser -f {-not ( lastlogontimestamp -like “*”) -and (enabled -eq $true)} |select name,DistinguishedName
Write-host $Neverlogin.count -foreground Green “Getting never logged User accounts that are enabled”

write-Host "Getting inactive User accounts the are enabled"
$inacUser = Search-ADAccount -AccountInactive -TimeSpan $tspan -UsersOnly |Where-Object { $_.Enabled -eq $true } |select name,DistinguishedName,LastLogonDate
Write-host $inacuser.count -foreground Green 'Number of inactive user accounts that are enabled'

write-Host "Getting users created within a week."
$ADuserInWeek = Get-ADUser -Filter {whenCreated -ge $week} -Properties Whencreated | select Name,whenCreated,DistinguishedName
Write-Host $ADUserinweek.count -ForegroundColor Green 'Number of users created in the last 7 days

