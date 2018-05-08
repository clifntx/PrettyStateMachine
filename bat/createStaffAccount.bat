net user Staff staff@2012 /PASSWORDCHG:NO /ADD
WMIC USERACCOUNT WHERE "Name='Staff'" SET PasswordExpires=FALSE