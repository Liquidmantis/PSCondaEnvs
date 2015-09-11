for /f "delims=" %%i in ("%~dp0..\envs") do (
    set ANACONDA_ENVS=%%~fi
    echo $ANACONDA_ENVS
)