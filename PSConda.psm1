<################################################################################
	PSConda

	adapted from PSCondaScripts, (https://github.com/Liquidmantis/PSCondaEnvs)

    publishes two PS functions

        activate <conda-envname>
        deactivate

    these functions take precendence over .bat files provided in conda with same name

    uses three globals

        $env:CONDA_CURRENT_ENV   this is the name of the current conda env
        $env:CONDA_BASE_PATH     this is the $env:path before activating env
        $function:global:CONDA_BASE_PROMT 
            this is the function:prompt prior to activation

    use as a module and import as part of powershell_profile or similar

        Import-Module -Global <abs path to module>\PSConda.psm1

    can use as script file, see PSConda.ps1 as example, the same except 
    for Export-ModuleMember statements so just maintaining PSConda.psm1

##################################################################################>

function activate() {

    param(
        [string][Parameter(Position=0, Mandatory=$True)] $target_envname
    )
     # get target env name as first arg to activate func
    
    # assumes that path_anaconda3 is set, this is done in powershell_profile or similar
    # this is the primary dependency cost of taking script out of conda installation
    $anacondaInstallPath = $path_anaconda_3

    # build anaconda env path
    $anaconda_envs = $anacondaInstallPath + '\envs'

    # build abs path to new env
    $anaconda_target_env_path = $anaconda_envs + "\$target_envname"

    # test if target_envname is a valid env
    if (-not (test-path  $anaconda_target_env_path\Python.exe)) {
    write-host
    write-warning "No environment named $target_envname exists in $anaconda_envs"
    write-host
    write-host
    return "ERROR: activate"
    }

    # Deactivate a previous activation if there is one
    if (test-path env:CONDA_CURRENT_ENV) {
        # invoke-expression deactivate
        # ps-deactivate
        println 'deactivate called'
    }

    $env:CONDA_CURRENT_ENV = $target_envname
    write-host
    write-host "Activating environment $env:CONDA_CURRENT_ENV ..."
    write-host "CONDA_CURRENT_ENV: $env:CONDA_CURRENT_ENV"
    $env:CONDA_BASE_PATH = $env:PATH
    $env:PATH="$anaconda_target_env_path;$anaconda_target_env_path\Scripts\;$env:CONDA_BASE_PATH"
   
    write-host
    write-host

    # save the current prompt as condaUserPrompt
    # append global: to make sure they are in global scope
    function global:CONDA_BASE_PROMPT {''}
    $function:global:CONDA_BASE_PROMPT = $function:global:prompt

    # create new prompt function which writes env name first then appends old prompt
    function global:prompt {
        # Add a prefix to the current prompt, but don't discard it.
        write-host "[$env:CONDA_CURRENT_ENV] " -nonewline -ForegroundColor Red
        & $function:CONDA_BASE_PROMPT
    }

}

function deactivate() {

    # deactivates a conda environment on Windows using PS

    write-host
    write-host "Deactivating environment $CONDA_CURRENT_ENV ..."


    # test if a conda env is active
    # assumes CONDA_CURRENT_ENV contains name of env if active

    # Deactivate a previous activation if it exists
    # This just means checking the three CONDA env variables and removing

    if (test-path env:CONDA_CURRENT_ENV) {
        # exists so remove it
        write-host "  remove-item CONDA_CURRENT_ENV: $env:CONDA_CURRENT_ENV"
        Remove-Item env:CONDA_CURRENT_ENV
    } else {
        # doesn't exist, called in error
        write-host "ERROR: CONDA_CURRENT_ENV does not contain a value"
        Write-host "continuing to check CONDA_BASE_PATH and CONDA_BASE_PROMPT"
    }

    if (test-path env:CONDA_BASE_PATH) {
        # exists so roll back
        write-host "  roll back PATH, remove-item CONDA_BASE_PATH"
        $env:path = $env:CONDA_BASE_PATH
        Remove-Item Env:CONDA_BASE_PATH
    } else {
        # doesn't exist, called in error
        write-host "ERROR: CONDA_BASE_PATH does not contain a value"
        Write-host "continuing to check CONDA_BASE_PROMPT"
    }

    if (test-path function:global:CONDA_BASE_PROMPT) {
        # exists so roll back
        write-host "  roll back PROMPT, remove-item CONDA_BASE_PROMPT"
        $function:global:prompt = $function:global:CONDA_BASE_PROMPT
        Remove-Item function:global:CONDA_BASE_PROMPT
    } else {
        # doesn't exist, called in error
        write-host "ERROR: CONDA_BASE_PROMPT does not contain a value"
    }

    write-host
    write-host
}


# this is a module not a script (.psm1 not .ps1) so must export any functions you 
# want to be visible in the PS env
Export-ModuleMember -Function activate, deactivate

# loading info for startup script
write-host 'PSConda.psm1 loaded ...'


