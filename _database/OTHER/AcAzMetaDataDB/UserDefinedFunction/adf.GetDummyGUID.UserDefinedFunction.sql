SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[adf].[GetDummyGUID]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
/*
	Created By: Emile Fraser
	Date: 2020-11-23
	Decription: Gets the dummy GUID

	Test1: SELECT [adf].[GetDummyGUID]()
*/
CREATE    FUNCTION [adf].[GetDummyGUID]()
RETURNS UNIQUEIDENTIFIER
BEGIN

	RETURN (
		SELECT (
			TRY_CONVERT(UNIQUEIDENTIFIER, ''00000000-0000-0000-0000-000000000000'')
		) AS DUMMY_GUID
	)


END;

' 
END
GO
