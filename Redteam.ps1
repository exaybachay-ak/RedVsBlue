#Credit to creator of POSHGUI - https://poshgui.com/#
#Set up functions
Function CallScript{
	param( $scriptname )
	. "$(pwd)\$scriptname.ps1"
	return
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
	$Form.BackColor = "#ff3300"
	$Form.TopMost = $true
	$Form.Width = 672
	$Form.Height = 388


	#Set up background image
	$Image = [system.drawing.image]::FromFile("$(pwd)\redverticalstripes.jpg")
	$Form.BackgroundImage = $Image
	$Form.BackgroundImageLayout = "Stretch"
	    # None, Tile, Center, Stretch, Zoom


	#Draw buttons in window
	CreateFormButton Potemkin Potemkin ffffff 106 33 6 9 {CallScript Potemkin}
	CreateFormButton PassiveRecon PassiveRecon ffffff 106 33 6 60 {CallScript PassiveRecon}
	CreateFormButton PowerSteg PowerSteg ffffff 106 33 6 104 {CallScript PowerSteg}
	CreateFormButton Grayb0x Grayb0x ffffff 106 33 6 146 {CallScript Grayb0x}
	CreateFormButton Keylogger Keylogger ffffff 106 33 6 192 {CallScript Keylogger}
	CreateFormButton BSEXEC BSEXEC ffffff 106 33 6 242 {CallScript BSEXEC}
	CreateFormButton PowerShift PowerShift ffffff 106 33 6 292 {CallScript PowerShift}

	#Draw text boxes in window
	drawTextbox Potemkintext "Full red team project platform with C2 ability" 473 20 120 14
	drawTextbox PassiveRecontext "Scan target network without touching their property" 473 20 120 64
	drawTextbox PowerStegtext "Powershell Backdoor with Stego" 473 20 120 108
	drawTextbox Grayb0xtext "Local vulnerability scanner and network scanner" 473 20 120 150
	drawTextbox Keyloggertext "Custom keylogger" 473 20 120 196
	drawTextbox BSEXECtext "Psexec alternative" 473 20 120 246
	drawTextbox PowerShifttext "Data exfiltration with rot encryption" 473 20 120 295
	
	[void]$Form.ShowDialog()
	#$Form.Dispose()

}


#Create the form with generate function
Generate-Form