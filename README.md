PSCondaEnvs
===========

Drop in replacement scripts that replicate Conda's activate/deactivate functions in Powershell.

### Installation:
Simply copy activate.ps1 and deactivate.ps1 into your Anaconda\Scripts directory.  You may need to remove or rename the existing BAT files but the PS1 versions seem to get precedence.

### Path:
Usually the path is `C:\Users\{USERNAME}\Anaconda3\condabin\`

### Setting Execution Policy:
The file is not digitally signed so the PowerShell will prevent it from running. To unblock the files from Execution Policy run the commands:

`Unblock-File -Path C:\Users\{USERNAME}\Anaconda3\condabin\activate.ps1`

`Unblock-File -Path C:\Users\{USERNAME}\Anaconda3\condabin\deactivate.ps1`

Replace the {USERNAME} section with your username.

### Commands for managing the environments in PowerShell
`activate {environment_name}`

`deactivate {environment_name}`

### Added Features:
The optional -UpdateRegistry switch has been added which will update the Python installpath to be the activated virtualenv.  I added this for installing compiled modules which detect the Python path from the registry.
THIS SHOULD BE USED WITH EXTREME CAUTION!  This has only been tested on my system and is hardcoded to the 2.7 installpath.  This setting is also persistent unlike the session-based ephemeral virtualenv activation.  Deactivate.ps1 will detect and prompt for reverting the change if a virtualenv hasn't been properly deactivated.

### Credit:
* Original Conda batch files.
* https://bitbucket.org/guillermooo/virtualenvwrapper-powershell
