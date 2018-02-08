#####################################################################################
###   Set up variables, API key, and import modules
#####################################################################################
$Yesterday = (Get-Date) - (New-TimeSpan -Day 1)
$FormatEnumerationLimit=-1
$apikey = Read-Host -Prompt "HNIDS.ps1 relies on VirusTotal intelligence.  Enter your VirusTotal API Key to continue"
if (!$apikey -or $apikey.length -lt 64){
	write-output "You must enter a valid API key to use this script.  Please retry, using a valid VT API Key"
	exit
}

#Import VirusTotal API module
# CREDIT TO David B Heise
#   https://archive.codeplex.com/?p=psvirustotal
Unblock-file .\psvirustotal\VirusTotal.psm1
Import-module .\psvirustotal\VirusTotal.psm1

#Import SQLLite module
# 
#   https://github.com/RamblingCookieMonster/PSSQLite
Unblock-file .\PSSQLite-master\PSSQlite\PSSQLite.psm1
Unblock-file .\PSSQLite-master\PSSQlite\Invoke-SqliteBulkCopy.ps1
Unblock-file .\PSSQLite-master\PSSQlite\Invoke-SqliteQuery.ps1
Unblock-file .\PSSQLite-master\PSSQlite\New-SqliteConnection.ps1
Unblock-file .\PSSQLite-master\PSSQlite\Out-DataTable.ps1
Import-module .\PSSQLite-master\PSSQlite\PSSQLite.psm1
Install-module PSSQLite

#####################################################################################
###   Get network connections from Sysmon event log
#####################################################################################
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

#Display a gridview of detected IP Addresses
#$netarr | out-gridview

#Create a bunch of hashtables to store VT scan results
$iplist = @{}
$countrylist = @{}
$ASOwnerlist = @{}
$Resolutionlist = @{}
$DetectedURLlist = @{}
$DetectedDownloaded = @{}
$UndetectedURLlist = @{}
$WorthInvestigating = @{}

$scaninfo = @()
$offbyone = 1
foreach($ip in $netarr){
	$report = Get-VTReport -VTApiKey $apikey -ip $ip

	#sort the resolutions out by last_resolved date, so we can grab latest one
	$resolution = $report.resolutions | sort-object -property last_resolved -descending

	$iplist.Add($netarr.IndexOf($ip), $ip)
	$countrylist.Add($netarr.IndexOf($ip), $report.country)
	$ASOwnerlist.Add($netarr.IndexOf($ip), $report.as_owner)
	$Resolutionlist.Add($netarr.IndexOf($ip), $resolution[0])
	$DetectedURLlist.Add($netarr.IndexOf($ip), $report.detected_urls[0])
	$UndetectedURLlist.Add($netarr.IndexOf($ip), $report.undetected_urls[0])
	$DetectedDownloaded.Add($netarr.IndexOf($ip), $report.detected_downloaded_samples[0])

	if(!$report.detected_downloaded_samples[0] -and !$report.detected_urls[0]){
		$WorthInvestigating.Add($netarr.IndexOf($ip), "N")
	}
	if($DetectedDownloaded -or $DetectedURLlist){
		$WorthInvestigating.Add($netarr.IndexOf($ip), "Y")
	}

	$hash = New-Object PSObject -property @{Index=$netarr.IndexOf($ip);IP=$ip;Country=$countrylist[$netarr.IndexOf($ip)];ASOwner=$ASOwnerList[$netarr.IndexOf($ip)];Resolution=$ResolutionList[$netarr.IndexOf($ip)];DetectedURL=$DetectedURLlist[$netarr.IndexOf($ip)];UndetectedURLs=$UndetectedURLlist[$netarr.IndexOf($ip)];DetectedMalware=$DetectedDownloaded[$netarr.IndexOf($ip)];WorthInvestigating=$WorthInvestigating[$netarr.IndexOf($ip)]}
	$scaninfo += $hash

	if($offbyone % 4 -eq 0){
		#Display a grid view of all VT data
		$scaninfo | select-object Index,IP,Country,WorthInvestigating,ASOwner,DetectedMalware,Resolution,DetectedURL,UndetectedURLs | out-gridview

		sleep 60
	}

	$offbyone += 1
}

<#
(0..$netarr.length) | %{
	$reportip = $_ | out-string
	$report = Get-VTReport -VTApiKey $apikey -ip $reportip

	#sort the resolutions out by last_resolved date, so we can grab latest one
	$resolution = $report.resolutions | sort-object -property last_resolved -descending

	$iplist.Add($_, $netarr[$_])
	$countrylist.Add($_, $report.country)
	$ASOwnerlist.Add($_, $report.as_owner)
	$Resolutionlist.Add($_, $resolution[0])
	$DetectedURLlist.Add($_, $report.detected_urls[0])
	$UndetectedURLlist.Add($_, $report.undetected_urls[0])
	$DetectedDownloaded.Add($_, $report.detected_downloaded_samples[0])

	$hash = New-Object PSObject -property @{Index=$_;IP=$reportip;Country=$countrylist[$_];ASOwner=$ASOwnerList[$_];Resolution=$ResolutionList[$_];DetectedURL=$DetectedURLlist[$_];UndetectedURLs=$UndetectedURLlist[$_];DetectedMalware=$DetectedDownloaded[$_]}

	$scaninfo += $hash

	if(($_ % 4 -eq 0) -and ($_ -ne 0)){
		#Display a grid view of all VT data
		$scaninfo | select-object Index,IP,Country,ASOwner,DetectedMalware,Resolution,DetectedURL,UndetectedURLs | out-gridview

		sleep 59
	}

}

#########################################################
# Create a SQLite database to store VirusTotal information
#########################################################
$Query = "CREATE TABLE NAMES (fullname VARCHAR(20) PRIMARY KEY, surname TEXT, givenname TEXT, BirthDate DATETIME)"
$DataSource = "$pwd\VirusTotal.SQLite"

Invoke-SqliteQuery -Query $Query -DataSource $DataSource

#########################################################
# Use nested list/array
#########################################################

foreach($ip in $netarr){
	$report = Get-VTReport -VTApiKey $apikey -ip $ip
	$vtlist += ,@($netarr,$netarr.IndexOf($ip),$report.country,$report.as_owner,$report.resolutions,$report.detected_urls)
}


#########################################################
# Use multidimensional hashtable
#########################################################
foreach($ip in $netarr){
	$report = Get-VTReport -VTApiKey $apikey -ip $ip
	$vtarray[$netarr.IndexOf($ip)] = @{}
	$vtarray[$netarr.IndexOf($ip)]["IPAddress"] = $ip
	$vtarray[$netarr.IndexOf($ip)]["Country"] = $report.country
	$vtarray[$netarr.IndexOf($ip)]["ASOwner"] = $report.as_owner
	$vtarray[$netarr.IndexOf($ip)]["Resolutions"] = $report.resolutions
	$vtarray[$netarr.IndexOf($ip)]["DetectedURLs"] = $report.detected_urls
}

#$vtarray["IPAddress"] = @{}
#$vtarray["IPAddress"]["Country"] = @{}
#$vtarray["IPAddress"]["ASOwner"] = @{}
#$vtarray["IPAddress"]["Resolutions"] = @{}
#$vtarray["IPAddress"]["DetectedURLs"] = @{}
#$vtarray["IPAddress"]["DetectedCommunicatingSamples"] = @{}
#$vtarray["IPAddress"]["UnDetectedCommunicatingSamples"] = @{}
#$vtarray["IPAddress"]["DetectedDownloadedSamples"] = @{}
#$vtarray["IPAddress"]["UnDetectedDownloadedSamples"] = @{}
#$vtarray["IPAddress"]["ResponseCode"] = @{}
#$vtarray["IPAddress"]["VerboseMessage"] = @{}
#$vtarray["IPAddress"]["ASN"] = @{}

for($counter=0; $counter -lt $netarr.length; $counter++) {
	write-output "Scanning $netarr[$counter]"
	$report = Get-VTReport -VTApiKey $apikey -ip $netarr[$counter]

	write-output $report.country
	write-output $report.asowner
	write-output $report.resolutions
	write-output $report.detected_urls

	$vtarray[$counter] = @{}
	$vtarray[$counter]["IPAddress"] = $netarr[$counter]
	$vtarray[$counter]["Country"] = $report.country
	$vtarray[$counter]["ASOwner"] = $report.asowner
	$vtarray[$counter]["Resolutions"] = $report.resolutions
	$vtarray[$counter]["DetectedURLs"] = $report.detected_urls

	#$vtarray["Entry"][$counter]["IPAddress"] = $ipaddy
	#$vtarray["Entry"][$counter]["Country"] = $report.country
	#$vtarray["Entry"][$counter]["ASOwner"] = $report.as_owner
	#$vtarray["Entry"][$counter]["Resolutions"] = $report.resolutions
	#$vtarray["Entry"][$counter]["DetectedURLs"] = $report.detected_urls
	
	#$vtarray.Add('Country')

	$vtarray[$ipaddy] = $ipaddy
	$vtarray[$ipaddy]["Country"] = $report.country
	$vtarray[$ipaddy]["ASOwner"] = $report.as_owner
	$vtarray[$ipaddy]["Resolutions"] = $report.resolutions
	$vtarray[$ipaddy]["DetectedURLs"] = $report.detected_urls
	$vtarray[$ipaddy]["DetectedCommunicatingSamples"] = $report.detected_communicating_samples
	$vtarray[$ipaddy]["UndetectedCommunicatingSamples"] = $report.undetected_communicating_samples
	$vtarray[$ipaddy]["DetectedDownloadedSamples"] = $report.detected_downloading_samples
	$vtarray[$ipaddy]["UndetectedDownloadedSamples"] = $report.undetected_downloading_samples
	$vtarray[$ipaddy]["ResponseCode"] = $report.response_code
	$vtarray[$ipaddy]["VerboseMessage"] = $report.verbose_msg
	$vtarray[$ipaddy]["ASN"] = $report.asn

	#$lastresolved = $report.resolutions | sort-object -property last_resolved -descending
	#write-output "The last known hostname is $lastresolved[0].hostname"
	#write-output "This system is owned by $report.as_owner"

	#Come up with a mixture of conditions that should alert someone of suspicious activity
	#$detectioncheck = $report | sls -Pattern "positives=[2-9]{1,2}" -all | Select Matches | fl * | out-string

	#If detection rules match, notify user somehow
	#if($detectioncheck){
	#
	#}
}

$vtarray | out-gridview

VT API Columns:::
country
as_owner

resolutions
detected_urls
detected_downloaded_samples
undetected_downloaded_samples
detected_communicating_samples
undetected_communicating_samples
response_code
verbose_msg
asn


Testing network scan to grab anything that resolves over 5 times
-also need to think of other suspicious things like country=netherlands, or ..

#Run report on IP Address
$VTScan = Get-VTReport -VTApiKey $apikey -ip 8.8.8.8

#Change into a string for grepping
$VTScanString = $VTScan | out-string

#Look for all matches, to determine if it's worth warning about
$Scanmatches = $VTScanString | sls -Pattern "positives=[2-9]{1,2}" -all | Select Matches

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
#>
