SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tSQLt].[Private_SqlVersion]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [tSQLt].[Private_SqlVersion]()
RETURNS TABLE
AS
RETURN
  SELECT CAST(DATABASEPROPERTYEX(DB_NAME(), ''ProductVersion'')AS NVARCHAR(128)) ProductVersion,
         CAST(DATABASEPROPERTYEX(DB_NAME(), ''Edition'')AS NVARCHAR(128)) Edition;
' 
END
GO
