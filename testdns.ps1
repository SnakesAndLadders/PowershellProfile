$numberoftests = 10
	$Networks = Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration -Filter IPEnabled=TRUE -ErrorAction Stop
	foreach($Network in $Networks) {
	  $DNSServers = $Network.DNSServerSearchOrder
	}
	$totalmeasurement = 0
	$i = 0
	foreach ($dnsserver in $DNSServers){
		while ($i -ne $numberoftests)
		{
			$measurement = (Measure-Command {Resolve-DnsName www.bing.com -Server $dnsserver –Type A}).TotalSeconds
			$totalmeasurement += $measurement
			$i += 1
		}
		$totalmeasurement = $totalmeasurement / $numberoftests
		"DNS Server: " + $dnsserver + ", Response time: " + $totalmeasurement + " seconds"
		$Networks = Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration -Filter IPEnabled=TRUE -ErrorAction Stop
		foreach($Network in $Networks) {
		  $DNSServers = $Network.DNSServerSearchOrder
		}
	}