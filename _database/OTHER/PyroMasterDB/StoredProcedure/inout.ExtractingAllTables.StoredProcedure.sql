SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[inout].[ExtractingAllTables]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [inout].[ExtractingAllTables] AS' 
END
GO
ALTER PROCEDURE [inout].[ExtractingAllTables] AS
BEGIN

select 'exec master..xp_cmdshell' 
		+ ' '''
		+ 'bcp'
		+ ' ' + TABLE_CATALOG + '.' + TABLE_SCHEMA + '.' + TABLE_NAME 
		+ ' out'
		+ ' c:\bcp\'
		+ TABLE_CATALOG + '.' + TABLE_SCHEMA + '.' + TABLE_NAME + '.bcp' 
		+ ' -N'
		+ ' -T'
		+ ' -S' + @@servername
		+ ''''
from INFORMATION_SCHEMA.TABLES
where TABLE_TYPE = 'BASE TABLE'

--exec master..xp_cmdshell 'bcp tempdb.dbo.Extract out c:\bcp\tempdb.dbo.Extract.bcp -N -T –S<servername>'

END
GO
