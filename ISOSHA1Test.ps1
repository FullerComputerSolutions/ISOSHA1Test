#Set-ExecutionPolicy Unrestricted
# Confirm Checksums

#Debugging
$DebugPreference = "Continue"

#Logging feature
$ErrorActionPreference="SilentlyContinue"
Stop-Transcript | out-null
$ErrorActionPreference = "Continue"
#current script directory
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
#current script name
$path = Get-Location
$scriptName = $MyInvocation.MyCommand.Name
$scriptLog = "$scriptPath\scriptlogs\$scriptName.log"
#start a transcript file
Start-Transcript -path $scriptLog
####### Main Code #########
Get-ChildItem $scriptPath -Filter *.iso | Out-GridView -Title 'Choose a file to check' -PassThru | % { 
If (Test-Path $scriptPath$_.sha1) {
	Write-Host "Calculating and comparing..."
	$CalcHash = (Get-FileHash $_ -Algorithm SHA1).hash
	$ExpectedHash = Get-Content $scriptPath$_.sha1
	if($CalcHash -ne $ExpectedHash){
		Write-Host -BackgroundColor red -ForegroundColor black "Mismatch SHA1"
		Write-Host -BackgroundColor green -ForegroundColor white "Expected: " $ExpectedHash
		Write-Host -BackgroundColor red -ForegroundColor black "Actual: " $CalcHash
		} Else {
		Write-Host -BackgroundColor green -ForegroundColor white "Match!"
		Write-Host -BackgroundColor green -ForegroundColor white "Expected: " $ExpectedHash
		Write-Host -BackgroundColor green -ForegroundColor white "Actual: " $CalcHash
		}
}

Else {
	Write-Host "Generating Hash..."
	(Get-FileHash $_ -Algorithm SHA1).hash | Out-File -filepath "$scriptPath$_.sha1"
}
}

########Always place these EOF########
#Close all open sessions
#Remove-PSSession $Session
Get-PSSession | Remove-PSSession
#Close Transcript log
Stop-Transcript