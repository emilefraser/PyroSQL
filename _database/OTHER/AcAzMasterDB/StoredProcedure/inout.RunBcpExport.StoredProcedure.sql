SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[inout].[RunBcpExport]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [inout].[RunBcpExport] AS' 
END
GO

ALTER   PROCEDURE [inout].[RunBcpExport]
AS
declare @sql varchar(8000)
select @sql = 'bcp tempdb..vw_bcpMasterSysobjects out 
                 c:\bcp\sysobjects.txt -c -t, -T -S' + @@servername
exec xp_cmdshell @sql
GO
