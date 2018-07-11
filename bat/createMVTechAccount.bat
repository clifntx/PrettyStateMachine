net user MVTech slowSm!le86 /add /expires:never 
WMIC USERACCOUNT WHERE "Name='MVTech'" SET PasswordExpires=FALSE
net localgroup administrators MVTech /add

net localgroup administrators 	