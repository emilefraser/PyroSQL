CREATE PROC DSQLT._generateLinkedserver(@Server sysname)
as
BEGIN
DECLARE @datasrc varchar(max)
SET @datasrc= @@Servername
EXEC master.dbo.sp_addlinkedserver @server = @Server, @srvproduct=@Server, @provider=N'SQLNCLI', @datasrc=@datasrc
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=@Server,@useself=N'True',@locallogin=NULL,@rmtuser=NULL,@rmtpassword=NULL
EXEC master.dbo.sp_serveroption @server=@Server, @optname=N'collation compatible', @optvalue=N'false'
EXEC master.dbo.sp_serveroption @server=@Server, @optname=N'data access', @optvalue=N'true'
EXEC master.dbo.sp_serveroption @server=@Server, @optname=N'dist', @optvalue=N'false'
EXEC master.dbo.sp_serveroption @server=@Server, @optname=N'pub', @optvalue=N'false'
EXEC master.dbo.sp_serveroption @server=@Server, @optname=N'rpc', @optvalue=N'false'
EXEC master.dbo.sp_serveroption @server=@Server, @optname=N'rpc out', @optvalue=N'false'
EXEC master.dbo.sp_serveroption @server=@Server, @optname=N'sub', @optvalue=N'false'
EXEC master.dbo.sp_serveroption @server=@Server, @optname=N'connect timeout', @optvalue=N'0'
EXEC master.dbo.sp_serveroption @server=@Server, @optname=N'collation name', @optvalue=null
EXEC master.dbo.sp_serveroption @server=@Server, @optname=N'lazy schema validation', @optvalue=N'false'
EXEC master.dbo.sp_serveroption @server=@Server, @optname=N'query timeout', @optvalue=N'0'
EXEC master.dbo.sp_serveroption @server=@Server, @optname=N'use remote collation', @optvalue=N'true'
EXEC master.dbo.sp_serveroption @server=@Server, @optname=N'remote proc transaction promotion', @optvalue=N'true'
END
