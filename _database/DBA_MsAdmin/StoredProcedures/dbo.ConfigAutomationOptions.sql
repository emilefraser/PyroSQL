SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE   PROCEDURE ConfigAutomationOptions
AS
BEGIN

SELECT * from sys.objects
--EXEC sp_configure 'Show Advanced Options', 1;
--GO
--RECONFIGURE;
--GO
--EXEC sp_configure;

--EXEC master.sp_configure 'Ole Automation Procedures', 1
--GO
--RECONFIGURE
--GO
--sp_configure 'xp_cmdshell', 1
--GO
--RECONFIGURE
--GO
--sp_configure 'SMO and DMO XPs', 1
--GO
--RECONFIGURE
--GO
--sp_configure 'optimize for ad hoc workloads', 1
--GO
--RECONFIGURE
--GO
--sp_configure 'Database Mail XPs', 1
--GO
--RECONFIGURE
--GO
--sp_configure 'clr enabled', 1
--GO
--RECONFIGURE
--GO
--sp_configure 'clr strict security', 0
--GO
--RECONFIGURE
--GO
--sp_configure 'Ad Hoc Distributed Queries', 1
--GO
--RECONFIGURE
--GO
--sp_configure 'allow polybase export', 1
--GO
--RECONFIGURE
--GO
--sp_configure 'allow updates', 1
--GO
--RECONFIGURE
--GO
--sp_configure 'tempdb metadata memory-optimized', 1
--GO
--RECONFIGURE
--GO

END
GO
