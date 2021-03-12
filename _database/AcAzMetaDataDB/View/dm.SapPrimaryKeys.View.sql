SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dm].[SapPrimaryKeys]'))
EXEC dbo.sp_executesql @statement = N'
-- SELECT * FROM [dm].[SapPrimaryKeys] ORDER BY [TABNAME], [POSITION]
CREATE     VIEW [dm].[SapPrimaryKeys]
AS
	SELECT
		[dd03m].[TABNAME]
	  , [dd03m].[DDLANGUAGE]	
	  , [dd03m].[FIELDNAME]
	  , [dd03m].[DDTEXT]	
	  , [dd03m].[POSITION]
	FROM
		[dm].[DD03M_Generated_Table_for_View_PROD] AS [dd03m]
	WHERE
		[dd03m].[DDLANGUAGE] = ''E''
	AND
		[dd03m].[KEYFLAG] = ''X''
		
' 
GO
