SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dba].[GetDMVObjects]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dba].[GetDMVObjects] 
AS 
	SELECT 
		*
	FROM 
		sys.objects AS obj
	WHERE
		obj.name LIKE ''dm%''' 
GO
