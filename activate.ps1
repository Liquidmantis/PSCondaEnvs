$global:condaEnvName = $args[0]

# fix for pre-PS3
if (-not $PSScriptRoot) { 
    $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent 
}

$env:ANACONDA_ENVS = (get-item $PSScriptRoot).parent.FullName + '\envs'

if (-not $condaEnvName) {
    write-host
    write-host "Usage: activate envname"
    write-host
    write-host "Deactivates previously activated Conda environment, then activates the chosen one."
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
    write-host
    # This search/replace removes the previous env from the path
    write-host "Deactivating environment `"$env:CONDA_DEFAULT_ENV...`""
    $env:PATH = $env:ANACONDA_BASE_PATH
    remove-item env:\CONDA_DEFAULT_ENV
    $function:prompt = $function:condaUserPrompt
    remove-item function:\condaUserPrompt
}

$env:CONDA_DEFAULT_ENV = $condaEnvName
write-host
write-host "Activating environment `"$env:CONDA_DEFAULT_ENV...`""
$env:ANACONDA_BASE_PATH = $env:PATH
$env:PATH="$env:ANACONDA_ENVS\$env:CONDA_DEFAULT_ENV\;$env:ANACONDA_ENVS\$env:CONDA_DEFAULT_ENV\Scripts\;$env:ANACONDA_BASE_PATH"
write-host
write-host

function global:condaUserPrompt {''}
$function:condaUserPrompt = $function:prompt

function global:prompt {
    # Add a prefix to the current prompt, but don't discard it.
    write-host "[$condaEnvName] " -nonewline -ForegroundColor Red
    & $function:condaUserPrompt
}
