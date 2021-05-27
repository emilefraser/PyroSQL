SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[adf].[GetTargetEntityName]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
/*
	Created By: Emile Fraser
	Date: 2020-11-20
	Decription: Gets the Full Target side Entity Name including Environment

	Test1: SELECT [adf].[GetTargetEntityName] (0, 1, ''PROD'', ''Test'', 0) -- Test_PROD
	Test2: SELECT [adf].[GetTargetEntityName] (0, 1, ''PROD'', ''Test'', 1) -- Test_PROD_Staged
*/
CREATE     FUNCTION [adf].[GetTargetEntityName] (
	@IsPrependLoadEnvironmentCode	BIT
,	@IsAppendLoadEnvironmentCode	BIT
,	@LoadEnvironmentCode			NVARCHAR(MAX)
,	@TargetEntityName				NVARCHAR(MAX)
,	@IsUseStageTable				BIT
)
RETURNS NVARCHAR(MAX)
BEGIN
	RETURN (
		SELECT 
			CONCAT_WS(
				''_''
			,	IIF(@IsPrependLoadEnvironmentCode = 1
					, @LoadEnvironmentCode
					, NULL
				)
			,	@TargetEntityName
			,	IIF(@IsAppendLoadEnvironmentCode = 1
					, @LoadEnvironmentCode				
					, NULL
				) 
			+	IIF(@IsUseStageTable = 1
					, ''_Staged''
					, ''''
				)
			)
	)


END;

' 
END
GO
