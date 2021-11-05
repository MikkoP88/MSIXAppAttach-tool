param($packageName, $vhdSize, $overrideVolumeName)

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
$packageNamePass$parentFolderPass$volumeGuidPass$msixJunctionPass
"

$attachAppScript += @'

#Mountvhdtry {    Mount-Diskimage -ImagePath $vhdSrc -NoDriveLetter -Access ReadOnly                     Write-Host ("Mounting of " + $vhdSrc + " was completed!") -BackgroundColor Green }catch{    Write-Host ("Mounting of " + $vhdSrc + " has failed!") -BackgroundColor Red}#Makelink$msixDest = "\\?\Volume{" + $volumeGuid + "}\"if (!(Test-Path $msixJunction)) {    md $msixJunction}$msixJunction = $msixJunction + $packageNamecmd.exe /c mklink /j $msixJunction $msixDest#region stage[Windows.Management.Deployment.PackageManager,Windows.Management.Deployment,ContentType=WindowsRuntime] | Out-NullAdd-Type -AssemblyName System.Runtime.WindowsRuntime$asTask = ([System.WindowsRuntimeSystemExtensions].GetMethods() | Where { $_.ToString() -eq 'System.Threading.Tasks.Task`1[TResult] AsTask[TResult,TProgress](Windows.Foundation.IAsyncOperationWithProgress`2[TResult,TProgress])'})[0]$asTaskAsyncOperation = $asTask.MakeGenericMethod([Windows.Management.Deployment.DeploymentResult], [Windows.Management.Deployment.DeploymentProgress])$packageManager = [Windows.Management.Deployment.PackageManager]::new()    $path = $msixJunction + $parentFolder + $packageName # needed if we do the pbisigned.vhd$path = ([System.Uri]$path).AbsoluteUri  $asyncOperation = $packageManager.StagePackageAsync($path, $null, "StageInPlace")                                                                                                                    $task = $asTaskAsyncOperation.Invoke($null, @($asyncOperation))        $task#endregion#Registers the application of the mounted container in the user context$path = "C:\Program Files\WindowsApps\" + $packageName + "\AppxManifest.xml"Add-AppxPackage -Path $path -DisableDevelopmentMode -Register 
'@
#Creating Attach Script END

#Export Attach Script File
$attachExportParam = $scriptLocation + "\" + "Attach-" + $appName + ".ps1"
$attachAppScript | Out-File $attachExportParam


#Creating Detach Script 
#Attach Passing parametter on script
$detachAppScript = "$vhdSrcPass
$packageNamePass$msixJunctionPass"

$detachAppScript += @'#Deregisters the application of the mounted container in the user contextRemove-AppxPackage -PreserveRoamableApplicationData $packageName 

#DerregisterRemove-AppxPackage -AllUsers -Package $packageNamecd $msixJunction rmdir $packageName -Recurse -Force -Confirm:$false#Dismount VHDdisMount-Diskimage -ImagePath $vhdSrc

'@
#Creating Detach Script END

#Export Detach Script File
$detachExportParam = $scriptLocation + "\" + "Detach-" + $appName + ".ps1"
$detachAppScript | Out-File $detachExportParam

