#####################################################################################
###   Set up variables
#####################################################################################
$Yesterday = (Get-Date) - (New-TimeSpan -Day 1)
$FormatEnumerationLimit=-1

#####################################################################################
###   Get network connections from Sysmon event log
#####################################################################################
#
###---> Need to approach this the opposite way
###------> Get all IP addys from Events and scan each against blacklist.txt
#
#Get list of suspicious IP Addresses to scan
if(test-path .\blacklist.txt){
	write-output "Looks like you already have the blacklist"
	#Filter out non-ip addresses from list
	$blacklist = get-content blacklist.txt | select-string -pattern "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$" | sort-object | Get-Unique
}

if((test-path .\blacklist.txt) -eq $False){
	#Set error action to silent, to suppress info
	$ErrorActionPreference = "SilentlyContinue"

	#Notify user that we are downloading blacklists
	write-output "Downloading blacklists... please wait..."

	#Retreive blacklist hosts from various sources
	$greensnow = (invoke-webrequest -URI "blocklist.greensnow.co/greensnow.txt" -UseBasicParsing -TimeoutSec 60)
	$bambenek = (invoke-webrequest -URI "osint.bambenekconsulting.com/feeds/c2-ipmasterlist.txt" -UseBasicParsing -TimeoutSec 60)
	$alienvault = (invoke-webrequest -URI "https://reputation.alienvault.com/reputation.unix" -UseBasicParsing -TimeoutSec 60)
	$binarybanlist = (invoke-webrequest -URI "https://www.binarydefense.com/banlist.txt" -UseBasicParsing -TimeoutSec 60)
	$binarytorlist = (invoke-webrequest -URI "https://www.binarydefense.com/tor.txt" -UseBasicParsing -TimeoutSec 60)
	$blocklistde = (invoke-webrequest -URI "https://lists.blocklist.de/lists/all.txt" -UseBasicParsing -TimeoutSec 60)

	#Echo all ip addresses out into a full blacklist file
	$greensnow.rawcontent > blacklist.txt
	$banbenek.rawcontent >> blacklist.txt
	$alientvault.rawcontent >> blacklist.txt
	$binarybanlist.rawcontent >> blacklist.txt
	$binarytorlist.rawcontent >> blacklist.txt
	$blocklistde.rawcontent >> blacklist.txt

	#Filter out non-ip addresses from list
	$blacklist = get-content blacklist.txt | select-string -pattern "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$" | sort-object | Get-Unique

	#Notify user that setup tasks are done
	write-output "Done downloading and setting up blacklist files"
}


<#
foreach($ipaddy in $blacklist){
	write-output "Checking for $ipaddy"
	Get-WinEvent -FilterHashTable @{ logname = "Microsoft-Windows-Sysmon/Operational"; Id = 3; StartTime=$Yesterday } -erroraction silentlycontinue | Where-Object {$_.Message -Like "*$ipaddy*" } | fl *
}
#>

$netevents = Get-WinEvent -FilterHashTable @{ logname = "Microsoft-Windows-Sysmon/Operational"; Id = 3; StartTime=$Yesterday } -erroraction silentlycontinue | Where-Object {$_.Message -Like "*DestinationIP*" } | fl * | out-string | select-string -Pattern "DestinationIP..[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" -All | Select Matches | sort-object | get-unique

#Get full array without truncation, then put a string out
$neteventsstring = $netevents | ft -wrap -autosize | out-string

#Split string into array
$neteventssplit = $neteventsstring.split(",")

#Remove excess info
$neteventssplit = $neteventssplit.replace("DestinationIp:","")
$neteventssplit = $neteventssplit.replace("Matches","")
$neteventssplit = $neteventssplit.replace("-------","")
$neteventssplit = $neteventssplit.replace("{","")
$neteventssplit = $neteventssplit.replace("}","")

#Loop through array and move objects into a proper array variable
$netarr = @()
foreach($ip in $neteventssplit)
{
	$netarr += $ip.Trim()
}

#Dedupe info
$netarr = $netarr | sort-object | get-unique

foreach($ipaddy in $netarr){
	write-output "Checking for $ipaddy"
	$blacklist | sls $ipaddy
}

#####################################################################################
###   Get file info from Sysmon event log
#####################################################################################

#Search Sysmon events for MD5s
#Get all events from last 24 hours where an MD5 is involved, and just get the MD5 matches, then sort and dedupe
$md5events = Get-WinEvent -FilterHashTable @{ logname = "Microsoft-Windows-Sysmon/Operational"; Id = 1; StartTime=$Yesterday } -erroraction silentlycontinue | Where-Object {$_.Message -Like "*MD5*" } | fl * | out-string | select-string -Pattern "MD5=................................" -All | Select Matches | sort-object | get-unique

#Get full array without truncation, then put a string out
$md5eventsstring = $md5events | ft -wrap -autosize | out-string

#Split string into array
$md5eventssplit = $md5eventstring.split(",")

#Remove excess info
$md5eventssplit = $md5eventssplit.replace("MD5=","")
$md5eventssplit = $md5eventssplit.replace("Matches","")
$md5eventssplit = $md5eventssplit.replace("-------","")
$md5eventssplit = $md5eventssplit.replace("{","")
$md5eventssplit = $md5eventssplit.replace("}","")

#Loop through array and move objects into a proper array variable
$md5arr = @()
foreach($md5 in $md5eventssplit)
{
	$md5arr += $md5.Trim()
}

#Dedupe info
$md5arr = $md5arr | sort-object | get-unique


#Take MD5 list and scan with VirusTotal API
#Install Posh-VirusTotal module
iex (New-Object Net.WebClient).DownloadString("https://gist.githubusercontent.com/darkoperator/9138373/raw/22fb97c07a21139a398c2a3d6ca7e3e710e476bc/PoshVTInstall.ps1")

#########################################################################################
###   Specify VirusTotal API Key
#########################################################################################

Set-VTAPIKey -APIKey efffc8248da060451491096897a3d4a05f6d0641c9eb93a54c3f95e46411f27e -MasterPassword What_The_Fuck_THISISBS$#@!



<#

#This one seems to be the best so far.. it just doesn't sort/unique properly



write-output " "
	
$md5listnew = Get-WinEvent -FilterHashTable @{ logname = "Microsoft-Windows-Sysmon/Operational"; Id = 1; StartTime=$Yesterday } -erroraction silentlycontinue | Where-Object {$_.Message -Like "*MD5*" } | fl * | out-string | select-string -Pattern "MD5=................................" -All | Select Matches | out-string | sort-object | get-unique

	$FormatEnumerationLimit=-1
	$md5listnew | ft -wrap -autosize


$md5eventstring = Get-WinEvent -FilterHashTable @{ logname = "Microsoft-Windows-Sysmon/Operational"; Id = 1; StartTime=$Yesterday } -erroraction silentlycontinue | Where-Object {$_.Message -Like "*MD5*" } | fl * | out-string

$md5listlong = $md5eventstring | sls -Pattern "MD5=................................" -All | Select Matches
$md5liststring = $md5listlong | out-string

$md5list = $md5liststring -replace "MD5=", ""

$newmd5list = @()
foreach($md5 in $md5list){
	$md5
}

#>
