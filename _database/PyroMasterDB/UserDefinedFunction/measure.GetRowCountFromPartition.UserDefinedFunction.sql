SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[measure].[GetRowCountFromPartition]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'

-- Created By: Emile Fraser
-- Date: 2020-09-09
-- Get Quick Table Rowcount for the partition sys view
CREATE      FUNCTION [measure].[GetRowCountFromPartition] (
	@SchemaName		SYSNAME
,	@TableName		SYSNAME
)
RETURNS INT
AS
BEGIN
   RETURN (SELECT [RowCount] FROM balance.GetSchemaRowCountFromPartition(@SchemaName, '''') WHERE TableName = @TableName)
END

' 
END
GO
