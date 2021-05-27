SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tool].[GetGreatest]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
/*
	Created By: Emile Fraser
	Date: 2020-09-26
	Decription: GEts the Greatest of 2 values and returns 

	Test1: SELECT [tool].[GetGreatest] (''24'', ''145'')
*/
CREATE   FUNCTION [tool].[GetGreatest] (@value1 NVARCHAR(MAX), @value2 NVARCHAR(MAX))
RETURNS NVARCHAR(MAX)
BEGIN


	RETURN (
		SELECT 
			IIF(TRY_CONVERT(INT, @value1) <= TRY_CONVERT(INT, @value2)
				, @value2
				, @value1
			)
	)


END;

' 
END
GO
