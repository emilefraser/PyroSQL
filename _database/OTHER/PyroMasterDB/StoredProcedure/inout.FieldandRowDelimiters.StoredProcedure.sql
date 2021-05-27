SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[inout].[FieldandRowDelimiters]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [inout].[FieldandRowDelimiters] AS' 
END
GO
ALTER   PROCEDURE [inout].[FieldandRowDelimiters]
AS
BEGIN

declare @sql varchar(8000)
select @sql = 'bcp master..sysobjects out c:\bcp\sysobjects.txt -c –t| -T -S' + @@servername
exec master..xp_cmdshell @sql

--declare @sql varchar(8000)
select @sql = 'bcp master..sysobjects out c:\bcp\sysobjects.txt -c –t^ -T -S' + @@servername
exec master..xp_cmdshell @sql

--declare @sql varchar(8000)
select @sql = 'bcp master..sysobjects out c:\bcp\sysobjects.txt -c –t|^ -T -S' + @@servername
exec master..xp_cmdshell @sql

select cr = ascii('
')
select lf = ascii(right('
',1))

--declare @sql varchar(8000)
select @sql = 'bcp master..sysobjects out c:\bcp\sysobjects.txt -c -t, -r0x0D -T -S' + @@servername
exec master..xp_cmdshell @sql

--declare @sql varchar(8000)
select @sql = 'bcp master..sysobjects out c:\bcp\sysobjects.txt -c -t"| ^" -r"0x0D0A" -T -S' + @@servername
exec master..xp_cmdshell @sql

END
GO
