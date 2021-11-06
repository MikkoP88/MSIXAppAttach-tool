# Tool for automatize MSIX App attach deployment workflow
This tool automatize MSIX app attach VHDX file creation and also creating attach and detach scripts for MSIX app attach deployment.

What this tool do:
```
1. Tool creating VHDX disk 
2. Unpack MSIX packet on VHDX.
3. Detach created VHDX disk.
4. Creating powershell script file for attach VHDX and MSIX app attach.
5. Creating powershell script file for detach VHDX and MSIX app attach.
```
## Getting Started
Tools is tested and verified working with Windows 10 20H1 build on-premises environment, but can work with cloud enviroment and any Windows 10 build 1809 or later.

### Requiment
- Application packet on .msix format, more info [MSIX Packaging Tool](https://docs.microsoft.com/en-us/windows/msix/packaging-tool/tool-overview)
- If Application MSIX Packet size is over 20GB then you need at least 20GB system memory, else unpacking MSIX Packet fail. 
- Download the [msixmgr tool](https://aka.ms/msixmgr) and extract the .zip on local computer or share folder.
- Download MSIX_App_Container_Creator_1.0.ps1 file.
- Administrator privileges on your PC to run this tool.

## Setting up
 Before running tool some parameters need to be edited on the MSIX_App_Container_Creator_1.0.ps1 file.

### Folders locations parameter

Source folder of MSIX application packet.
```
$msixPath = "MSIX application Packet Folder"
```
Destination folder where MSIX App Attach VHDX file will be created.
```
$vhdSrcFolder = "VHDX Destination Folder"
```
Folder where is MSIXMGR tool.
```
$msixmgrPath = "MSIXMGR tool Folder"
```
Destination folder where tool creating powershell Sripts for Attach and Detach App Attach container.
```
$scriptLocation = "Attach/Detach scipts destination folder"
```
### Optionally parameters

Parent folder name on VHDX.
```
$parentFolder = "MSIX"
```
Attach and Detach script MSIX Junction. This affect only attach/detach MSIX App Attach scipts.
```
$msixJunction = "C:\temp\AppAttach\"
```
### Example of parametters
On this example is used shared folder locations, so tool work with local and shared folders. Optionally parametters can be leaved with default values.
```
#Folders locations parameter
$msixPath = "\\Fileserver\MSIX-Packets"
$vhdSrcFolder = "\\Fileserver\MSIX-VHDX"
$msixmgrPath = "\\Fileserver\MSIX-Tool"
$scriptLocation = "\\Fileserver\MSIX-Deploment-Scipts"

#Optionally parameters
$parentFolder = "MSIX"
$msixJunction = "C:\temp\AppAttach\"
```
## Usage
Open powershell and go folder where you put MSIX_App_Container_Creator_1.0.ps1 file.
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
### Deploy multiple MSIX Packets single Poweshell run
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
