@ECHO OFF

SqlLocalDB create "PERFORMANCE" 14.0 -s
SqlLocalDB.exe share "PERFORMANCE" "PERFORMANCESharedLocalDB"  
SqlLocalDB.exe start "PERFORMANCE"  
SqlLocalDB.exe info "PERFORMANCE"  

REM The previous statement outputs the Instance pipe name for the next step  
sqlcmd -S np:\\.\pipe\LOCALDB#5A4CF929\tsql\query 
CREATE LOGIN NewLogin WITH PASSWORD = 'Passw0rd!!@52';   
GO  
CREATE USER NewLogin;  
GO  
EXIT  

PAUSE