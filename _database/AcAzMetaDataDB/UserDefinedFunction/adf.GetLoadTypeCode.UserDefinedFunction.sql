SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[adf].[GetLoadTypeCode]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
/*
	Created By: Emile Fraser
	Date: 2020-09-26
	Decription: Gets the Current Load Iteration

	Test1: SELECT [adf].[GetLoadTypeCode] (0, 0, 1000, ''FULL'')			-- FULL
	Test2: SELECT [adf].[GetLoadTypeCode] (0, 0, 1000,''INCREMENTAL'')	-- INITIAL
*/
CREATE     FUNCTION [adf].[GetLoadTypeCode] (
	@IsDropAndRecreateTarget	BIT			= NULL	
,	@IsTruncateAndReloadTarget	BIT			= NULL 
,	@RowCount					INT			= NULL
,	@LoadTypeCode				VARCHAR(30) = ''FULL''

)
RETURNS VARCHAR(30)
BEGIN
	RETURN (
		CASE WHEN 
			
			COALESCE(@IsDropAndRecreateTarget, 0)				= 1 
			OR COALESCE(@IsTruncateAndReloadTarget, 0)			= 1
			OR COALESCE(@RowCount,0)							IS NULL								
				THEN ''FULL''
				ELSE @LoadTypeCode
			END
	)

END;

' 
END
GO
