Add-Type -AssemblyName System.Windows.Forms

$Form = New-Object system.Windows.Forms.Form
$Form.Text = "Red vs Blue"
$Form.BackColor = "#1613d0"
$Form.TopMost = $true
$Form.Width = 672
$Form.Height = 338

$Logging = New-Object system.windows.Forms.Button
$Logging.Text = "Logging"
$Logging.ForeColor = "#ffffff"
$Logging.Width = 85
$Logging.Height = 34
$Logging.location = new-object system.drawing.point(5,9)
$Logging.Font = "Microsoft Sans Serif,10"
$Form.controls.Add($Logging)

$Logging = New-Object system.windows.Forms.Button
$Logging.Text = "Logging"
$Logging.ForeColor = "#ffffff"
$Logging.Width = 85
$Logging.Height = 34
$Logging.location = new-object system.drawing.point(5,9)
$Logging.Font = "Microsoft Sans Serif,10"
$Form.controls.Add($Logging)

$Sinkhole = New-Object system.windows.Forms.Button
$Sinkhole.Text = "Sinkhole"
$Sinkhole.ForeColor = "#ffffff"
$Sinkhole.Width = 86
$Sinkhole.Height = 33
$Sinkhole.location = new-object system.drawing.point(6,58)
$Sinkhole.Font = "Microsoft Sans Serif,10"
$Form.controls.Add($Sinkhole)

$VulnTrack = New-Object system.windows.Forms.Button
$VulnTrack.Text = "VulnTrack"
$VulnTrack.ForeColor = "#ffffff"
$VulnTrack.Width = 85
$VulnTrack.Height = 31
$VulnTrack.location = new-object system.drawing.point(6,104)
$VulnTrack.Font = "Microsoft Sans Serif,10"
$Form.controls.Add($VulnTrack)

$VulnTrack = New-Object system.windows.Forms.Button
$VulnTrack.Text = "VulnTrack"
$VulnTrack.ForeColor = "#ffffff"
$VulnTrack.Width = 85
$VulnTrack.Height = 31
$VulnTrack.location = new-object system.drawing.point(6,104)
$VulnTrack.Font = "Microsoft Sans Serif,10"
$Form.controls.Add($VulnTrack)

$HNIDS = New-Object system.windows.Forms.Button
$HNIDS.Text = "HNIDS"
$HNIDS.ForeColor = "#fdfdfd"
$HNIDS.Width = 84
$HNIDS.Height = 36
$HNIDS.location = new-object system.drawing.point(7,146)
$HNIDS.Font = "Microsoft Sans Serif,10"
$Form.controls.Add($HNIDS)

$IPINT = New-Object system.windows.Forms.Button
$IPINT.Text = "IPINT"
$IPINT.ForeColor = "#ffffff"
$IPINT.Width = 83
$IPINT.Height = 34
$IPINT.location = new-object system.drawing.point(7,192)
$IPINT.Font = "Microsoft Sans Serif,10"
$Form.controls.Add($IPINT)

$textBox11 = New-Object system.windows.Forms.TextBox
$textBox11.Text = "Set up Windows logging, according to NSA Spotting the Adversary document"
$textBox11.Width = 473
$textBox11.Height = 20
$textBox11.location = new-object system.drawing.point(120,15)
$textBox11.Font = "Microsoft Sans Serif,10"
$Form.controls.Add($textBox11)

$textBox11 = New-Object system.windows.Forms.TextBox
$textBox11.Text = "Set up Windows logging, according to NSA Spotting the Adversary document"
$textBox11.Width = 473
$textBox11.Height = 20
$textBox11.location = new-object system.drawing.point(120,15)
$textBox11.Font = "Microsoft Sans Serif,10"
$Form.controls.Add($textBox11)

$textBox13 = New-Object system.windows.Forms.TextBox
$textBox13.Text = "Keep track of your vulnerabilities with alerts and email notifications"
$textBox13.Width = 474
$textBox13.Height = 20
$textBox13.location = new-object system.drawing.point(118,111)
$textBox13.Font = "Microsoft Sans Serif,10"
$Form.controls.Add($textBox13)

$textBox13 = New-Object system.windows.Forms.TextBox
$textBox13.Text = "Keep track of your vulnerabilities with alerts and email notifications"
$textBox13.Width = 474
$textBox13.Height = 20
$textBox13.location = new-object system.drawing.point(118,111)
$textBox13.Font = "Microsoft Sans Serif,10"
$Form.controls.Add($textBox13)

$textBox15 = New-Object system.windows.Forms.TextBox
$textBox15.Text = "Configure routes to send malware traffic to NULL"
$textBox15.Width = 474
$textBox15.Height = 20
$textBox15.location = new-object system.drawing.point(118,64)
$textBox15.Font = "Microsoft Sans Serif,10"
$Form.controls.Add($textBox15)

$textBox15 = New-Object system.windows.Forms.TextBox
$textBox15.Text = "Configure routes to send malware traffic to NULL"
$textBox15.Width = 474
$textBox15.Height = 20
$textBox15.location = new-object system.drawing.point(118,64)
$textBox15.Font = "Microsoft Sans Serif,10"
$Form.controls.Add($textBox15)

$textBox17 = New-Object system.windows.Forms.TextBox
$textBox17.Text = "Host-based Network Intrusion Detection System"
$textBox17.Width = 474
$textBox17.Height = 20
$textBox17.location = new-object system.drawing.point(118,154)
$textBox17.Font = "Microsoft Sans Serif,10"
$Form.controls.Add($textBox17)

$textBox18 = New-Object system.windows.Forms.TextBox
$textBox18.Text = "Open-source intelligence about IP Address information"
$textBox18.Width = 475
$textBox18.Height = 20
$textBox18.location = new-object system.drawing.point(118,200)
$textBox18.Font = "Microsoft Sans Serif,10"
$Form.controls.Add($textBox18)

$button19 = New-Object system.windows.Forms.Button
$button19.Text = "Party Mode (Red Team)"
$button19.ForeColor = "#fdfdfd"
$button19.Width = 299
$button19.Height = 51
$button19.location = new-object system.drawing.point(177,242)
$button19.Font = "Microsoft Sans Serif,10"
$Form.controls.Add($button19)

[void]$Form.ShowDialog()
$Form.Dispose()
