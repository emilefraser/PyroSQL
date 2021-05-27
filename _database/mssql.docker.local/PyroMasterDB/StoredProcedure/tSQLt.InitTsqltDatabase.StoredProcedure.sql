SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tSQLt].[InitTsqltDatabase]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [tSQLt].[InitTsqltDatabase] AS' 
END
GO
ALTER   PROCEDURE [tSQLt].[InitTsqltDatabase]
AS 
BEGIN

	DECLARE @cmd NVARCHAR(MAX);
	SET @cmd='EXEC sp_configure ''clr enabled'', 1;
			  RECONFIGURE;'
	EXEC sp_executesql @stmt = @cmd
	SELECT DATABASEPROPERTYEX(DB_NAME(), 'BuildClrVersion')

	SET @cmd='ALTER DATABASE ' + QUOTENAME(DB_NAME()) + ' SET TRUSTWORTHY ON;';
	EXEC(@cmd);
	EXEC sp_executesql @stmt = @cmd

	select name, TrustWorthySetting =
	case is_trustworthy_on
	when 1 then 'TrustWorthy setting is ON for MSDB'
	ELSE 'TrustWorthy setting is OFF for ' + name
	END
	from sys.databases 
	where database_id =  DB_ID()


END
GO
