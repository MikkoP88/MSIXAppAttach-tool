﻿param($packageName, $vhdSize, $overrideVolumeName)

#Editable Parametters

#MSIX Source Packet Location
$msixPath = "Source MSIX Packet Folder"
#MSIX App Attach VHDX Destination
$vhdSrcFolder = "VHDX Destination Folder"
#Parent Folder on VHDX
$parentFolder = "MSIX"
#MSIXMGR tool location
$msixmgrPath = "MSIXMGR tool Folder"
#Location where save powershell Sripts to Attach Detach App Attach container
$scriptLocation = "Location where you want to save attach and detach powershell script files"
#Attach and Detach script MSIX Junction
$msixJunction = "C:\temp\AppAttach\"


#Static parameters
$parts = $packageName.split("_")
$appName = $parts[0] + "_" + $parts[1]
$vhdSrc = $vhdSrcFolder + "\" + $appName + ".vhdx"
$parentFolder = "\" + $parentFolder + "\"
$volumeName = "MSIX-" + $parts[0]
$packagePath = $msixPath + "\" + $packageName + ".msix"

#Generate a VHD or VHDX package for MSIX
New-VHD -SizeBytes $vhdSize -Path $vhdSrc -Dynamic -confirm:$false
$vhdObject = Mount-VHD $vhdSrc -PassThru
$disk = Initialize-Disk -PassThru -Number $vhdObject.Number
$partition = New-Partition -AssignDriveLetter -UseMaximumSize -DiskNumber $disk.Number
Format-Volume -FileSystem NTFS -confirm:$false -DriveLetter $partition.DriveLetter -Force
$Path = $partition.DriveLetter + ":" + $parentFolder

#Create a folder with Package Parent Folder
New-Item -Path $Path -ItemType Directory

#Partition and Volume Name
if (-not ($overrideVolumeName -eq $null)) {
  $volumeName = "MSIX-" + $overrideVolumeName
}
else {

  if ($volumeName.length -gt 32) {
    Write-Host "Volume name is too long. Give new volume name. MAX length 27 letters"
    $volumeName = Read-Host -Prompt 'New Volume Name'
  }
}
Set-Volume -DriveLetter $partition.DriveLetter -NewFileSystemLabel $volumeName

#Unpack MSIX on VHD/VHDX
Set-Location $msixmgrPath
Write-Host ("Unpacking MSIX to VHD/VHDX Disk") -BackgroundColor Green
.\msixmgr.exe -Unpack -packagePath $packagePath -Destination $Path -applyacls

#Get VHD/VHDX GUID ID 
$volumeDeviceID = ((Get-WmiObject win32_volume | Where-Object { $_.DriveLetter -eq $partition.DriveLetter + ":" }).DeviceId)
$volumeGuid = ($volumeDeviceID.split("{")).split("}")[1]

Dismount-VHD -Path $vhdSrc

#Creating passing parametters for Scripts
$vhdSrcPass = '$vhdSrc = "'
$vhdSrcPass += $vhdSrc
$vhdSrcPass += '"'

$packageNamePass = '$packageName = "'
$packageNamePass += $packageName
$packageNamePass += '"'

$parentFolderPass = '$parentFolder = "'
$parentFolderPass += $parentFolder
$parentFolderPass += '"'

$volumeGuidPass = '$volumeGuid = "'
$volumeGuidPass += $volumeGuid
$volumeGuidPass += '"'

$parentFolderPass = '$parentFolder = "'
$parentFolderPass += $parentFolder
$parentFolderPass += '"'

$msixJunctionPass = '$msixJunction = "'
$msixJunctionPass += $msixJunction
$msixJunctionPass += '"'


#Creating Attach Script
#Attach Passing parametter on script
$attachAppScript = "
$vhdSrcPass
$packageNamePass
"

$attachAppScript += @'

#Mountvhd
'@
#Creating Attach Script END

#Export Attach Script File
$attachExportParam = $scriptLocation + "\" + "Attach-" + $appName + ".ps1"
$attachAppScript | Out-File $attachExportParam


#Creating Detach Script 
#Attach Passing parametter on script
$detachAppScript = "
$packageNamePass

$detachAppScript += @'



'@
#Creating Detach Script END

#Export Detach Script File
$detachExportParam = $scriptLocation + "\" + "Detach-" + $appName + ".ps1"
$detachAppScript | Out-File $detachExportParam
