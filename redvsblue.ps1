###   Credit to creator of POSHGUI - https://poshgui.com/#

#####################################################################################
###   To Do
#####################################################################################
###   1. Set up checks for powershell and .NET versions
###   -need to see if all 3 are True, otherwise redirect user to updates for .NET etc
###
###   2. Make a /all options, for GPO deployment of all blue team settings that make sense
###   -sysmon, 300MB logs, PS Logging, IPINT, vulntrack, etc
###   --red team not something to put in silent mode
###   
###   3. Set up user checks with return if not root
###   -currently have these in wrong part of script, and they don't work
###
###   *Logging
###   *Sinkhole
###   *VulnTrack
###   *HNIDS
###   *IPINT
###
### 
###   .NET 4.5
###   Windows Management Framework (WMF) 4.0 (Windows 7/2008 only)
###   Windows Management Framework (WMF) 5.0
###   Windows 7 and 2008 R2 must be upgraded to Wind
###
###   
###   »      .NET 4.5
###   »      Windows Management Framework (WMF) 4.0
###   »      The appropriate WMF 4.0 update
###           -     8.1/2012 R2 – KB3000850
###           -     2012 – KB3119938
###           -     7/2008 R2 SP1 – KB3109118

#####################################################################################
###   Set up functions and variables
#####################################################################################

$user = [Security.Principal.WindowsIdentity]::GetCurrent();
$userisadmin = (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)

if($userisadmin){
}
else{
	write-output "You aren't root.  Please re-launch PowerShell with Run As Administrator option to ensure proper functionality."
	exit
}

###Set up constant variables for dashboard
if(test-path .\extlogging.txt){
}
else{
	$text = "are not"
	$text | out-file extlogging.txt
}
$extlogging = [IO.File]::ReadAllText("$(pwd)\extlogging.txt")


###Configure environment
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles();
[void][reflection.assembly]::LoadWithPartialName("System.Windows.Forms")


###Set up icons
$redcheck = (get-item "$(pwd)\Icons\redcheck.png")
$greencheck = (get-item "$(pwd)\Icons\greencheck.png")
$health = (get-item "$(pwd)\Icons\systemhealth.png")
$application = (get-item "$(pwd)\Icons\application.png")

$redcheckimg = [System.Drawing.Image]::Fromfile($redcheck);
$greencheckimg = [System.Drawing.Image]::Fromfile($greencheck);
$healthimg = [System.Drawing.Image]::Fromfile($health);
$applicationimg = [System.Drawing.Image]::Fromfile($application);


Function CallScript{
	param( $scriptname )
	start-process powershell -argument "$(pwd)\$scriptname.ps1" -NoNewWindow
}


Function MoreDetails{
	param( $controlname,$text,$clickaction )
	
	$NewForm = New-Object system.Windows.Forms.Form
	$NewForm.Text = "Red vs Blue"
	$NewForm.BackColor = "#efefef"
	$NewForm.Width = 672
	$NewForm.Height = 350

	$textbox = New-Object system.windows.Forms.TextBox
	$textbox.Text = "$text"
	$textbox.location = new-object system.drawing.point(40,15)
	$textbox.font = "Segoe UI,10"
	$textbox.AutoSize = "false"
	$textbox.Multiline = "true"
	$textbox.Size = "585,200"

	$Button = New-Object system.windows.Forms.Button
	$Button.Text = "Run	 $controlname.ps1"
	$Button.ForeColor = "#000000"
	$Button.width = "300"
	$Button.height = "50"
	$Button.location = new-object system.drawing.point(177,242)
	$Button.font = "Segoe UI,10"
	$Button.Add_Click($clickaction)

	$NewForm.controls.Add($textbox)
	$NewForm.controls.Add($Button)

	[void]$NewForm.ShowDialog()
}

function CreateFormButton{
	param( $name,$text,$color,$width,$height,$locationx,$locationy,$clickaction )
	$Button = New-Object system.windows.Forms.Button
	$Button.Text = "	$text"
	$Button.ForeColor = "#$color"
	$Button.BackColor = "#bbbbbb"
	$Button.width = "$width"
	$Button.height = "$height"
	$Button.location = new-object system.drawing.point($locationx,$locationy)
	$Button.font = "Segoe UI,10"
	$Button.Add_Click($clickaction)
	$Form.controls.Add($Button)
}

function CreateRedteamButton{
	param( $name,$text,$color,$width,$height,$locationx,$locationy,$clickaction )
	$Button = New-Object system.windows.Forms.Button
	$Button.Text = "	$text"
	$Button.ForeColor = "#$color"
	$Button.width = "$width"
	$Button.height = "$height"
	$Button.location = new-object system.drawing.point($locationx,$locationy)
	$Button.font = "Segoe UI,10"
	$Button.Add_Click($clickaction)
	$Form.controls.Add($Button)
}

function drawFormLink($text,$width,$height,$font,$fontsize,$locationx,$locationy,$clickaction){
	$LinkLabel = New-Object System.Windows.Forms.LinkLabel
	$LinkLabel.LinkColor = "#000088"
	$LinkLabel.ActiveLinkColor = "RED"
	$LinkLabel.Text = "$text"
	$LinkLabel.Size = new-object System.Drawing.Size($width,$height)
	$LinkLabel.Font = "$font,$fontsize"
	$LinkLabel.Location = new-object System.Drawing.Size($locationx,$locationy)
	#The neverunderline thing was not easy to find.. here's the link:
	#https://stackoverflow.com/questions/27820164/powershell-net-clickable-link
	$LinkLabel.LinkBehavior = "NeverUnderline"
	$LinkLabel.Add_Click($clickaction)
	$Form.Controls.Add($LinkLabel)
}

function drawTextbox($name,$text,$width,$height,$locationx,$locationy,$color,$forecolor){
	$name = New-Object system.windows.Forms.TextBox
	$name.Text = "$text"
	$name.width = "$width"
	$name.height = "$height"
	$name.location = new-object system.drawing.point($locationx,$locationy)
	$name.font = "Segoe UI,10"
	$name.ForeColor = "#$forecolor"
	$Form.controls.Add($name)
}

function drawImage($image,$locationx,$locationy){
	$PictureBox = New-Object Windows.Forms.PictureBox
	$PictureBox.width = $image.Size.Width;
	$PictureBox.height = $image.Size.Height;
	$PictureBox.location = new-object system.drawing.point($locationx,$locationy)
	$PictureBox.Image = $image
	$Form.controls.Add($PictureBox)
}

function drawLabel($name,$size,$width,$height,$locationx,$locationy,$text){
	$Label = New-Object System.Windows.Forms.Label
	$Label.Location = new-object System.Drawing.Size($locationx,$locationy)
	$Label.Text = $text
	$Label.font = "Segoe UI,$size"
	$Label.width = "$width"
	$Label.height = "$height"
	$Form.Controls.Add($Label)
}

function Generate-Form{
	Add-Type -AssemblyName System.Windows.Forms
	Add-Type -AssemblyName System.Drawing

	#####################################################################################
	###   Gather system info and set up variables for later
	#####################################################################################

	###Get info about disk drives
	$cdiskinfo = Get-PSDrive C | Select-Object Used,Free
	$cpercentfree = ($cdiskinfo.Free / ($cdiskinfo.Used + $cdiskinfo.Free)) * 100
	$cdiskinfosize = $diskinfo.Used + $diskinfo.Free
	$ddiskinfo = Get-PSDrive D | Select-Object Used,Free
	$dpercentfree = ($ddiskinfo.Free / ($ddiskinfo.Used + $ddiskinfo.Free)) * 100
	$ddiskinfosize = $ddiskinfo.Used + $ddiskinfo.Free

	$onefifth = ($diskinfosize/5)
	$loginfo = Get-eventlog -list
	$seclog = $loginfo[8].MaximumKilobytes / 1024
	$syslog = $loginfo[9].MaximumKilobytes / 1024
	$applog = $loginfo[0].MaximumKilobytes / 1024
	$pslog = $loginfo[10].MaximumKilobytes / 1024


	#####################################################################################
	###   Form setup
	#####################################################################################

	###Create main form window
	$Form = New-Object system.Windows.Forms.Form
	$Form.Text = "Red vs Blue"
	$Form.BackColor = "#efefef"
	###$Form.TopMost = $true
	$Form.Width = 672
	$Form.Height = 650
	$Font = New-Object System.Drawing.Font("Segoe UI",24)
	$Form.font = $Font


	#####################################################################################
	###   Top half of form - Buttons and text boxes for blue team utilities
	#####################################################################################

	#Write a header on the top of the form
	drawLabel Header 20 700 50 155 5 "Blue Team Security Settings"

	###Draw links and text labels in window
	drawFormLink "Launch Logging.ps1" 250 30 "Segoe UI" 16 30 50 {MoreDetails Logging "This is some information about Logging, including what we will be doing and how to revert it." {CallScript Logging}}
	drawLabel Loggingtext 10 700 30 35 83 "Set up Windows logging, according to NSA Spotting the Adversary document"

	drawFormLink "Launch Sinkhole.ps1" 250 30 "Segoe UI" 16 30 110 {MoreDetails Sinkhole "This is some information about Sinkhole, including what we will be doing and how to revert it." {CallScript Sinkhole}}
	drawLabel Sinkholetext 10 700 30 35 143 "Configure routes to send malware traffic to NULL"

	drawFormLink "Launch IPINT.ps1" 250 30 "Segoe UI" 16 30 170 {MoreDetails IPINT "This is some information about IPINT, including what we will be doing and how to revert it." {CallScript IPINT}}
	drawLabel IPINTtext 10 700 30 35 203 "Open-source intelligence about IP Address information"

	drawFormLink "Launch HNIDS.ps1" 250 30 "Segoe UI" 16 30 230 {MoreDetails HNIDS "This is some information about HNIDS, including what we will be doing and how to revert it." {CallScript HNIDS}}
 	drawLabel HNIDStext 10 700 30 35 263 "Host-based Network Intrusion Detection System"

	drawFormLink "Launch VulnTrack.ps1" 250 30 "Segoe UI" 16 30 290 {MoreDetails VulnTrack "This is some information about VulnTrack, including what we will be doing and how to revert it." {CallScript VulnTrack}}
	drawLabel VulnTracktext 10 700 30 35 323 "Keep track of your vulnerabilities with alerts and email notifications"

	
	###Draw System Info section banner
	drawTextbox SystemInfo "                                                             System Health Checks" 672 7 0 365 bbbbbb 000000


	#####################################################################################
	###   Bottom half of form - system information displays
	#####################################################################################

	###Draw System Info textboxes

	if($seclog -lt 300){
		drawTextbox Secmax "Maximum Security Logfile Size is: $seclog MB" 275 30 36 400 000000 000000
		drawImage $redcheckimg 15 403
	}
	else{
		drawTextbox Secmax "Maximum Security Logfile Size is: $seclog MB" 275 30 36 400 000000 000000
		drawImage $greencheckimg 15 403
	}

	if($syslog -lt 300){
		drawTextbox Sysmax "Maximum System Logfile Size is: $syslog MB" 275 30 36 425 000000 000000
		drawImage $redcheckimg 15 428
	}
	else{
		drawTextbox Sysmax "Maximum System Logfile Size is: $syslog MB" 275 30 36 425 000000 000000
		drawImage $greencheckimg 15 428
	}

	if($applog -lt 300){
		drawTextbox Appmax "Maximum Application Logfile Size is: $applog MB" 275 30 36 450 000000 000000
		drawImage $redcheckimg 15 453
	}
	else{
		drawTextbox Appmax "Maximum Application Logfile Size is: $applog MB" 275 30 36 450 000000 000000
		drawImage $greencheckimg 15 453
	}

	if($pslog -lt 300){
		drawTextbox PSmax "Maximum Powershell Logfile Size is: $pslog MB" 275 30 36 475 000000 000000
		drawImage $redcheckimg 15 478
	}
	else{
		drawTextbox PSmax "Maximum Powershell Logfile Size is: $pslog MB" 275 30 36 475 000000 000000
		drawImage $redcheckimg 15 478
	}

	if($extlogging -match "are not"){
		drawTextbox ExtLogging "You are not doing extended logging." 275 30 36 500 000000 000000
		drawImage $redcheckimg 15 503
	}
	else{
		drawTextbox ExtLogging "You are doing extended logging." 275 30 36 500 000000 000000
		drawImage $greencheckimg 15 503
	}

	if($cpercentfree -lt 25){
		drawTextbox FreespaceC "Free C drive space is: $cpercentfree %" 275 30 36 525 000000 000000
		drawImage $redcheckimg 15 528
	}
	else{
		drawTextbox FreespaceC "Free C drive space is: $cpercentfree %" 275 30 36 525 000000 000000
		drawImage $greencheckimg 15 528
	}

	if($dpercentfree -lt 25){
		drawTextbox FreespaceD "Free D drive space is: $dpercentfree %" 275 30 36 550 000000 000000
		drawImage $redcheckimg 15 553
	}
	else{
		drawTextbox FreespaceD "Free D drive space is: $dpercentfree %" 275 30 36 550 000000 000000
		drawImage $greencheckimg 15 553
	}
	
	[void]$Form.ShowDialog()
}


#Create the form with generate function
Generate-Form


#Keep the form information updated
#Figure out why refresh isn't working
#while($i -lt 1000000){
#	sleep(500)
#	if($seclog -lt 3072000){
#		$Secmax.BackColor = 'red'
#	}
#
#	$Form.Refresh()
#	[void]$Form.ShowDialog()
#}
