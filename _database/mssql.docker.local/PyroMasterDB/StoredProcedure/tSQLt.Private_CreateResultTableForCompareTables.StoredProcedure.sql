SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tSQLt].[Private_CreateResultTableForCompareTables]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [tSQLt].[Private_CreateResultTableForCompareTables] AS' 
END
GO
ALTER PROCEDURE [tSQLt].[Private_CreateResultTableForCompareTables]
 @ResultTable NVARCHAR(MAX),
 @ResultColumn NVARCHAR(MAX),
 @BaseTable NVARCHAR(MAX)
AS
BEGIN
  DECLARE @Cmd NVARCHAR(MAX);
  SET @Cmd = '
     SELECT ''='' AS ' + @ResultColumn + ', Expected.* INTO ' + @ResultTable + ' 
       FROM tSQLt.Private_NullCellTable N 
       LEFT JOIN ' + @BaseTable + ' AS Expected ON N.I <> N.I 
     TRUNCATE TABLE ' + @ResultTable + ';' --Need to insert an actual row to prevent IDENTITY property from transfering (IDENTITY_COL can't be NULLable);
  EXEC(@Cmd);
END
GO
