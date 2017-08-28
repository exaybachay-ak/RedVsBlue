#Credit to creator of POSHGUI - https://poshgui.com/#

#Set up functions
function drawButton($name,$text,$color,$width,$height,$locationx,$locationy){
	$name = New-Object system.windows.Forms.Button
	$name.Text = "$text"
	$name.ForeColor = "#$color"
	$name.width = "$width"
	$name.height = "$height"
	$name.location = new-object system.drawing.point($locationx,$locationy)
	$name.font = "Microsoft Sans Serif,10"
	$Form.controls.Add($name)
}

function drawTextbox($name,$text,$width,$height,$locationx,$locationy){
	$name = New-Object system.windows.Forms.TextBox
	$name.Text = "$text"
	$name.width = "$width"
	$name.height = "$height"
	$name.location = new-object system.drawing.point($locationx,$locationy)
	$name.font = "Microsoft Sans Serif,10"
	$Form.controls.Add($name)
}

Add-Type -AssemblyName System.Windows.Forms

#Create main form window
$Form = New-Object system.Windows.Forms.Form
$Form.Text = "Red vs Blue"
$Form.BackColor = "#1613d0"
$Form.TopMost = $true
$Form.Width = 672
$Form.Height = 338

#Draw buttons in window
drawButton Logging Logging ffffff 85 33 6 9
drawButton Sinkhole Sinkhole ffffff 86 33 6 58
drawButton VulnTrack VulnTrack ffffff 86 33 6 104
drawButton HNIDS HNIDS ffffff 86 33 6 146
drawButton IPINT IPINT ffffff 86 33 6 192 
drawButton Partymode "Party Mode (Red Team)" ffffff 300 50 177 242

#Draw text boxes in window
drawTextbox Loggingtext "Set up Windows logging, according to NSA Spotting the Adversary document" 473 20 120 15
drawTextbox VulnTracktext "Keep track of your vulnerabilities with alerts and email notifications" 473 20 120 111
drawTextbox Sinkholetext "Configure routes to send malware traffic to NULL" 473 20 120 64
drawTextbox HNIDStext "Host-based Network Intrusion Detection System" 473 20 120 154
drawTextbox IPINTtext "Open-source intelligence about IP Address information" 473 20 120 200

[void]$Form.ShowDialog()
$Form.Dispose()
