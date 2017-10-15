cd "C:\Users\dbadmin\Google Drive\LocalSync\Documents\AAIT\WIn10DesktopDeployment\Scripts"
powershell get-executionPolicy;
powershell -noexit Set-ExecutionPolicy -executionPolicy RemoteSigned -Force -Scope Process; get-executionPolicy; .\QA.ps1;
powershell -noexit get-executionPolicy;