$global:condaEnvName = $args[0]

$env:ANACONDA_ENVS = (get-item $PSScriptRoot).parent.FullName + '\envs'

if (-not (test-path env:\CONDA_DEFAULT_ENV)) {
    write-host
    write-host "No active Conda environment detected."
    write-host
    write-host "Usage: deactivate"
    write-host "Deactivates previously activated Conda environment."
    write-host
    exit
}

# Deactivate a previous activation if it is live
if (test-path env:\CONDA_DEFAULT_ENV) {
    # This search/replace removes the previous env from the path
    write-host
    write-host "Deactivating environment `"$env:CONDA_DEFAULT_ENV...`""
    $env:PATH = $env:ANACONDA_BASE_PATH
    remove-item env:\CONDA_DEFAULT_ENV
    $function:prompt = $function:condaUserPrompt
    remove-item function:\condaUserPrompt
    write-host
    write-host
}