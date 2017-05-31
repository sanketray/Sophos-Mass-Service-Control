$File = Get-Content "C:\Users\TEMP.BAREESC.009\Documents\Server-List.csv"
Foreach ($Endpoint in $File)
{C:\Tools\Sophos\Sophos-Service-Control.ps1 -Action Restart -ServerType EPT -ServerName $Endpoint}
