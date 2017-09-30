#Load Chrome extension
#& "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
#$extpath = "$(pwd)\IPINT-master"
#write-host $extpath
#& "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe" --load-extension="$extpath"

#Force Chrome to crash so we can load IPINT
TASKKILL /IM chrome.exe /F

#Check folder structure for evidence of 32-bit binary
$32bit = test-path "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"

if($32bit -eq "True") {
	& "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe" --load-extension="$(pwd)\IPINT-master"
	return
}

& "C:\Program Files\Google\Chrome\Application\chrome.exe" --load-extension="$(pwd)\IPINT-master"