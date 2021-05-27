SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dm].[SapObject]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dm].[SapObject]
AS
SELECT [OBJECT]
      ,[TABNAME]
      ,[MULTCASE]				= IIF([MULTCASE] = ''X'', ''Multiple case'', ''Single case'')
	  ,[IsChangeDocumentInsert]	= IIF([DOCUINS] = ''X'', 1, 0)
      ,[IsChangeDocumentDelete]	= IIF([DOCUDEL] = ''X'', 1, 0) 
      ,[REFNAME]
FROM 
	[dm].[TCDOB_Objects_for_change_document_creation]
' 
GO
