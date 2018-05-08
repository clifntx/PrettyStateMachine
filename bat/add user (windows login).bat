@echo off

SET /P UN=User name:
net user "%UN%" * /add /expires:never
timeout /t -1