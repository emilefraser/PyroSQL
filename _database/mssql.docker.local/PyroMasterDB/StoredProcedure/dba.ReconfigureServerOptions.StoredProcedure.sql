SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dba].[ReconfigureServerOptions]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dba].[ReconfigureServerOptions] AS' 
END
GO
ALTER PROCEDURE [dba].[ReconfigureServerOptions]
AS
BEGIN

	EXEC sp_configure;  

	EXEC sp_configure 'show advanced option', '1';  
	RECONFIGURE;  

	EXEC sp_configure;  

	EXEC  sp_configure 'Ad Hoc Distributed Queries', '1'
	RECONFIGURE;  

	EXEC sp_configure;  

	EXEC  sp_configure 'remote proc trans', '1'
	RECONFIGURE;  

	EXEC sp_configure;  

	--EXEC  sp_configure 'xp_cmdshell', '1'
	--RECONFIGURE;  

	--EXEC sp_configure;  

	--EXEC  sp_configure 'polybase enabled', '1'
	--RECONFIGURE;  

	--EXEC sp_configure;  

	--EXEC  sp_configure 'Ole Automation Procedures', '1'
	--RECONFIGURE;  


	--EXEC sp_configure;  

	EXEC  sp_configure 'Database Mail XPs', '1'
	RECONFIGURE;  
	
	
	EXEC sp_configure;  

	EXEC  sp_configure 'Agent XPs', '1'
	RECONFIGURE;  


	EXEC sp_configure;  

	EXEC  sp_configure 'clr enabled', '1'
	RECONFIGURE;  
END
GO
