#####################################################################################
###   Sysmon install and tweaks
#####################################################################################
# Further info on sysmon installation:
# https://cqureacademy.com/blog/server-monitoring/sysmon

$sysmoninstalled = test-path "C:\Windows\System32\winevt\Logs\Microsoft-Windows-Sysmon%4Operational.evtx"

if($sysmoninstalled -eq "True"){
	write-host > "$(pwd)\extlogging.txt"
}
else{
	& "$(pwd)\sysmon.exe" -accepteula -i -h md5,sha256 -l -n
}


#####################################################################################
###   Gather information about system state
#####################################################################################

#Grab info about event logs and check for custom collection - "is this already set up?"
#Get info about disk drives
$diskinfo = Get-PSDrive C | Select-Object Used,Free
$percentfree = $diskinfo.Free / ($diskinfo.Used + $diskinfo.Free)
$diskinfosize = $diskinfo.Used + $diskinfo.Free
$onefifth = ($diskinfosize/5)
	
#Get info about Event Logs
$loginfo = Get-eventlog -list
$seclog = $loginfo[8].MaximumKilobytes
$syslog = $loginfo[9].MaximumKilobytes	
$applog = $loginfo[0].MaximumKilobytes
$pslog = $loginfo[10].MaximumKilobytes
$sysmonlog = Get-WinEvent -ListLog "Microsoft-Windows-Sysmon/Operational"

#Warning message to abort if disk space is low
#3221225472 bytes is 3GB
if($diskinfo.Free -lt 3221225472){
	$question = read-host "You are critically low on storage.  Please reconsider increasing your free space before continuing.  If you still want to proceed, type OKAY."
	if($question -eq "OKAY"){
		
	}
	else{
		return
	}
}


#####################################################################################
###   Increase logging to max of 300MB
#####################################################################################

#300MB, in bytes is 314572800
#300MB, in Kilobytes is 307200
if($applog -lt 307200){
	limit-eventlog -logname "Application" -MaximumSize 300MB
}
if($seclog -lt 307200){
	limit-eventlog -logname "Security" -MaximumSize 300MB
}
if($syslog -lt 307200){
	limit-eventlog -logname "System" -MaximumSize 300MB
}
if($pslog -lt 307200){
	limit-eventlog -logname "Windows Powershell" -MaximumSize 300MB		
}
if($pslog -lt 307200){
	limit-eventlog -logname "Windows Powershell" -MaximumSize 300MB		
}
if($sysmonlog.MaximumSizeInBytes -lt 2147483648){
	wevtutil sl Microsoft-Windows-Sysmon/Operational /ms:2147483648
}


#####################################################################################
###   Registry mods for Powershell logging
#####################################################################################
# Credit to matthewdunwoody for the registry imports
# https://github.com/matthewdunwoody/PS_logging_reg

# Get info about installed versions of PowerShell
# Credit to Jaykul for script that grabs .NET Version
# https://stackoverflow.com/questions/3487265/powershell-script-to-return-versions-of-net-framework-on-a-machine

$dotnetver = Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP' -recurse |
Get-ItemProperty -name Version,Release -EA 0 |
Where { $_.PSChildName -match '^(?!S)\p{L}'} |
Select PSChildName, Version, Release, @{
  name="Product"
  expression={
      switch -regex ($_.Release) {
        "378389" { [Version]"4.5" }
        "378675|378758" { [Version]"4.5.1" }
        "379893" { [Version]"4.5.2" }
        "393295|393297" { [Version]"4.6" }
        "394254|394271" { [Version]"4.6.1" }
        "394802|394806" { [Version]"4.6.2" }
        "460798" { [Version]"4.7" }
        {$_ -gt 460798} { [Version]"Undocumented 4.7 or higher, please update script" }
      }
    }
}

# Sort table in descending order
$dotnetver = $dotnetver | sort Version

# Grab the largest entry in the table for reference
$dotnetcheck = $dotnetver.Version[$dotnetver.length-1]

if($dotnetcheck -ge 4.5){
	# Check for WMF 4.0 and WMF 5.0 - Should be PSVersion 5 or above
	$version = $PSVersionTable.PSVersion

	if($version.Major -ge 5){
		# Apply registry changes to enable extended logging
		& regedit /s "$(pwd)\PS_logging.reg"
	}
	else{
		write-host "You must upgrade your PowerShell (WMF) version to 5 or above to get full logging capabilities.  Please close this window, upgrade to version 5 and re-run this script."
	}
}

else{
	write-host "You must upgrade your .NET version to 4.5 or above to get full logging capabilities.  Please close this window, upgrade to version 4.5 and re-run this script."
}