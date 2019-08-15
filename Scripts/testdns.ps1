$numberoftests = 10
$Networks = Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration -Filter IPEnabled=TRUE -ErrorAction Stop
foreach($Network in $Networks) {
  $DNSServers = $Network.DNSServerSearchOrder
}
$i = 0
Write-Host "DNS Servers assigned to this host: $DNSServers"
$DNSServers += "1.1.1.1"
$DNSServers += "8.8.4.4"
foreach ($dnsserver in $DNSServers){
	# $totalmeasurement = 0
	while ($i -ne $numberoftests)
	{
		$measurement = (Measure-Command {Resolve-DnsName www.bing.com -Server $dnsserver –Type A}).TotalSeconds
		$totalmeasurement += $measurement
		$i += 1
	}
	$totalmeasurement = $totalmeasurement / $numberoftests
	$totalmeasurement = [math]::Round(($totalmeasurement),4)
	write-host "DNS Server:  $dnsserver, Response time: $totalmeasurement seconds"
}