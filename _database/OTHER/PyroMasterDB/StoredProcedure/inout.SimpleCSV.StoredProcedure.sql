SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[inout].[SimpleCSV]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [inout].[SimpleCSV] AS' 
END
GO
ALTER PROCEDURE [inout].[SimpleCSV]
AS
BEGIN

declare @sql varchar(8000)
select @sql = 'bcp master..sysobjects out c:\bcp\sysobjects.txt -c -t, -T -S' + @@servername
exec master..xp_cmdshell @sql
END
GO
