$OSInfo = Get-CimInstance -ClassName Win32_OperatingSystem	
$Computerinfo = Get-CimInstance -ClassName  Win32_ComputerSystem
$ProcInfo = Get-CimInstance -ClassName  Win32_Processor
$BiosInfo = Get-CimInstance -ClassName  Win32_BIOS 
$LastReboot = (Get-CimInstance -ClassName  Win32_OperatingSystem -Property LastBootUpTime).LastBootUpTime
$Memory = [math]::round($Computerinfo.TotalPhysicalMemory/1GB, 2)
$DriveMaps = Get-SmbMapping 
$Drives = Get-CimInstance -ClassName  Win32_LogicalDisk
$NetAdapter = Get-CimInstance -ClassName  win32_networkadapterconfiguration | where {$_.IPEnabled -eq "True"}
$IPAddress = $NetAdapter.ipaddress[0]
$Gateway = $NetAdapter.defaultipgateway
$SubnetM = $NetAdapter.ipsubnet[0]
$DNS = $NetAdapter.dnsserversearchorder
clear
Write-Host "--------------- Computer Information ---------------"  -ForegroundColor Green
Write-Host "Computer:" $Computerinfo.Name "`nDomain:"$Computerinfo.Domain -ForegroundColor Green
Write-Host "Details:" $Computerinfo.Model " `nSerial Number:" $BiosInfo.SerialNumber "`nAsset Tag:" $BiosInfo.Version  -ForegroundColor Green
Write-Host $Memory "GB of Ram`n"$ProcInfo.Name " Processor." -ForegroundColor Green
Write-Host "Running Windows Build Number: " $OSInfo.BuildNumber " on OS Type " $OSInfo.OSType  -ForegroundColor Green
Write-Host "Last Rebooted: " $LastReboot -ForegroundColor Green
Write-Host "`n`n--------------- Network Information ---------------"
Write-Host "Address:" $IPAddress "`nDefault Gateway:" $Gateway "`nSubnet Mask:" $SubnetM "`nDNS Servers:" $DNS
Write-Host "`n`n--------------- Logical Drives ---------------" -ForegroundColor Green
foreach ($Drive in $Drives){
	$Size = [math]::round($Drive.size/1GB, 2)
	$Free = [math]::round($Drive.FreeSpace/1GB, 2)
	Write-Host "Drive " $Drive.DeviceID " - $Free GB free of $Size GB" -ForegroundColor Green
}
Write-Host "`n`n--------------- Mapped Drives ---------------"
ForEach ($DriveMap in $Drivemaps) {
	Write-Host "Drive: " $DriveMap.LocalPath "UNC: " $DriveMap.RemotePath
}
Write-Host "`n`n"