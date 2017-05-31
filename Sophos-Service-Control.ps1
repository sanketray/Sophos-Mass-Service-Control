# # Sophos infrastructure service control and status script
# sophos-service-control.ps1
#
# remotely restarts sophos services in vendor-recommended order for SUM or EC
#
# usage: SUM = Sophos UPdate Manager EC = Enterprise Console EPT = Endpoint client hammerofthor = restart all Sophos SUM servers t the 
#        sophos-service-control.ps1 -servername <servername> [-servertype (SUM|EC|EPT)] [-action (restart|status|hammerofthor)] [-force (true|false)] [-verbose]
#
#
# Status:
#    IAC: appears to work on 2003 and 2008 sums
#
#Important to-dos:
# - logging of what was done
#
# Eventual to-dos
# query a list of sums out of the database and use the hammer of thor


[CmdletBinding()]
param (     [Parameter(Mandatory=$true)][string]$ServerName,
            [string]$servertype="SUM",
            [string]$action="status",
            [switch]$force=$false
    )

# define service name array for each role
$SUMServiceNames = @()
$SUMServiceNames +=  "Sophos Message Router"
$SUMServiceNames +=  "Sophos Agent"
$SUMServiceNames +=  "SAVAdminService"
$SUMServiceNames +=  "SUM"

$ECServiceNames = @()
$ECServiceNames +=  "Sophos Message Router"
$ECServiceNames +=  "Sophos Certification Manager"
$ECServiceNames +=  "Sophos Agent"
$ECServiceNames +=  "SAVAdminService"
$ECServiceNames +=  "SUM"
$ECServiceNames +=	"Sophos Management Service"

$EPTServiceNames = @()
$EPTServiceNames += "Sophos Message Router"
$EPTServiceNames += "SAVService"
$EPTServiceNames += "Sophos Agent"
$EPTServiceNames += "SAVAdminService"
$EPTServiceNames += "Sophos Autoupdate Service"

[boolean]$stoppedServiceFound = $false
#functions 

function getRemoteServiceArray {
    param ( [string]$remoteComputerName,$type)
    Write-Verbose "computer: $remotecomputername; type: $type"
    switch ($type) {
        EC { $svcList = $ECServiceNames }
        SUM { $svcList = $SUMServiceNames }
        EPT { $svcList = $EPTServiceNames }
        default { $svcList = $SUMServiceNames }
    }
    $svcOutputArray = @()
        foreach ($svc in $svcList) {
            write-verbose "getting object for $svc"
            $svctemp = get-service -ComputerName $remoteComputerName $svc
            if ([string]$($svctemp.Status) -eq "Stopped") {$stoppedServiceFound =$true}
            $svcOutputArray += $svctemp
            }
        $svcOutputArray
}

function restartRemoteServices {
    param ( [array]$servicesToRestart
    )

    foreach ($thisService in $servicesToRestart) {
    #need: error trapping
    stop-service -inputobject $thisService
    Start-Service -InputObject $thisService
    }
}


# main
$serviceArray = getRemoteServiceArray -remotecomputername $ServerName -type $servertype
write-verbose "Stopped service found = $stoppedServiceFound"
#restart if asked to
if ($action -match "restart") {
     if (($stoppedServiceFound -eq $false -or $force -eq $true) ) {
        write-verbose "restarting $servertype services on $servername"
        restartRemoteServices($serviceArray)
    }
}

# provide status
#$serviceArray | get-service 
$serviceArray


