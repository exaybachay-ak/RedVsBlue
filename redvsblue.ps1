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
###
###   4. Write a function that looks through logs for NSA spotting the adversary each day
###   -should be able to go back, but may only work with enhanced logging set up
### 
###   5. Add function for AmICompromised.ps1
###   -just another status at the bottom, if its running or not
###   --maybe i should do a service instead?
###   ---i am interested in learning service wrappers with powershell  
###   -add further functionality to AIC.ps1
###   --check sysmon for outbound MD5 hashes against VT and other IOC feeds
###
#####################################################################################
###    https://stackoverflow.com/questions/27242315/powershell-button-image
###
###      Use this for drawing images instead of buttons
###      -basically need this to make my app look clean and modern
###      --try this for a template/example:
###         https://thielj.github.io/MetroFramework/
###           http://www.glyfx.com/content/page/free.html
###
#https://stackoverflow.com/questions/33703/how-can-you-make-a-net-windows-forms-project-look-fresh
###      ^^^ Use these ideas to make it look cleaner
###      -tahoma font, icons from above, black/white/light blue
###
#####################################################################################
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
	###this works, but isn't good enough - need to spawn another window
	###. "$(pwd)\$scriptname.ps1"
	start-process powershell -argument "$(pwd)\$scriptname.ps1" -NoNewWindow
	###start-process powershell -argument "$(pwd)\$scriptname.ps1"
	###invoke-expression 'cmd /c start powershell -Command { $scriptname.ps1;pause }'
	###start powershell { $scriptname.ps1; Read-Host }
	###start-Process powershell { $scriptname.ps1; Read-Host }
	###invoke-expression 'cmd /c start powershell -Command { [$scriptname.ps1;Read-Host] }'
	###invoke-expression 'cmd /c start powershell -Command { $scriptname.ps1; Read-Host}'
	###start-process powershell -ArgumentList '-noexit -command '$scriptname.ps1;Read-Host''
}


Function MoreDetails{
	param( $controlname,$text,$clickaction )
	
	$NewForm = New-Object system.Windows.Forms.Form
	$NewForm.Text = "Red vs Blue"
	$NewForm.BackColor = "#0033ff"
	###$NewForm.TopMost = $true
	$NewForm.Width = 672
	$NewForm.Height = 350

	$textbox = New-Object system.windows.Forms.TextBox
	$textbox.Text = "$text"
	$textbox.location = new-object system.drawing.point(40,15)
	#$textbox.font = "Tahoma,10"
	$textbox.font = "Segoe UI,10"
	$textbox.AutoSize = "false"
	$textbox.Multiline = "true"
	$textbox.Size = "585,200"

	$Button = New-Object system.windows.Forms.Button
	$Button.Text = "Run	 $controlname.ps1"
	$Button.ForeColor = "#ffffff"
	$Button.width = "300"
	$Button.height = "50"
	$Button.location = new-object system.drawing.point(177,242)
	#$Button.font = "Tahoma,10"
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
	#$Button.font = "Tahoma,10"
	$Button.font = "Segoe UI,10"
	###works - $name.Add_Click({Button_OnClick})
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
	#$Button.font = "Tahoma,10"
	$Button.font = "Segoe UI,10"
	###works - $name.Add_Click({Button_OnClick})
	$Button.Add_Click($clickaction)
	$Form.controls.Add($Button)
}

function drawTextbox($name,$text,$width,$height,$locationx,$locationy,$color,$forecolor){
	$name = New-Object system.windows.Forms.TextBox
	$name.Text = "$text"
	$name.width = "$width"
	$name.height = "$height"
	$name.location = new-object system.drawing.point($locationx,$locationy)
	#$name.font = "Tahoma,10"
	$name.font = "Segoe UI,10"
	#$name.BackColor = "#$color"
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

function Generate-Form{
	Add-Type -AssemblyName System.Windows.Forms
	Add-Type -AssemblyName System.Drawing

	#####################################################################################
	###   Gather system info and set up variables for later
	#####################################################################################

	###Gather system info
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
	$Form.BackColor = "#ffffff"
	###$Form.TopMost = $true
	$Form.Width = 672
	$Form.Height = 650


	#####################################################################################
	###   Top half of form - Buttons and text boxes for blue team utilities
	#####################################################################################

	###Draw buttons in window
	CreateFormButton Logging Logging 000000 86 33 6 9 {MoreDetails Logging "This is some information about logging, including what we will be doing and how to revert it." {CallScript Logging}}
	CreateFormButton Sinkhole Sinkhole 000000 86 33 6 58 {MoreDetails Sinkhole "This is some information about Sinkhole, including what we will be doing and how to revert it." {CallScript Sinkhole}}
###	CreateFormButton VulnTrack VulnTrack 000000 86 33 6 104 {MoreDetails VulnTrack "This is some information about VulnTrack, including what we will be doing and how to revert it." {CallScript VulnTrack}}
###	CreateFormButton HNIDS HNIDS 000000 86 33 6 146 {MoreDetails HNIDS "This is some information about HNIDS, including what we will be doing and how to revert it." {CallScript HNIDS}}
	CreateFormButton IPINT IPINT 000000 86 33 6 192 {MoreDetails IPINT "This is some information about IPINT, including what we will be doing and how to revert it." {CallScript IPINT}}
	CreateRedteamButton Redteam "Red Team" 000000 300 50 177 542 {MoreDetails Redteam "This is some information about Red team, including what we will be doing and how to revert it." {CallScript Redteam}}

	###Draw text boxes in window
	drawTextbox Loggingtext "Set up Windows logging, according to NSA Spotting the Adversary document" 473 20 120 15 eeeeee 000000
###	drawTextbox VulnTracktext "Keep track of your vulnerabilities with alerts and email notifications" 473 20 120 111 eeeeee 000000
	drawTextbox Sinkholetext "Configure routes to send malware traffic to NULL" 473 20 120 64 eeeeee 000000
###	drawTextbox HNIDStext "Host-based Network Intrusion Detection System" 473 20 120 154 eeeeee 000000
	drawTextbox IPINTtext "Open-source intelligence about IP Address information" 473 20 120 200 eeeeee 000000
	
	###Draw System Info section banner
	drawTextbox SystemInfo "                                                             System Health Checks" 672 7 0 250 bbbbbb 000000


	#####################################################################################
	###   Bottom half of form - system information displays
	#####################################################################################

	###Draw System Info textboxes
	if($seclog -lt 300){
		drawTextbox Secmax "Maximum Security Logfile Size is: $seclog MB" 275 30 36 300 000000 000000
		drawImage $redcheckimg 15 305
	}
	else{
		drawTextbox Secmax "Maximum Security Logfile Size is: $seclog MB" 275 30 36 300 000000 000000
		drawImage $greencheckimg 15 305
	}

	if($syslog -lt 300){
		drawTextbox Sysmax "Maximum System Logfile Size is: $syslog MB" 275 30 36 325 000000 000000
		drawImage $redcheckimg 15 329
	}
	else{
		drawTextbox Sysmax "Maximum System Logfile Size is: $syslog MB" 275 30 36 325 000000 000000
		drawImage $greencheckimg 15 329
	}

	if($applog -lt 300){
		drawTextbox Appmax "Maximum Application Logfile Size is: $applog MB" 275 30 36 350 000000 000000
		drawImage $redcheckimg 15 354
	}
	else{
		drawTextbox Appmax "Maximum Application Logfile Size is: $applog MB" 275 30 36 350 000000 000000
		drawImage $greencheckimg 15 354
	}

	if($pslog -lt 300){
		drawTextbox PSmax "Maximum Powershell Logfile Size is: $pslog MB" 275 30 36 375 000000 000000
		drawImage $redcheckimg 15 379
	}
	else{
		drawTextbox PSmax "Maximum Powershell Logfile Size is: $pslog MB" 275 30 36 375 000000 000000
		drawImage $redcheckimg 15 379
	}

	if($extlogging -match "are not"){
		drawTextbox ExtLogging "You are not doing extended logging." 275 30 36 400 000000 000000
		drawImage $redcheckimg 15 404
	}
	else{
		drawTextbox ExtLogging "You are doing extended logging." 275 30 36 400 000000 000000
		drawImage $greencheckimg 15 404
	}

	if($cpercentfree -lt 25){
		drawTextbox FreespaceC "Free C drive space is: $cpercentfree %" 275 30 375 300 000000 000000
		drawImage $redcheckimg 350 304
	}
	else{
		drawTextbox FreespaceC "Free C drive space is: $cpercentfree %" 275 30 375 300 000000 000000
		drawImage $greencheckimg 350 304
	}

	if($dpercentfree -lt 25){
		drawTextbox FreespaceD "Free D drive space is: $dpercentfree %" 275 30 375 325 000000 000000
		drawImage $redcheckimg 350 329
	}
	else{
		drawTextbox FreespaceD "Free D drive space is: $dpercentfree %" 275 30 375 325 000000 000000
		drawImage $greencheckimg 350 329
	}

	#Draw an image real quick for testing
	#drawImage $greencheckimg 300 100
	
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
