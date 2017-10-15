cd "C:\Users\dbadmin\Google Drive\LocalSync\Documents\AAIT\powershell scripts\"
powershell get-executionPolicy;
powershell -noexit Set-ExecutionPolicy -executionPolicy RemoteSigned -Force -Scope Process; get-executionPolicy; .\scripts\ps\QA.ps1;
powershell -noexit get-executionPolicy;