# Welcome Banner
Write-Host "ELK EVTX UPLOAD SCRIPT | v1.0"
Write-Host "[!] If multiple systems, please ensure all logs are local and grouped by system within nested folders." "`n"

# Backend Maintenance
# Check to see if Winlogbeat Registry File from prior uploads exists
$regFile = Test-Path $pwd\winlogbeat\data\evtx-registry.yml
# If it does exists, remove Winlogbeat Registry File
if($regFile -eq $true){Remove-Item -Path $pwd\winlogbeat\data\evtx-registry.yml -Force}

# Get current date for logging
$date = Get-Date -UFormat "%m-%d"


# Ask for path containing desired logs
Do {
    Write-Host "Enter target directory path containing EVTX logs or folders grouping them by system (i.e. C:\Users\Asus VivoBook S\Documents\LIYIN\Deloitte\logs)."
    $tempPath = Read-Host "Path"
    # Check to see if input path exists
    $checkPath = Test-Path $tempPath
    if($checkPath -eq $false){Write-Host "[!] Directory Path not found. Please check your input and try again." "`n"}
}
Until ($checkPath -eq $true)
Write-Host ""

# Adjust target directory path to have proper syntax for Winlogbeat, if needed
$userPath = $tempPath -replace '/','\'

# Check for nested folders
Write-Host "Do you have nested folders labeled by system within this directory? (Default is NO)"
    $nested = Read-Host "(y/n)" 
    Switch ($nested){ 
        Y {Write-Host ""} 
        N {Write-Host ""} 
        Default {
            Write-Host ""
            Write-Host "[*] Defaulting to no nested folders..." "`n"
        }
} 

# Perform directory check if nested folders exist
if($nested -eq "y"){
    Do {
        # Filter for all folders
        $folders = Get-ChildItem -Path $userPath -Directory

        # Verify Info
        Write-Host "The following folders (systems) were detected:"
        Write-Host ""
        Write-Host $folders
        Write-Host ""
        Write-Host "Is this the data you wish to upload? (Default is NO)"
            $answer = Read-Host "(y/n)" 
            Switch ($answer){ 
                Y {Write-Host ""} 
                N {Write-Host ""} 
                Default {
                    Write-Host ""
                    Write-Host "[*] Defaulting to NO..." "`n"
                } 
            } 
    }
    Until ($answer -eq "y")
}

# Ask for Client Name
$tempClient = Read-Host "Enter Index Name (i.e. my-index)"
# Replace Spaces, if any, in name for ELK Index Name
$client = $tempClient -replace '\s','_'
# Convert to Lowercase for ELK Index Name
$elkClient = $client.ToLower()

# Ask for Case Number
# $case = Read-Host "Enter Case # (i.e. 20-0101)"

if($nested -eq "n"){
    # Ask for Identifier for easier searching in Kibana
    Write-Host ""
    Write-Host "Enter a searchable identifier or note for this evidence upload (i.e. evidence2)"
    $ID = Read-Host "Identifier"
}

# Informative Message regarding Index Creation
Write-Host ""
Write-Host "ELK Index: $case-$elkClient-evtx"
Write-Host "[!] If new client, don't forget to add this index for viewing under 'Index Patterns' within Kibana settings." "`n"
Write-Host "[*] Logs for this upload can be found in 'elk-logging' within the root 'ELK-Tools' folder." "`n"

# Nested Folders Code
if($nested -eq "y"){
    # Filter for all folders
    $folders = Get-ChildItem -Path $userPath -Directory
    # Create for loop to cycle through all folders
    foreach($folder in $folders){
        # Define loop vars
        $i = 1
	    $ID = $folder
	    $foldersPath = $userPath + "\" + $folder
        # Filter for just the .evtx files within selected folder
	    $dirs = Get-ChildItem -Path $foldersPath -filter *.evtx
        $dirsCount = $dirs.Count
	    # Create for loop to grab all .evtx files within selected folder
	    foreach($file in $dirs){
            # Add shiny progress bar
            $percentComplete = ($i / $dirsCount) * 100
            Write-Progress -Activity "$i of $dirsCount EVTX files found within $foldersPath sent to ELK" -Status "Uploading $file..." -PercentComplete $percentComplete
		    $filePath = $foldersPath + "\" + $file
            # Execute Winlogbeat w/custom vars
		    .\winlogbeat\winlogbeat.exe -e -c .\winlogbeat\winlogbeat-events.yml -E EVTX_FILE="$filePath" -E CLIENT="$rsmClient" -E CLIENT="$elkClient" -E CASE="$case" -E ID="$ID" -E FILE="$file" 2>&1 >> $pwd\elk-logging\winlogbeat_log_${date}.txt
		    Sleep 3
            $i++
	    }
    }
}

# Single Folder Code
if($nested -eq "n"){
    $i = 1
    # Filter by EVTX extension
    $dirs = Get-ChildItem -Path $userPath -filter *.evtx
    $dirsCount = $dirs.Count
	# Create for loop to grab all .evtx files within selected folder
	foreach($file in $dirs){
        # Add shiny progress bar
        $percentComplete = ($i / $dirsCount) * 100
        Write-Progress -Activity "$i of $dirsCount EVTX files found within $userPath sent to ELK" -Status "Uploading $file..." -PercentComplete $percentComplete
		$filePath = $userPath + "\" + $file
        # Execute Winlogbeat w/custom vars
		.\winlogbeat\winlogbeat.exe -e -c .\winlogbeat\winlogbeat-events.yml -E EVTX_FILE="$filePath" -E CLIENT="$client" -E ELK_CLIENT="$elkClient" -E CASE="$case" -E ID="$ID" -E FILE="$file" 2>&1 >> $pwd\elk-logging\winlogbeat_log_${date}.txt
		Sleep 3
        $i++
	}
}

# Show message confirming successful upload
Write-Host "[*] EVTX Upload completed. Use the 'Discover' tab in Kibana to view."