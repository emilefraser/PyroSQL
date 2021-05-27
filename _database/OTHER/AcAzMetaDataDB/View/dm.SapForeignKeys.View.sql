SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dm].[SapForeignKeys]'))
EXEC dbo.sp_executesql @statement = N'

CREATE   VIEW [dm].[SapForeignKeys]
AS
SELECT DISTINCT
	TABNAME
  , CHECKTABLE
  , CHECKFIELD
  , PRIMPOS
FROM
	[dm].[DD05Q_Generated_table_for_View_PROD]

' 
GO
