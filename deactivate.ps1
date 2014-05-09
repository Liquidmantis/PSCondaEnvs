Param(
    [string]$condaEnvName,
    [switch]$updateRegistry
)

$installPath = 
# Get location of Anaconda installation
$anacondaInstallPath = (get-item $PSScriptRoot).parent.FullName

# Build ENVS path
$env:ANACONDA_ENVS = $anacondaInstallPath + '\envs'

Function Set-Installpath {
    # Updates Python installpath to be the Anaconda root location
    Try {
        write-host "Setting Python Installpath back to default location..."
        Set-ItemProperty -Path hklm:\Software\python\pythoncore\2.7\installpath -Name "(default)" -Value "$anacondaInstallPath" -ErrorAction Stop
    }
    Catch {
        write-warning "Unable to update Python path in registry.  Need to run as admin."
    }
}

Function Test-Installpath {
    # Checks that installpath doesn't point to an old virtualenv.
    $regCheck = (Get-ItemProperty -path hklm:\Software\python\pythoncore\2.7\installpath -Name "(default)")."(default)"
    if ($regCheck -ne $anacondaInstallPath) {
        write-warning "Python installpath Registry key points to $regCheck`nand likely should be updated to $anacondaInstallPath.`nRecommend running Deactivate with -UpdateRegistry switch."
    }
}

if (-not (test-path env:\CONDA_DEFAULT_ENV)) {
    
    write-host
    
    if ($updateRegistry) {
        Set-Installpath}
    else {
        write-host "No active Conda environment detected."
        write-host
        write-host "Usage: deactivate"
        write-host "Deactivates previously activated Conda environment."
        write-host "Use -UpdateRegistry to reset the Python installpath key."
        write-host
        
        Test-Installpath
    }
    
    write-host
    exit
}

# Deactivate a previous activation if it is live
if (test-path env:\CONDA_DEFAULT_ENV) {
    
    write-host
    write-host "Deactivating environment `"$env:CONDA_DEFAULT_ENV...`""

    # This removes the previous env from the path and restores the original path
    $env:PATH = $env:ANACONDA_BASE_PATH
    if ($updateRegistry) {Set-Installpath}
    
    # Restore original prompt
    $function:prompt = $function:condaUserPrompt
    
    # Clean up 
    remove-item env:\CONDA_DEFAULT_ENV
    remove-item function:\condaUserPrompt
    
    Test-Installpath

    write-host
    write-host
}