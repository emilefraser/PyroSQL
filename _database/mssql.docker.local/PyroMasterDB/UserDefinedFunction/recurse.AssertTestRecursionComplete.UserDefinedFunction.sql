SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[recurse].[AssertTestRecursionComplete]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'/*
	SELECT [recurse].[AssertTestRecursionComplete]
*/
CREATE   FUNCTION [recurse].[AssertTestRecursionComplete] (							
)
RETURNS BIT
AS
BEGIN
	RETURN ((
		SELECT
			IIF(COUNT(1) > 0 , 0, 1)
		FROM 
			[DEV_DataVault__ODS_CAMS__DocImage] AS a 
		LEFT JOIN 
			[dbo_DocImageArchive] AS b 
			ON a.DocImageID = b.DocImageID 
		WHERE 
			b.[IsUploaded] IS NULL
	))
END' 
END
GO
