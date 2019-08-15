# ┍——————————————————————————————————————————— TOOLS —————————————————————————————————————————————————┑
# | la             List Aliases                  | genpass     Generate Random Password               |
# | tt             Start Time Tracker            | ports       List All Open Ports                    |
# | title          Set Window Title              | compinfo    Get Computer Information               |
# | nscan          Scan Network ([start] [end])  | home        SSH To Home                            |
# | weather        Get Weather Forcast           | myip        Show public IP                         |
# | last5          Get Last 5 events from logs   | watchop     Watch a server ([ip] [port])           |
# | watchlog       Watch Event Log ([log])       | dirmore     Dir With Folder Sizes (Can Add 'GUI')  |
# | nano           Run Nano in Bash ([filename]) | npp         Open file in Notepad++                 |
# | 365            Connect to Office 365         | gwlat       Get Default Gateway Latency            |
# | wanspeed       Internet Speed Test           | wanlat      Get 1.1.1.1 Latency                    |
# | testdns        DNS Latency Test              | tail        Watch changes to a file live           |
# | tcping         Continually check server      | waitrdp     Alert when RDP is back online          |
# | waithttp       Alert when HTTP back online   | waitssl     Alert when HTTPS is back online        |
# | Test-Port      Show if port is up            | countdown   Start a countdown                      |
# ┕——————————————————————————————————————————————✼————————————————————————————————————————————————————┙

clear
$Admin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
$ProfilePath = Split-Path -Path $profile.CurrentUserCurrentHost
$ScriptsPath = "$ProfilePath\Scripts"
$SSHServer = 
$SSHPort = 
$City = "http://wttr.in/[city]"

Unblock-File "$ScriptsPath\nettests.ps1"
Unblock-File "$ScriptsPath\Get-WanSpeed.ps1"
Unblock-File "$ScriptsPath\logtime.ps1"
Unblock-File "$ScriptsPath\compinfo.ps1"
Unblock-File "$ScriptsPath\Invoke-TSPingSweep.ps1"
. $ScriptsPath\nettests.ps1
$Header = "~-~-~-~-~ Type 'la' for aliases. ~-~-~-~-~"

Function testdns {
	Write-Host "Testing DNS Latency"
	& $ScriptsPath\testdns.ps1	
}

Function 365 {
	$UserCredential = Get-Credential
	$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
	Import-PSSession $Session -DisableNameChecking
	Write-Host "Be sure to run [Remove-PSSession $Session] when done"
}

Function gwlat {
	Import-Module "$ScriptsPath\nettests.ps1"
	gwlattest
}

Function wanlat {
	Import-Module "$ScriptsPath\nettests.ps1"
	wanlattest
}

Function wanspeed {
	Write-Host "Testing Internet Speed"
	& $ScriptsPath\Get-WanSpeed.ps1
	
}

Function title($title) {
	$host.ui.RawUI.WindowTitle = $title
}

function genpass {Add-Type -AssemblyName System.web;[System.Web.Security.Membership]::GeneratePassword(20,5) | Set-Clipboard;Write-Host "Copied to clipboard" -ForegroundColor Green}

function la {clear;(Select-String -Path $profile -Pattern '^#').Line.TrimStart(" ", "#");title("~-~-~-~-~ Type 'la' for aliases. ~-~-~-~-~")}

function tt {Start-Job -FilePath "$ScriptsPath\logtime.ps1"}

Function NotifyNow($ToSend){
	Add-Type -AssemblyName System.Windows.Forms 
	$global:balloon = New-Object System.Windows.Forms.NotifyIcon
	$path = (Get-Process -id $pid).Path
	$balloon.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path) 
	$balloon.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Warning 
	$balloon.BalloonTipText = $ToSend
	$balloon.BalloonTipTitle = "Attention $Env:USERNAME" 
	$balloon.Visible = $true 
	$balloon.ShowBalloonTip(5000)
}

Function HumanReadK($number){
	Return [math]::round($number/1KB, 2)
}

Function ports {            
	Import-Module "$ScriptsPath\nettests.ps1"
	portstest
}

Function compinfo {
	Write-Host "Getting Computer Info"
	& $ScriptsPath\compinfo.ps1	
}

Function nscan{
	Param(
        [parameter(position=1)]
        $end,
        [parameter(position=0)]
		$start
    )
	title "Scanning Network"
	Import-Module "$ScriptsPath\Invoke-TSPingSweep.ps1"
	Invoke-TSPingSweep -StartAddress $start -EndAddress $end -ResolveHost -ScanPort -TimeOut 500
	title "Scan Complete"
	NotifyNow("Scan Complete")
}

Function home{ssh $SSHServer -p $SSHPort}

Function weather {clear;(curl $City -UserAgent "curl" ).Content}

Function myip{
	$IPAddress = (Invoke-WebRequest -uri "http://ifconfig.me/ip").Content
	write-Host "`nYour Public IP is"$IPAddress -ForegroundColor Green
}

Function last5 {
	$logs = "system", "application"
	foreach ($log in $logs){
		Get-EventLog -LogName $log -Newest 5
	}
}

Function watchop {
	Param(
        [parameter(position=1)]
        $port,
        [parameter(position=0)]
		$ip
    )
	Import-Module "$profilepath\nettests.ps1"
	watchoptest $port $ip
}

Function watchlog($log) {
	cls;get-date;Write-host "Watching $log Log";$idxA = (get-eventlog -LogName $log -Newest 1).Index;while($true){$idxA2 = (Get-EventLog -LogName $log -newest 1).index;get-eventlog -logname $log -newest ($idxA2 - $idxA) |  sort index;$idxA = $idxA2;sleep 10}
}

Function dirmore {
	param( $gui = $null )
	if ($gui){
		dir | % { New-Object PSObject -Property @{ Name = $_.Name; Size = if($_.PSIsContainer) { HumanReadK((gci $_.FullName -Recurse | Measure Length -Sum  -ErrorAction SilentlyContinue).Sum) } else {HumanReadK($_.Length) }; Type = if($_.PSIsContainer) {'Directory'} else {'File'} } -ErrorAction SilentlyContinue }  | Out-GridView -Title "Directory Listing"
	}else{
		dir | % { New-Object PSObject -Property @{ Name = $_.Name; Size = if($_.PSIsContainer) { HumanReadK((gci $_.FullName -Recurse | Measure Length -Sum  -ErrorAction SilentlyContinue).Sum) } else {HumanReadK($_.Length) }; Type = if($_.PSIsContainer) {'Directory'} else {'File'} } -ErrorAction SilentlyContinue }  | Format-Table
	}
}

function nano ($File){
    bash -c "nano $File"
}

function npp ($File) {
    start notepad++ $File
}

function tail($filename) {
    $last = ''
    while ($true) {
        $next = Get-Content $filename -tail 1
        if ($last -ne $next -and $next.Trim() -ne '') {
            Write-Host $next
        }
        $last = $next
        Start-Sleep 1
    }
}
Write-Host $Header -ForegroundColor Green
title($Header)
