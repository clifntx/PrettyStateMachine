net user BFSTech murkyMet@l75 /add /expires:never 
WMIC USERACCOUNT WHERE "Name='BFSTech'" SET PasswordExpires=FALSE
net localgroup administrators BFSTech /add
	