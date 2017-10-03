#Credit to creator of POSHGUI - https://poshgui.com/#

$user = [Security.Principal.WindowsIdentity]::GetCurrent();
(New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)

if($user -contains "False"){
	#drawTextbox UserInfo "You are NOT running as root" 275 30 375 350 ff0000
	#remove-item $Form
	return $null
	write-output "You aren't root!!!"
}
else{
	#drawTextbox UserInfo "You are running as root" 275 30 375 350 00ff00
}

#Set up constant variables for dashboard
if(test-path .\extlogging.txt){
}
else{
	$text = "are not"
	$text | out-file extlogging.txt
}
$extlogging = [IO.File]::ReadAllText("$(pwd)\extlogging.txt")


#Configure environment
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

#####################################################################################
###   To Do
#####################################################################################
###   1. Set up checks for powershell and .NET versions
###   -need to see if all 3 are True, otherwise redirect user to updates for .NET etc
###   2. Make a /all options, for GPO deployment of all blue team settings
###   -sysmon, 300MB logs, PS Logging, IPINT, vulntrack, etc
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
#####################################################################################
###   Set up functions
#####################################################################################

Function CallScript{
	param( $scriptname )
	#this works, but isn't good enough - need to spawn another window
	#. "$(pwd)\$scriptname.ps1"
	start-process powershell -argument "$(pwd)\$scriptname.ps1" -NoNewWindow
	#start-process powershell -argument "$(pwd)\$scriptname.ps1"
	#invoke-expression 'cmd /c start powershell -Command { $scriptname.ps1;pause }'
	#start powershell { $scriptname.ps1; Read-Host }
	#start-Process powershell { $scriptname.ps1; Read-Host }
	#invoke-expression 'cmd /c start powershell -Command { [$scriptname.ps1;Read-Host] }'
	#invoke-expression 'cmd /c start powershell -Command { $scriptname.ps1; Read-Host}'
	#start-process powershell -ArgumentList '-noexit -command '$scriptname.ps1;Read-Host''
}


Function MoreDetails{
	param( $controlname,$text,$clickaction )
	
	$NewForm = New-Object system.Windows.Forms.Form
	$NewForm.Text = "Red vs Blue"
	$NewForm.BackColor = "#0033ff"
	#$NewForm.TopMost = $true
	$NewForm.Width = 672
	$NewForm.Height = 350

	#Set up background image
	$Image = [system.drawing.image]::FromFile("$(pwd)\blueverticalstripes.jpg")
	$NewForm.BackgroundImage = $Image
	$NewForm.BackgroundImageLayout = "Stretch"
	    # None, Tile, Center, Stretch, Zoom

	$textbox = New-Object system.windows.Forms.TextBox
	$textbox.Text = "$text"
	$textbox.location = new-object system.drawing.point(40,15)
	$textbox.font = "Microsoft Sans Serif,10"
	$textbox.AutoSize = "false"
	$textbox.Multiline = "true"
	$textbox.Size = "585,200"

	$Button = New-Object system.windows.Forms.Button
	$Button.Text = "Run	 $controlname.ps1"
	$Button.ForeColor = "#ffffff"
	$Button.width = "300"
	$Button.height = "50"
	$Button.location = new-object system.drawing.point(177,242)
	$Button.font = "Microsoft Sans Serif,10"
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
	$Button.BackColor = "#0000ff"
	$Button.width = "$width"
	$Button.height = "$height"
	$Button.location = new-object system.drawing.point($locationx,$locationy)
	$Button.font = "Microsoft Sans Serif,10"
	#works - $name.Add_Click({Button_OnClick})
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
	$Button.font = "Microsoft Sans Serif,10"
	#works - $name.Add_Click({Button_OnClick})
	$Button.Add_Click($clickaction)
	$Form.controls.Add($Button)
}

function drawTextbox($name,$text,$width,$height,$locationx,$locationy,$color,$forecolor){
	$name = New-Object system.windows.Forms.TextBox
	$name.Text = "$text"
	$name.width = "$width"
	$name.height = "$height"
	$name.location = new-object system.drawing.point($locationx,$locationy)
	$name.font = "Microsoft Sans Serif,10"
	$name.BackColor = "#$color"
	$name.ForeColor = "#$forecolor"
	$Form.controls.Add($name)
}

function Generate-Form{
	Add-Type -AssemblyName System.Windows.Forms
	Add-Type -AssemblyName System.Drawing

	#####################################################################################
	###   Gather system info and set up variables for later
	#####################################################################################

	#Gather system info
	#Get info about disk drives
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

	#Create main form window
	$Form = New-Object system.Windows.Forms.Form
	$Form.Text = "Red vs Blue"
	$Form.BackColor = "#0033ff"
	#$Form.TopMost = $true
	$Form.Width = 672
	$Form.Height = 650


	#Set up background image
	$Image = [system.drawing.image]::FromFile("$(pwd)\blueverticalstripes.jpg")
	$Form.BackgroundImage = $Image
	$Form.BackgroundImageLayout = "Stretch"
	    # None, Tile, Center, Stretch, Zoom


	#####################################################################################
	###   Top half of form - Buttons and text boxes for blue team utilities
	#####################################################################################

	#Draw buttons in window
	CreateFormButton Logging Logging ffffff 86 33 6 9 {MoreDetails Logging "This is some information about logging, including what we will be doing and how to revert it." {CallScript Logging}}
	CreateFormButton Sinkhole Sinkhole ffffff 86 33 6 58 {MoreDetails Sinkhole "This is some information about Sinkhole, including what we will be doing and how to revert it." {CallScript Sinkhole}}
	CreateFormButton VulnTrack VulnTrack ffffff 86 33 6 104 {MoreDetails VulnTrack "This is some information about VulnTrack, including what we will be doing and how to revert it." {CallScript VulnTrack}}
	CreateFormButton HNIDS HNIDS ffffff 86 33 6 146 {MoreDetails HNIDS "This is some information about HNIDS, including what we will be doing and how to revert it." {CallScript HNIDS}}
	CreateFormButton IPINT IPINT ffffff 86 33 6 192 {MoreDetails IPINT "This is some information about IPINT, including what we will be doing and how to revert it." {CallScript IPINT}}
	CreateRedteamButton Redteam "Red Team" ffffff 300 50 177 542 {MoreDetails Redteam "This is some information about Red team, including what we will be doing and how to revert it." {CallScript Redteam}}

	#Draw text boxes in window
	drawTextbox Loggingtext "Set up Windows logging, according to NSA Spotting the Adversary document" 473 20 120 15 ffffff 000000
	drawTextbox VulnTracktext "Keep track of your vulnerabilities with alerts and email notifications" 473 20 120 111 ffffff 000000
	drawTextbox Sinkholetext "Configure routes to send malware traffic to NULL" 473 20 120 64 ffffff 000000
	drawTextbox HNIDStext "Host-based Network Intrusion Detection System" 473 20 120 154 ffffff 000000
	drawTextbox IPINTtext "Open-source intelligence about IP Address information" 473 20 120 200 ffffff 000000
	
	#Draw System Info section banner
	drawTextbox SystemInfo "                                                         V--V--V--V   System Health Information  V--V--V--V" 672 7 0 250 0000ff ffffff


	#####################################################################################
	###   Bottom half of form - system information displays
	#####################################################################################

	#Draw System Info textboxes
	if($seclog -lt 300){
		drawTextbox Secmax "Maximum Security Logfile Size $seclog MB" 275 30 6 300 ff0000 000000
	}
	else{
		drawTextbox Secmax "Maximum Security Logfile Size $seclog MB" 275 30 6 300 00ff00 000000
	}

	if($syslog -lt 300){
		drawTextbox Sysmax "Maximum System Logfile Size $syslog MB" 275 30 6 325 ff0000 000000
	}
	else{
		drawTextbox Sysmax "Maximum System Logfile Size $syslog MB" 275 30 6 325 00ff00 000000
	}

	if($applog -lt 300){
		drawTextbox Appmax "Maximum Application Logfile Size $applog MB" 275 30 6 350 ff0000 000000
	}
	else{
		drawTextbox Appmax "Maximum Application Logfile Size $applog MB" 275 30 6 350 00ff00 000000
	}

	if($pslog -lt 300){
		drawTextbox PSmax "Maximum Powershell Logfile Size $pslog MB" 275 30 6 375 ff0000 000000
	}
	else{
		drawTextbox PSmax "Maximum Powershell Logfile Size $pslog MB" 275 30 6 375 00ff00 000000
	}

	if($cpercentfree -lt 25){
		drawTextbox FreespaceC "Free C drive space is $cpercentfree %" 275 30 375 300 ff0000 000000
	}
	else{
		drawTextbox FreespaceC "Free C drive space is $cpercentfree %" 275 30 375 300 00ff00 000000
	}

	if($dpercentfree -lt 25){
		drawTextbox FreespaceD "Free D drive space is $dpercentfree %" 275 30 375 325 ff0000 000000
	}
	else{
		drawTextbox FreespaceD "Free D drive space is $dpercentfree %" 275 30 375 325 00ff00 000000
	}

	if($extlogging -match "are not"){
		drawTextbox ExtLogging "You are not doing extended logging." 275 30 6 400 ff0000 000000
	}
	else{
		drawTextbox ExtLogging "You are doing extended logging." 275 30 6 400 00ff00 000000
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
