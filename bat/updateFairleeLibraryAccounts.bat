net user Administrator DOLsecure
WMIC USERACCOUNT WHERE "Name='Administrator'" SET PasswordExpires=FALSE

net user Patron ""
WMIC USERACCOUNT WHERE "Name='Patron'" SET PasswordExpires=FALSE
WMIC USERACCOUNT WHERE "Name='Patron'" SET PasswordRequired=FALSE