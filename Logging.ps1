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

#Warning message to abort if disk space is low
#1073741824 bytes is 1GB
if($diskinfo.Free -lt 1073741824){
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

#####################################################################################
###   Sysmon install and tweaks
#####################################################################################
# Further info on sysmon installation:
# https://cqureacademy.com/blog/server-monitoring/sysmon

& "$(pwd)\Sysmon\sysmon.exe" -accepteula -i -h md5 -l -n


#####################################################################################
###   Registry mods for Powershell logging
#####################################################################################
# Credit to matthewdunwoody for the registry imports
# https://github.com/matthewdunwoody/PS_logging_reg

# First thing it to check status of current powershell environment
# 

#& "C:\Program Files\Google\Chrome\Application\chrome.exe" --load-extension="$(pwd)\IPINT-master"
& regedit "$(pwd)\PS_logging_reg-master\PS_logging.reg"

$sysmoninstalled = test-path "C:\Windows\System32\winevt\Logs\Microsoft-Windows-Sysmon%4Operational.evtx"

if($sysmoninstalled -eq "True"){
	write-host > "$(pwd)\extlogging.txt"
}
else{
	
}