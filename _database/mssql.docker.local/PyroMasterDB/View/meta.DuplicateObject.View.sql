SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[meta].[DuplicateObject]'))
EXEC dbo.sp_executesql @statement = N'/*
	SELECT * FROM meta.DuplicateObject
*/
CREATE   VIEW [meta].[DuplicateObject]
AS
SELECT 
	[OjectName]		= obj.[name]
  , [ObjectCount]	= COUNT(1)
FROM 
	sys.objects AS obj
GROUP BY 
	obj.[name]
HAVING 
	COUNT(1) > 1;' 
GO
