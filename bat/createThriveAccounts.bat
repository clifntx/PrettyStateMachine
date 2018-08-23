net user Thrivetech ivoryKo@la40 /add /expires:never 
WMIC USERACCOUNT WHERE "Name='Thrivetech'" SET PasswordExpires=FALSE
net localgroup administrators Thrivetech /add

net user biznable giantHamst3r17 /add /expires:never 
WMIC USERACCOUNT WHERE "Name='biznable'" SET PasswordExpires=FALSE
net localgroup administrators biznable /add

net localgroup administrators 	