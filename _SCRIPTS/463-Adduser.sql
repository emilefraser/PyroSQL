Declare @ret int
PRINT 'added windows login $(login) to '+ db_name()+' on '+@@Servername + ' as "$(membername)"'
/* Adds a security account in the current database for a SQL Server login or Windows
 user or group, and enables it to be granted permissions to perform activities in the
 database*/
EXEC @ret=sp_grantdbaccess '$(login)', '$(membername)'
if @ret=0 print 'successfully' else print 'with errors!'
PRINT 'added $(membername) to $(rolename) on '+ db_name()+' on '+@@Servername
/*Adds the database user, database role, Windows login, or Windows group to a database role in the current database.*/
EXEC @ret=sp_addrolemember '$(rolename)', '$(membername)'
if @ret=0 print 'successfully' else print 'with errors!'
Go

