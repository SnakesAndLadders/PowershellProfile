Function gwlattest {
	Try{
		$GetInterface = Get-WmiObject -Class Win32_IP4RouteTable | where { $_.destination -eq '0.0.0.0' -and $_.mask -eq '0.0.0.0' } | select nexthop
		$timeout = 1000
		$Ping = New-Object System.Net.NetworkInformation.Ping
		$total = 0
		foreach($i in 1..10){
			$Response = $Ping.Send($GetInterface.nexthop,$Timeout)
			$total = $total + $Response.RoundtripTime
		}
		$Connect = $total/10
	}Catch{
		$Connect = "Error"
	}
	$Connect
}

Function wanlattest {
	Try{
		$timeout = 1000
		$Ping = New-Object System.Net.NetworkInformation.Ping
		$total = 0
		foreach($i in 1..10){
			$Response = $Ping.Send("1.1.1.1",$Timeout)
			$total = $total + $Response.RoundtripTime
		}
		$Connect = $total/10
	}Catch{
		$Connect = "Error"
	}
	$Connect
}

Function portstest {            
	[cmdletbinding()]            
	param(            
	)		
	try {            
		$TCPProperties = [System.Net.NetworkInformation.IPGlobalProperties]::GetIPGlobalProperties()            
		$Connections = $TCPProperties.GetActiveTcpListeners()            
		foreach($Connection in $Connections) {            
			if($Connection.address.AddressFamily -eq "InterNetwork" ) { $IPType = "IPv4" } else { $IPType = "IPv6" }            
						
			$OutputObj = New-Object -TypeName PSobject            
			$OutputObj | Add-Member -MemberType NoteProperty -Name "LocalAddress" -Value $connection.Address            
			$OutputObj | Add-Member -MemberType NoteProperty -Name "ListeningPort" -Value $Connection.Port            
			$OutputObj | Add-Member -MemberType NoteProperty -Name "IPV4Or6" -Value $IPType            
			$OutputObj            
		}            
				
	} catch {            
		Write-Error "Failed to get listening connections. $_"            
	}           
}

Function watchoptest {
	Param(
        [parameter(position=1)]
        $port,
        [parameter(position=0)]
		$ip
    )
	
	cls
	while($true){
		get-date
		$t = New-Object Net.Sockets.TcpClient
		try {
			$t.connect($ip,$port)
			write-host "Service is up"
		}catch{
			write-Host "Service is down"
		}finally{
			$t.close();sleep 30
		}
	}
}