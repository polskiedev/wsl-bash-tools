@echo off
set "source=%USERPROFILE%\Documents\wsl-bash-projects"
set "destination=\\wsl.localhost\Ubuntu\root\wsl-bash-tools\polskie"

echo "Copying files from %source%\projects to %destination%\projects ..."
xcopy "%source%\projects" "%destination%\projects" /E /I /Y

echo "Copying .env from %source% to %destination% ..."
xcopy "%source%\.env" "%destination%\" /E /I /Y
echo Files copied successfully.
pause