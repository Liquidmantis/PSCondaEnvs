Param(
    [string]$global:condaEnvName,
    [switch]$updateRegistry
)

# Get location of Anaconda installation
$global:anacondaInstallPath = (get-item $PSScriptRoot).parent.FullName

# Build ENVS path
$env:ANACONDA_ENVS = $anacondaInstallPath + '\envs'

Function Set-Installpath {
    # Updates Python installpath to be the Anaconda root location
    Try {
        write-host "Setting Python Installpath to $env:ANACONDA_ENVS..."
        Set-ItemProperty -Path hklm:\Software\python\pythoncore\2.7\installpath -Name "(default)" -Value "$env:ANACONDA_ENVS" -ErrorAction Stop
    }
    Catch {
        write-warning "Unable to update Python path in registry.  Need to run as admin."
    }
}

if (-not $condaEnvName) {
    write-host
    write-host "Usage: activate envname [-UpdateRegistry]"
    write-host
    write-host "Deactivates previously activated Conda environment, then activates the chosen one."
    write-host "Use -UpdateRegistry to set Python installpath to the activated virtualenv.  Useful"
    write-host "for installing modules compiled into Windows installers."
    write-host
    write-host
    exit
}

if (-not (test-path $env:ANACONDA_ENVS\$condaEnvName\Python.exe)) {
    write-host
    write-warning "No environment named `"$condaEnvName`" exists in $env:ANACONDA_ENVS."
    write-host
    write-host
    exit 
}

# Deactivate a previous activation if it is live
if (test-path env:\CONDA_DEFAULT_ENV) {
    invoke-expression deactivate.ps1
}

$env:CONDA_DEFAULT_ENV = $condaEnvName
write-host
write-host "Activating environment `"$env:CONDA_DEFAULT_ENV...`""
$env:ANACONDA_BASE_PATH = $env:PATH
$env:PATH="$env:ANACONDA_ENVS\$env:CONDA_DEFAULT_ENV\;$env:ANACONDA_ENVS\$env:CONDA_DEFAULT_ENV\Scripts\;$env:ANACONDA_BASE_PATH"

if ($updateRegistry) {Set-Installpath}
    
write-host
write-host

function global:condaUserPrompt {''}
$function:condaUserPrompt = $function:prompt

function global:prompt {
    # Add a prefix to the current prompt, but don't discard it.
    write-host "[$condaEnvName] " -nonewline -ForegroundColor Red
    & $function:condaUserPrompt
}