$svcName = "Genapi.NotaPlusToCNKAudit"
$services = Get-WmiObject win32_service | Where-Object { $_.PathName -like "*$svcName*" -and $_.StartName -like "*LocalService" }

foreach ($svc in $services) 
{
Write-Output "---------------------------------------"
Write-Output "Name=$($svc.Name)"
Write-Output "DisplayName=$($svc.DisplayName)"
Write-Output "State=$($svc.State)"
Write-Output "PathName=$($svc.PathName)"
Write-Output "StartName=$($svc.StartName)"

Stop-Service -Name $svc.Name
$tempSvc = Get-Service -Name $svc.Name
if ($tempSvc.Status -ne "Stopped") 
{
	Write-host "Could not stop service $($svc.Name)" -f Red
}
else 
{
	Write-host "Successfully stopped service $($svc.Name)" -f Green
}

$changeLogonAccountStatus = $svc.Change($null,$null,$null,$null,$null,$null,"LocalSystem","",$null,$null,$null)
if ($changeLogonAccountStatus.ReturnValue -eq "0")  
{
    Write-host "The logon account changed successfully for the $($svc.Name) service." -f Green
}
else 
{
    Write-host "Failed to change the logon account for the $($svc.Name) service. Error code: $($changeLogonAccountStatus.ReturnValue)" -f Red
}

Start-Service -Name $svc.Name
$tempSvc = Get-Service -Name $svc.Name
if ($tempSvc.Status -eq "Running") 
{
	Write-host "Service $($svc.Name) Restarted" -f Green
}
else 
{
	Write-host "Cannot restart $($svc.Name)" -f Red
}
}

if (($services | Measure-Object).Count -le 0) 
{
	Write-host "Couldn't find any Genapi.NotaPlusToCNKAudit services with StartName like *LocalService" -f Red
}
