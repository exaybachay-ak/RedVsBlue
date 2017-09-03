#Credit to creator of POSHGUI - https://poshgui.com/#
#Set up functions
Function CallScript{
	param( $scriptname )
	. "$(pwd)\$scriptname.ps1"
}

Function MoreDetails($controlname,$text,$clickaction){
	Add-Type -AssemblyName System.Windows.Forms
	Add-Type -AssemblyName System.Drawing
	
	$NewForm = New-Object system.Windows.Forms.Form
	$NewForm.Text = "Red vs Blue"
	$NewForm.BackColor = "#0033ff"
	$NewForm.TopMost = $true
	$NewForm.Width = 672
	$NewForm.Height = 338

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

function drawTextbox($name,$text,$width,$height,$locationx,$locationy){
	$name = New-Object system.windows.Forms.TextBox
	$name.Text = "$text"
	$name.width = "$width"
	$name.height = "$height"
	$name.location = new-object system.drawing.point($locationx,$locationy)
	$name.font = "Microsoft Sans Serif,10"
	$Form.controls.Add($name)
}

function Generate-Form{
	Add-Type -AssemblyName System.Windows.Forms
	Add-Type -AssemblyName System.Drawing

	#Create main form window
	$Form = New-Object system.Windows.Forms.Form
	$Form.Text = "Red vs Blue"
	$Form.BackColor = "#0033ff"
	$Form.TopMost = $true
	$Form.Width = 672
	$Form.Height = 338


	#Set up background image
	$Image = [system.drawing.image]::FromFile("$(pwd)\blueverticalstripes.jpg")
	$Form.BackgroundImage = $Image
	$Form.BackgroundImageLayout = "Stretch"
	    # None, Tile, Center, Stretch, Zoom


	#Draw buttons in window
	CreateFormButton Logging Logging ffffff 86 33 6 9 {MoreDetails Logging "This is some information about logging, including what we will be doing and how to revert it." {CallScript Logging}}
	CreateFormButton Sinkhole Sinkhole ffffff 86 33 6 58 {MoreDetails Sinkhole "This is some information about Sinkhole, including what we will be doing and how to revert it." {CallScript Sinkhole}}
	CreateFormButton VulnTrack VulnTrack ffffff 86 33 6 104 {MoreDetails VulnTrack "This is some information about VulnTrack, including what we will be doing and how to revert it." {CallScript VulnTrack}}
	CreateFormButton HNIDS HNIDS ffffff 86 33 6 146 {MoreDetails HNIDS "This is some information about HNIDS, including what we will be doing and how to revert it." {CallScript HNIDS}}
	CreateFormButton IPINT IPINT ffffff 86 33 6 192 {MoreDetails IPINT "This is some information about IPINT, including what we will be doing and how to revert it." {CallScript IPINT}}
	CreateRedteamButton Redteam "Red Team" ffffff 300 50 177 242 {MoreDetails Redteam "This is some information about Red team, including what we will be doing and how to revert it." {CallScript Redteam}}

	#Draw text boxes in window
	drawTextbox Loggingtext "Set up Windows logging, according to NSA Spotting the Adversary document" 473 20 120 15
	drawTextbox VulnTracktext "Keep track of your vulnerabilities with alerts and email notifications" 473 20 120 111
	drawTextbox Sinkholetext "Configure routes to send malware traffic to NULL" 473 20 120 64
	drawTextbox HNIDStext "Host-based Network Intrusion Detection System" 473 20 120 154
	drawTextbox IPINTtext "Open-source intelligence about IP Address information" 473 20 120 200
	
	[void]$Form.ShowDialog()
	#$Form.Dispose()

}


#Create the form with generate function
Generate-Form
