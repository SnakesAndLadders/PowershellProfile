Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

$LogDay                          = Get-Date -UFormat "{0:MM-dd-yyyy}"
$SaveFile						 = "timelog-$($LogDay).txt"
$SaveLocation					 = [Environment]::GetFolderPath("MyDocuments")
$Form                            = New-Object system.Windows.Forms.Form
$Form.ClientSize                 = '400,370'
$Form.text                       = "Time Log Entry"
$Form.TopMost                    = $false
$Icon 							 = [system.drawing.icon]::ExtractAssociatedIcon($PSHOME + "\powershell.exe")
$Form.Icon 						 = $Icon

$LogEntry                        = New-Object system.Windows.Forms.TextBox
$LogEntry.multiline              = $false
$LogEntry.width                  = 327
$LogEntry.height                 = 66
$LogEntry.location               = New-Object System.Drawing.Point(34,10)
$LogEntry.Font                   = 'Microsoft Sans Serif,10'

$LogViewer                       = New-Object system.Windows.Forms.TextBox
$LogViewer.multiline			 = $true
$LogViewer.width                 = 327
$LogViewer.height                = 300
$LogViewer.location              = New-Object System.Drawing.Point(34,50)

$Form.controls.AddRange(@($LogEntry,$LogViewer))
$LogEntry.Add_KeyDown({
    if ($_.KeyCode -eq "Enter") {
        #logic
        Write-Log $LogEntry.text
    }
})
$LogViewer.Add_Paint({ Load-Log })

function Get-TimeStamp {
    
    return "[{0:MM/dd/yy} {0:HH:mm}]" -f (Get-Date)
    
}

function Write-Log($LogItem) {
	if (!(Test-Path "$($SaveLocation)$($SaveFile)"))
	{
		New-Item -path $SaveLocation -name $SaveFile -type "file"
	}
	Write-Output "$(Get-TimeStamp) $LogItem" | Out-file "$($SaveLocation)$($SaveFile)" -append
	$LogEntry.Clear()
	Load-Log
}

function Load-Log {
	$LogViewer.Clear()
	$output = ""
	if ((Test-Path "$($SaveLocation)$($SaveFile)"))
	{
		# foreach($line in Get-Content "$($SaveLocation)$($SaveFile)") {
		# if ($line) {
			# $LogViewer.Items.Add($line)
		# 	$output += $line
		#}
		$output = Get-Content "$($SaveLocation)$($SaveFile)"
    }
	
    $LogViewer.text = $output | Out-String
}
Load-Log
[void]$Form.ShowDialog()