# Tool for automatize MSIX App attach deployment workflow
This tool automatize MSIX Packet converting to MSIX app attach VHDX file with all needed attach and detach scipts. 

What this tool do:
```
1. Tool creating VHDX file and unpack MSIX packet on VHDX.
2. Detach created VHDX file.
3. Creating powershell script file for attach VHDX with MSIX app attach.
4. Creating powershell script file for detach VHDX and MSIX app attach packet.
```
## Getting Started
Download MSIX_App_Container_Creator_1.0.ps1 file and edit folders location parameters:
### Folders location parameters:
*Locations can be on shared folder.*

MSIX Source Packet Location.
```
$msixPath = "Source MSIX Packet Folder"
```
MSIX App Attach VHDX Destination.
```
$vhdSrcFolder = "VHDX Destination Folder"
```
MSIXMGR tool location.
```
$msixmgrPath = "MSIXMGR tool Folder"
```
Location where save powershell Sripts to Attach Detach App Attach container.
```
$scriptLocation = "Location where you want to save attach and detach powershell script files"
```
### Default optionally parameters:
Parent Folder on VHDX.
```
$parentFolder = "MSIX"
```
Attach and Detach script MSIX Junction. This only for attach and detach scipts.
```
$msixJunction = "C:\temp\AppAttach\"
```
## Usage
Download MSIX_App_Container_Creator_1.0.ps1 file and edit needed parameter.

### Open powershell and go folder where you put MSIX_App_Container_Creator_1.0.ps1 file.
```
cd "MSIX_App_Container_Creator_1.0.ps1 folder location"
```
### Run tool with basic parameters. 
Use on -vhdsize parametter with MB example 500MB. 
```
.\MSIX_App_Container_Creator_1.0.ps1 -packageName <Package> -vhdsize <SizeMB>
```
### Run tool with optional volume name parameters. 
Use -overrideVolumeName when package name before x64 part go over 27 Letters. 

*Example: [WinRAR_1.0.0.0_x64__5q4ajw4wvsctp.msix] letters to count [WinRAR_1.0.0.0]*

```
.\MSIX_App_Container_Creator_1.0.ps1 -packageName <Package> -vhdsize <SizeMB> -overrideVolumeName <Volume Name>
```
## Deploy multiple MSIX Packets single Poweshell run
Because tool automize MSIX app Attach creation process, can be run multiple creation on single powershell console.
```
cd "MSIX_App_Container_Creator_1.0.ps1 folder location"
.\MSIX_App_Container_Creator_1.0.ps1 -packageName Packaget1 -vhdsize 500MB

cd "MSIX_App_Container_Creator_1.0.ps1 folder location"
.\MSIX_App_Container_Creator_1.0.ps1 -packageName Packaget2 -vhdsize 500MB
```
*You have to use <cd "MSIX_App_Container_Creator_1.0.ps1 folder location"> to prevent poweshell console jumping to wrong folder.*
## Output
Example of files what tool creating and naming scheme
```
MSIX packet name: 
PuTTY_1.0.0.0_x64__5q4ajw4wvsctp

Output:
PuTTY_1.0.0.0.vhdx
Attach-PuTTY_1.0.0.0.ps1
Detach-PuTTY_1.0.0.0.ps1
```
