SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tSQLt].[Private_GetCommaSeparatedColumnList]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [tSQLt].[Private_GetCommaSeparatedColumnList] (@Table NVARCHAR(MAX), @ExcludeColumn NVARCHAR(MAX))
RETURNS NVARCHAR(MAX)
AS 
BEGIN
  RETURN STUFF((
     SELECT '','' + CASE WHEN system_type_id = TYPE_ID(''timestamp'') THEN '';TIMESTAMP columns are unsupported!;'' ELSE QUOTENAME(name) END 
       FROM sys.columns 
      WHERE object_id = OBJECT_ID(@Table) 
        AND name <> @ExcludeColumn 
      ORDER BY column_id
     FOR XML PATH(''''), TYPE).value(''.'',''NVARCHAR(MAX)'')
    ,1, 1, '''');
        
END;
' 
END
GO
