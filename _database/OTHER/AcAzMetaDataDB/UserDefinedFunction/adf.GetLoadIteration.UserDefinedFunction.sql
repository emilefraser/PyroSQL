SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[adf].[GetLoadIteration]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
/*
	Created By: Emile Fraser
	Date: 2020-09-26
	Decription: Gets the Current Load Iteration (Initial or Subsequent)

	Test1: SELECT [adf].[GetLoadIteration] (0, 0, 1000)	-- SUBSEQUENT
	Test2: SELECT [adf].[GetLoadIteration] (1, 0, 1000) -- INITIAL
	Test3: SELECT [adf].[GetLoadIteration] (0, 1, 1000) -- INITIAL
	Test4: SELECT [adf].[GetLoadIteration] (0, 0, 1000) -- SUBSEQUENT
	Test5: SELECT [adf].[GetLoadIteration] (0, 0, 0)	-- SUBSEQUENT
	Test6: SELECT [adf].[GetLoadIteration] (1, 1, 0)	-- INITIAL
*/
CREATE     FUNCTION [adf].[GetLoadIteration] (
	@IsDropAndRecreateTarget	BIT = NULL	
,	@IsTruncateAndReloadTarget	BIT = NULL 
,	@RowCount					INT	= NULL
)
RETURNS VARCHAR(10)
BEGIN
	RETURN (
		CASE WHEN 			
			COALESCE(@IsDropAndRecreateTarget, 0)				= 1 
			OR COALESCE(@IsTruncateAndReloadTarget, 0)			= 1
			OR @RowCount										IS NULL								
				THEN ''INITIAL''
				ELSE ''SUBSEQUENT''
			END
	)

END;

' 
END
GO
